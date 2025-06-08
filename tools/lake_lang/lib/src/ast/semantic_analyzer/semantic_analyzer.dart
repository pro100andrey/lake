import '../nodes/ast_nodes.dart';
import 'error_reporter.dart';
import 'symbol_table.dart';
import 'visitors/symbol_table_visitor.dart';
import 'visitors/type_checking_visitor.dart';

class SemanticAnalyzer {
  SemanticAnalyzer(this.reporter) : symbolTable = SymbolTable(reporter);

  final ErrorReporter reporter;
  final SymbolTable symbolTable;

  void analyze(DocumentNode ast) {
    final symbolTableVisitor = SymbolTableVisitor(symbolTable, reporter);
    ast.accept(symbolTableVisitor);

    final typeCheckingVisitor = TypeCheckingVisitor(symbolTable, reporter);
    ast.accept(typeCheckingVisitor);
  }
}
