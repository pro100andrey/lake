import '../../../nodes/ast_nodes.dart';
import '../../symbols/symbol_table.dart';
import '../base_rule.dart';

abstract class SemanticRule extends BaseRule {
  /// Creates a new semantic rule with the given [reporter] and [table].
  const SemanticRule(super.reporter, this.table);

  final SymbolTable table;

  /// Checks the provided [node] against the rule's logic.
  @override
  void check(AstNode node);
}

final class NoDuplicateDeclarationsRule extends SemanticRule {
  const NoDuplicateDeclarationsRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    throw UnimplementedError(
      'NoDuplicateDeclarationsRule is not implemented yet.',
    );
  }
}

class NoUndefinedSymbolsRule extends SemanticRule {
  const NoUndefinedSymbolsRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    throw UnimplementedError(
      'NoUndefinedSymbolsRule is not implemented yet.',
    );
  }
}
