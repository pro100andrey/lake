import 'package:source_span/source_span.dart';

import '../nodes/ast_nodes.dart';
import 'errors/error_reporter.dart';
import 'symbols/symbol_table.dart';
import 'visitors/symbol_table_visitor.dart';
import 'visitors/type_checking_visitor.dart';

class SemanticAnalyzer {
  const SemanticAnalyzer();

  void analyze({
    required DocumentNode document,
    required SourceFile sourceFile,
  }) {
    final reporter = ErrorReporter();
    final symbolTable = SymbolTable(reporter);

    final symbolTableVisitor = SymbolTableVisitor(symbolTable, reporter);

    document.accept(symbolTableVisitor);

    final typeCheckingVisitor = TypeCheckingVisitor(symbolTable, reporter);

    document.accept(typeCheckingVisitor);
  }
}
