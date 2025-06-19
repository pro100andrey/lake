import 'package:petitparser/petitparser.dart';

import '../../ast/lake_ast_grammar_definition.dart';
import '../../ast/nodes/ast_nodes.dart';
import '../diagnostics/diagnostic_system.dart';
import '../diagnostics/diagnostics.dart';
import '../file_manager/lake_file_manager.dart';
import 'analysis_cache.dart';

/// Builds the Abstract Syntax Tree (AST) for a given source file.
/// It uses the LakeAstGrammarDefinition to parse the file content
/// and produces a DocumentNode. It also interacts with the cache
/// to store/retrieve ASTs and reports parsing errors to the diagnostic system.
final class LakeAstBuilder {
  LakeAstBuilder({
    required AnalysisCache analysisCache,
    required DiagnosticSystem diagnosticSystem,
    required LakeFileManager fileManager,
  }) : _analysisCache = analysisCache,
       _diagnosticSystem = diagnosticSystem,
       _fileManager = fileManager {
    _astParser = const LakeAstGrammarDefinition().build();
  }

  final AnalysisCache _analysisCache;
  final DiagnosticSystem _diagnosticSystem;
  final LakeFileManager _fileManager;

  /// The parser instance configured to build the AST.
  late final Parser _astParser;

  /// Parses the content of a file and returns its DocumentNode (AST).
  ///
  /// This method first checks the cache. If a valid AST exists, it's returned.
  /// Otherwise, the file content is parsed, and the resulting AST (or errors)
  /// are stored in the cache and reported to the diagnostic system.
  Future<DocumentNode?> buildAst(String filePath) async {
    final absolutePath = _fileManager.resolvePath('', filePath);

    // 1. Check cache first
    final cachedAst = _analysisCache.getAst(absolutePath);
    if (cachedAst != null) {
      return cachedAst;
    }

    // 2. If not in cache or invalidated, load file content
    SourceItem sourceItem;

    try {
      sourceItem = _fileManager.getSourceItem(absolutePath);
    } on Exception catch (e) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          filePath: absolutePath,
          message: 'Failed to load file for AST build: $e',
          span: (start: 0, end: 0), // No specific span for file loading error
        ),
      );
      return null;
    }

    // Clear old parsing diagnostics for this file before re-parsing
    _diagnosticSystem.clearDiagnosticsForFile(absolutePath);

    // 3. Parse the file content

    try {
      final result = _astParser.parse(sourceItem.content);

      switch (result) {
        case Success(value: final documentNode):
          _analysisCache.setAst(absolutePath, documentNode);
          return documentNode;

        case Failure():
          _diagnosticSystem.report(
            GenericDiagnostic(
              filePath: absolutePath,
              message: 'Syntax error: ${result.message}',
              span: (
                start: result.position,
                end: result.position + 1,
              ),
            ),
          );

          _analysisCache.invalidate(absolutePath);

          return null;
      }
    } on Exception catch (e) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          filePath: absolutePath,
          message: 'Error during AST parsing: $e',
          span: (start: 0, end: 0), // No specific span for parsing error
        ),
      );

      // Mark as invalid if an exception occurs
      _analysisCache.invalidate(absolutePath);
    }

    return null;
  }
}
