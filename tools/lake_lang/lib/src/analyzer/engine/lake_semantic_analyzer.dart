// ignore_for_file: avoid_print

import 'package:path/path.dart' as p;

import '../diagnostics/diagnostic_system.dart';
import '../symbol_table/compilation_symbol_table.dart';
import '../symbol_table/symbol_table_builder.dart';
import '../visitors/initial_symbol_collector_visitor.dart';
import 'analysis_cache.dart';
import 'lake_ast_builder.dart';
import 'lake_file_manager.dart';

/// The main semantic analyzer for the Lake IDL.
/// It orchestrates symbol collection, type resolution, and semantic checks.
class LakeSemanticAnalyzer {
  LakeSemanticAnalyzer({
    required LakeAstBuilder astBuilder,
    required AnalysisCache analysisCache,
    required DiagnosticSystem diagnosticSystem,
    required LakeFileManager fileManager,
  }) : _astBuilder = astBuilder,
       _analysisCache = analysisCache,
       _diagnosticSystem = diagnosticSystem,
       _fileManager = fileManager;

  final LakeAstBuilder _astBuilder;
  final AnalysisCache _analysisCache;
  final DiagnosticSystem _diagnosticSystem;
  final LakeFileManager _fileManager;

  /// Analyzes a single file.
  /// This method is designed to be called for incremental analysis.
  /// It performs both symbol collection and type resolution/checking.
  void analyzeFile(String filePath) {
    print(
      'SemanticAnalyzer: Starting analysis for file: '
      '${p.basename(filePath)}',
    );

    final absolutePath = _fileManager.resolvePath('', filePath);
    // Clear old semantic diagnostics for this file
    _diagnosticSystem.clearDiagnosticsForFile(absolutePath);


    // 1. Get AST (from cache or parse)
    final ast = _astBuilder.buildAst(absolutePath);

    if (ast == null) {
      // AST build failed, diagnostics already reported by AstBuilder.
      // Invalidate global symbols related to this file if it previously existed
      // _globalSymbolTable.removeFileExports(absolutePath);
      _analysisCache.invalidate(absolutePath); // Ensure it's marked invalid
      return;
    }

    final sourceItem = _fileManager.getSourceItem(absolutePath);

    // 2. Phase 1: Symbol Collection
    // Build a fresh local symbol table for this file.
    // Any existing symbols for this file in GlobalSymbolTable will be replaced.

    // _globalSymbolTable.removeFileExports(absolutePath);

    final compilationTable = CompilationSymbolTable(
      diagnosticSystem: _diagnosticSystem,
    );

    final symbolTableBuilder = SymbolTableBuilder(
      filePath: absolutePath,
      diagnosticSystem: _diagnosticSystem,
      compilationSymbolTable: compilationTable,
    );
    final initialSymbolCollector = InitialSymbolCollectorVisitor(
      symbolTableBuilder: symbolTableBuilder,
      diagnosticSystem: _diagnosticSystem,
    );

    // Traverse the AST to collect symbols and build the local symbol table.
    ast.accept(initialSymbolCollector);
  }

  /// Initiates a full analysis run for a set of entry points.
  /// This typically follows a full import graph build.
  void performFullAnalysis(Iterable<String> entryPoints) {
    _diagnosticSystem.clearAllDiagnostics();
    _analysisCache.clearAll();
    // _globalSymbolTable.clear();

    // Ensure all files are loaded and graph is built
    _fileManager.buildInitialImportGraph(entryPoints);

    // Get all files that are part of the project (keys in import graph)
    final allProjectFiles = _fileManager.getTransitiveDependents('');
    // This is a simplification; a better way is to iterate
    // _fileManager._importGraph.keys directly.

    _fileManager.allGraphFiles.forEach(analyzeFile);
  }

  /// Handles a file change notification from FileManager.
  /// This is the core of the incremental analysis logic.
  void onFileChanged(String filePath) {
    _diagnosticSystem.clearDiagnosticsForFile(
      filePath,
    ); // Clear old diagnostics for the changed file

    // Invalidate the changed file and all its transitive dependents in the
    // cache.
    // The FileManager already invalidated the changed file when it was loaded.
    // Now invalidate dependents.
    final dependents = _fileManager.getTransitiveDependents(filePath)
      ..forEach(_analysisCache.invalidate);

    // First analyze the changed file itself
    analyzeFile(filePath);

    // Then re-analyze its dependents if they are currently loaded/cached and invalidated
    // (This ensures consistency in semantic checks across files)
    for (final dependentPath in dependents) {
      // Only re-analyze if it's in the cache and marked invalid (meaning it needs re-processing)
      // and if its AST is still available (i.e., file exists and parsed previously)
      if (_analysisCache.isInvalidated(dependentPath) &&
          _fileManager.sourceItemExists(dependentPath)) {
        analyzeFile(dependentPath);
      }
    }
    // _globalSymbolTable is updated automatically within analyzeFile,
    // and resolved references within each file also get updated.
  }
}
