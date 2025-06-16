import '../nodes/ast_nodes.dart';
import 'errors/error_reporter.dart';
import 'symbols/symbol_table.dart';
import 'visitors/symbol_table_visitor.dart';
import 'visitors/type_checking_visitor.dart';

class SemanticAnalyzer {
  const SemanticAnalyzer();

  void analyze({
    required DocumentNode document,
    required ErrorReporter reporter,
  }) {
    final symbolTable = SymbolTable(reporter);

    final symbolTableVisitor = SymbolTableVisitor(symbolTable, reporter);
    document.accept(symbolTableVisitor);

    final typeCheckingVisitor = TypeCheckingVisitor(symbolTable, reporter);
    document.accept(typeCheckingVisitor);
  }
}
