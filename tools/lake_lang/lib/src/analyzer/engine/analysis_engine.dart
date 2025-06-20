// ignore_for_file: avoid_print

import 'dart:async';

import '../../ast/nodes/ast_nodes.dart';
import '../../common/span.dart';
import '../diagnostics/diagnostic.dart';
import '../diagnostics/diagnostic_system.dart';
import '../symbol_table/symbol_entry.dart';
import 'analysis_cache.dart';
import 'lake_ast_builder.dart';
import 'lake_file_manager.dart';
import 'lake_semantic_analyzer.dart';
import 'semantic_info.dart';

class AnalysisEngine {
  AnalysisEngine() {
    _diagnosticSystem = DiagnosticSystem();
    _analysisCache = AnalysisCache();

    _fileManager = LakeFileManager(
      analysisCache: _analysisCache,
      diagnosticSystem: _diagnosticSystem,
    );

    _astBuilder = LakeAstBuilder(
      analysisCache: _analysisCache,
      diagnosticSystem: _diagnosticSystem,
      fileManager: _fileManager,
    );

    _semanticAnalyzer = LakeSemanticAnalyzer(
      astBuilder: _astBuilder,
      analysisCache: _analysisCache,
      diagnosticSystem: _diagnosticSystem,
      fileManager: _fileManager,
    );

    _diagnosticSystem.onDiagnosticsChanged.listen((_) {
      _diagnosticsController.add(_diagnosticSystem.getAllDiagnostics());
    });
  }

  late final DiagnosticSystem _diagnosticSystem;
  late final AnalysisCache _analysisCache;
  late final LakeAstBuilder _astBuilder;
  late final LakeFileManager _fileManager;
  late final LakeSemanticAnalyzer _semanticAnalyzer;

  // Stream controller to notify external listeners about diagnostic changes.
  final StreamController<Map<String, List<Diagnostic>>> _diagnosticsController =
      StreamController.broadcast();

  /// A stream that emits the current set of diagnostics whenever they change.
  Stream<Map<String, List<Diagnostic>>> get diagnosticsStream =>
      _diagnosticsController.stream;

  /// Initiates a full analysis run for the given entry points.
  /// This will build the import graph, parse all relevant files,
  /// and perform full semantic analysis.
  void analyzeProject(Iterable<String> entryPoints) {
    print('Starting full project analysis...');
    // Clear everything before a full analysis
    _diagnosticSystem.clearAllDiagnostics();
    _analysisCache.clearAll();

    // The semantic analyzer's performFullAnalysis handles graph building
    // internally
    _semanticAnalyzer.performFullAnalysis(entryPoints);
    print('Full project analysis completed.');
    _diagnosticsController.add(
      _diagnosticSystem.getAllDiagnostics(),
    ); // Emit final diagnostics
  }

  /// Notifies the analysis engine that a file has changed.
  /// This triggers incremental analysis.
  /// In a real application, this would be called by a file watcher.
  void fileChanged(String filePath) {
    print('File changed: $filePath. Starting incremental analysis...');
    // Load the file first to update FileManager's internal state and trigger
    //graph update
    _fileManager.loadFile(filePath);
    // Then trigger semantic analyzer's incremental logic
    _semanticAnalyzer.onFileChanged(filePath);
    print('Incremental analysis for $filePath completed.');
    _diagnosticsController.add(
      _diagnosticSystem.getAllDiagnostics(),
    ); // Emit updated diagnostics
  }

  /// Gets the current diagnostics for a specific file.
  List<Diagnostic> getDiagnosticsForFile(String filePath) =>
      _diagnosticSystem.getDiagnosticsForFile(filePath);

  /// Gets all current diagnostics across the project.
  Map<String, List<Diagnostic>> getAllDiagnostics() =>
      _diagnosticSystem.getAllDiagnostics();

  /// Retrieves the AST for a given file.
  /// This might trigger parsing if not cached.
  Future<DocumentNode?> getAst(String filePath) async =>
      _astBuilder.buildAst(filePath);

  /// Retrieves the semantic information for a given file.
  /// This might trigger analysis if not cached.
  Future<SemanticInfo?> getSemanticInfo(String filePath) async {
    // SemanticInfo is produced by SemanticAnalyzer.analyzeFile.
    // If it's not in cache, we need to trigger its analysis.
    // Note: This might cause a full file analysis if the file hasn't been
    //analyzed yet.
    if (_analysisCache.getSemanticInfo(filePath) == null) {
      _semanticAnalyzer.analyzeFile(filePath);
    }
    return _analysisCache.getSemanticInfo(filePath);
  }

  /// Provides an API for Go-to-Definition.
  /// Returns the definition [SymbolInfo] for a symbol at a given [offset] in a [filePath].
  /// This would typically involve finding the [IdentifierNode] at the offset first.
  Future<SymbolEntry?> getDefinitionAtOffset(
    String filePath,
    int offset,
  ) async {
    final absolutePath = _fileManager.resolvePath('', filePath);
    final semanticInfo = await getSemanticInfo(absolutePath);
    if (semanticInfo == null) {
      return null;
    }

    // TODO: This is a placeholder. A real implementation needs to:
    // 1. Get the AST for the file.
    // 2. Traverse the AST to find the *IdentifierNode* at the given offset.
    // 3. Look up this IdentifierNode in the _resolvedReferences map
    // (from TypeResolutionVisitor).
    // 4. Return the SymbolInfo associated with that IdentifierNode.
    // This requires exposing _resolvedReferences or a lookup method from
    // SemanticInfo.

    // For now, let's return a dummy symbol if any symbol contains the offset
    // This logic needs to be robust, possibly using a dedicated AST visitor for
    // queries.
    // Example: Iterate over all symbols in local table and check if span
    //contains offset.
    // for (final symbol in semanticInfo.localSymbolTable.getSymbolsInScope()) {
    //   if (symbol.definitionSpan.contains(offset)) {
    //     return symbol; // This is actually the definition, not the reference.
    //   }
    // }
    return null;
  }

  /// Provides an API for Find All References.
  /// Returns a list of [Span]s where the symbol at the given [offset] in
  /// [filePath] is referenced.
  Future<List<Span>> getReferencesAtOffset(String filePath, int offset) async {
    final definitionSymbol = await getDefinitionAtOffset(filePath, offset);
    if (definitionSymbol == null) {
      return [];
    }

    throw UnimplementedError(
      'Find All References is not yet implemented. '
      'This requires a full symbol resolution and reference collection pass.',
    );

    // return definitionSymbol.references;
  }

  /// Disposes of internal resources.
  Future<void> dispose() async {
    await _diagnosticsController.close();
    // No other explicit dispose methods for other components yet,
    // but this is where you'd add them if they manage resources.
  }
}
