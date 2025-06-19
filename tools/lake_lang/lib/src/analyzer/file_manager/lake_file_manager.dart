import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';

import '../../../lake_lang.dart';
import '../engine/analysis_cache.dart';

typedef SourceItem = ({SourceFile sourceFile, String content});

/// Represents a node in the import graph.
final class _ImportGraphNode {
  // Files that import this node

  _ImportGraphNode(this.filePath);

  final String filePath;
  final Set<String> imports = {}; // Files this node imports
  final Set<String> dependents = {};
}

final class LakeFileManager {
  LakeFileManager({
    required AnalysisCache analysisCache,
    required DiagnosticSystem diagnosticSystem,
  }) : _analysisCache = analysisCache,
       _diagnosticSystem = diagnosticSystem;

  // final LakeAstBuilder _astBuilder;
  final AnalysisCache _analysisCache;
  final DiagnosticSystem _diagnosticSystem;

  // Map of file path to its graph node
  final Map<String, _ImportGraphNode> _importGraph = {};

  List<String> get allGraphFiles => _importGraph.keys.toList();

  // Track files that have been processed for import graph building
  final Set<String> _processedForGraph = {};

  // For managing open/watched files (simplified for now)
  final Map<String, SourceItem> _sourceItems = {};
  // _sourceItems.containsKey(dependentPath)
  bool sourceItemExists(String path) => _sourceItems.containsKey(path);

  /// Loads the content of a file and stores it.
  /// This should be called when a file is opened or changed.
  Future<SourceItem> loadFile(String filePath) async {
    final absolutePath = p.absolute(filePath);

    if (!_sourceItems.containsKey(absolutePath)) {
      final content = await File(absolutePath).readAsString();
      final sourceFile = SourceFile.fromString(content, url: absolutePath);

      _sourceItems[absolutePath] = (sourceFile: sourceFile, content: content);
      // Invalidate cache for this file as it's been loaded/reloaded
      _analysisCache.invalidate(absolutePath);
      // Trigger graph update for this file later
      await _updateImportGraphForFile(absolutePath);
    }

    return _sourceItems[absolutePath]!;
  }

  /// Gets the [SourceFile] object for a given path.
  /// Throws an error if the file is not loaded.
  SourceItem getSourceItem(String filePath) {
    final absolutePath = p.absolute(filePath);
    if (!_sourceItems.containsKey(absolutePath)) {
      throw ArgumentError('File $absolutePath has not been loaded.');
    }

    return _sourceItems[absolutePath]!;
  }

  /// Resolves an imported path relative to the importing file's path.
  /// Handles both relative (e.g., 'my_module') and absolute (e.g., '/libs/utils') paths.
  String resolvePath(String currentFilePath, String importedPath) {
    if (p.isAbsolute(importedPath)) {
      // If the imported path is already absolute, use it directly.
      return p.normalize(importedPath);
    } else {
      // Resolve relative to the directory of the current file.
      final currentDir = p.dirname(currentFilePath);
      return p.normalize(p.join(currentDir, importedPath));
    }
  }

  /// Builds or updates the import graph for a given file.
  /// This involves parsing its imports and linking nodes.
  /// Returns a list of newly discovered imported file paths.
  Future<List<String>> _updateImportGraphForFile(String filePath) async {
    // Clear old diagnostics for this file
    _diagnosticSystem.clearDiagnosticsForFile(filePath);

    _getOrCreateNode(filePath); // Ensure the node exists

    // Clear old import relationships for this file
    _importGraph[filePath]!.imports.clear();

    final sourceItem = getSourceItem(filePath);
    final parser = const LakeAstGrammarDefinition().build();
    final result = parser.parse(sourceItem.content);

    final newImports = <String>[];

    switch (result) {
      case Success(value: final value):
        final documentNode = value! as DocumentNode;
        final headers = documentNode.headers;
        final imports = headers
            .whereType<ImportNode>()
            .map((header) => header.path.value)
            .toList(growable: false);

        for (final importedPathRaw in imports) {
          final resolvedImportPath = resolvePath(filePath, importedPathRaw);
          _importGraph[filePath]!.imports.add(resolvedImportPath);
          _getOrCreateNode(resolvedImportPath).dependents.add(filePath);
          newImports.add(resolvedImportPath);

          // Recursively load and process new imports if not already processed
          if (!_processedForGraph.contains(resolvedImportPath)) {
            _processedForGraph.add(resolvedImportPath);
            try {
              await loadFile(
                resolvedImportPath,
              ); // This will recursively update graph
            } on Exception catch (e) {
              _diagnosticSystem.report(
                GenericDiagnostic(
                  filePath: filePath,
                  message:
                      'Could not load imported file "$importedPathRaw": $e',
                  span: (start: 0, end: 0), // Placeholder span
                ),
              );
            }
          }
        }

      // Successfully parsed, proceed with import extraction
      case Failure():
        _diagnosticSystem.report(
          GenericDiagnostic(
            filePath: filePath,
            message: 'Parsing error for import graph: ${result.message}',
            span: (
              start: result.position,
              end: result.position + 1,
            ),
          ),
        );
    }

    _processedForGraph.add(filePath); // Mark as processed for graph building
    return newImports;
  }

  /// Helper to get or create an import graph node.
  _ImportGraphNode _getOrCreateNode(String filePath) =>
      _importGraph.putIfAbsent(filePath, () => _ImportGraphNode(filePath));

  /// Builds the initial import graph from a set of entry points.
  Future<void> buildInitialImportGraph(Iterable<String> entryPoints) async {
    _importGraph.clear();
    _processedForGraph.clear();
    _diagnosticSystem
        .clearAllDiagnostics(); // Clear all diagnostics before full rebuild

    for (final entryPoint in entryPoints) {
      final absolutePath = p.absolute(entryPoint);
      if (!_processedForGraph.contains(absolutePath)) {
        await loadFile(absolutePath); // This will recursively update graph
      }
    }

    _detectAndReportCycles();
  }

  /// Detects and reports import cycles using DFS.
  void _detectAndReportCycles() {
    final visiting = <String>{}; // Nodes currently in the recursion stack
    final visited = <String>{}; // Nodes already fully visited

    void dfs(String nodePath) {
      visiting.add(nodePath);
      visited.add(nodePath);

      final node = _importGraph[nodePath];
      if (node != null) {
        for (final importPath in node.imports) {
          if (visiting.contains(importPath)) {
            // Cycle detected!
            _diagnosticSystem.report(
              GenericDiagnostic(
                filePath: nodePath,
                message:
                    'Circular dependency detected: $nodePath -> ... -> '
                    '$importPath -> $nodePath',
                span: (start: 0, end: 0), // Placeholder span
              ),
            );
          }
          if (!visited.contains(importPath) &&
              _importGraph.containsKey(importPath)) {
            dfs(importPath);
          }
        }
      }
      visiting.remove(nodePath);
    }

    for (final nodePath in _importGraph.keys) {
      if (!visited.contains(nodePath)) {
        dfs(nodePath);
      }
    }
  }

  /// Gets all files that directly or indirectly depend on `filePath`.
  /// Used for invalidating cache upon changes.
  Set<String> getTransitiveDependents(String filePath) {
    final dependents = <String>{};
    final queue = <String>[filePath];
    final visited = <String>{};

    while (queue.isNotEmpty) {
      final currentFile = queue.removeAt(0);
      if (!visited.add(currentFile)) {
        continue;
      }

      final node = _importGraph[currentFile];
      if (node != null) {
        for (final dependentFile in node.dependents) {
          if (!dependents.contains(dependentFile)) {
            dependents.add(dependentFile);
            queue.add(dependentFile);
          }
        }
      }
    }

    return dependents;
  }
}
