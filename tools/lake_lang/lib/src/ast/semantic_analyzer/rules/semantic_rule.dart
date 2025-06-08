import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';
import '../symbol_table.dart';

sealed class SemanticRule {
  const SemanticRule(this.reporter, this.table);

  final ErrorReporter reporter;
  final SymbolTable table;

  void check(AstNode node);
}

class NoDuplicateDeclarationsRule extends SemanticRule {
  const NoDuplicateDeclarationsRule(super.reporter, super.table);

  @override
  void check(AstNode node) {}
}

class NoUndefinedSymbolsRule extends SemanticRule {
  const NoUndefinedSymbolsRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    switch (node) {
      case CustomTypeNode(:final value):
        final _ = table.lookup(value, node.span);
      case _:
        break;
    }
  }
}
