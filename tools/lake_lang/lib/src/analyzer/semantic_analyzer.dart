// ignore_for_file: avoid_print

import '../ast/lake_ast_grammar_definition.dart';
import '../ast/nodes/ast_nodes.dart';
import 'errors/error_reporter.dart';
import 'symbol_table/compilation_symbol_table.dart';
import 'symbol_table/symbol_table_builder.dart';
import 'visitors/initial_symbol_collector_visitor.dart';
import 'visitors/symbol_table_populator_visitor.dart';

class SemanticAnalyzerNew {
  SemanticAnalyzerNew(ErrorReporter errorReporter)
    : _errorReporter = errorReporter,
      _compilationSymbolTable = CompilationSymbolTable(errorReporter),
      _astGrammar = const LakeAstGrammarDefinition();

  final LakeAstGrammarDefinition _astGrammar;
  late final _parser = _astGrammar.build();

  final ErrorReporter _errorReporter;

  final CompilationSymbolTable _compilationSymbolTable;

  bool analyze(Map<String, String> sourceFiles) {
    _errorReporter.clearErrors();

    final parsedAsts = <String, DocumentNode>{};
    final fileBuilders = <String, SymbolTableBuilder>{};

    print('Starting semantic analysis: Pass 1 (Symbol Collection)...');

    for (final entry in sourceFiles.entries) {
      final filePath = entry.key;
      final sourceCode = entry.value;

      final result = _parser.parse(sourceCode);

      final document = result.value as DocumentNode?;

      if (document == null) {
        _errorReporter.reportGeneric(
          message:
              'Parsing failed for file "$filePath". '
              'Skipping semantic analysis for this file.',
          span: (start: 0, end: 0),
          filePath: filePath,
        );

        continue;
      }

      parsedAsts[filePath] = document;

      final symbolTableBuilder = SymbolTableBuilder(
        filePath: filePath,
        errorReporter: _errorReporter,
        compilationSymbolTable: _compilationSymbolTable,
      );

      fileBuilders[filePath] = symbolTableBuilder;

      // First pass: Collect initial symbols.
      final initialCollector = InitialSymbolCollectorVisitor(
        symbolTableBuilder: symbolTableBuilder,
        reporter: _errorReporter,
      );

      document.accept(initialCollector);

      if (_errorReporter.hasErrors) {
        print('Errors detected during Pass 1 for $filePath.');
        // Potentially stop early or continue to collect all pass 1 errors
        // For a full compiler, you might want to gather all errors from both
        // passes before reporting.
      }
    }

    if (_errorReporter.hasErrors) {
      print('Semantic analysis failed during Pass 1. Reporting errors.');

      _errorReporter.printDiagnostics();

      return false;
    }

    for (final entry in parsedAsts.entries) {
      final filePath = entry.key;
      final document = entry.value;
      final symbolTableBuilder = fileBuilders[filePath]!;

      // Run SymbolTablePopulatorVisitor
      final populator = SymbolTablePopulatorVisitor(
        compilationSymbolTable: _compilationSymbolTable,
        symbolTableBuilder: symbolTableBuilder,
        reporter: _errorReporter,
      );

      document.accept(populator);

      if (_errorReporter.hasErrors) {
        print('Errors detected during Pass 2 for $filePath.');
        // Continue to collect all pass 2 errors
      }
    }

    print('Semantic analysis completed.');

    if (_errorReporter.hasErrors) {
      print('Semantic analysis failed with errors:');
      _errorReporter.printDiagnostics();
      return false;
    }

    print('No semantic errors found.');
    return true;
  }

  /// Provides access to the completed compilation symbol table.
  CompilationSymbolTable get compilationSymbolTable => _compilationSymbolTable;
}
