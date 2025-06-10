import '../../../nodes/ast_nodes.dart';
import '../../semantic_error.dart';
import '../base_rule.dart';

final class NonEmptyStructDefinitionRule
    extends BaseRule<StructDefinitionNode> {
  /// Creates a rule that checks if a struct definition is non-empty.
  const NonEmptyStructDefinitionRule(super.reporter);

  @override
  void check(StructDefinitionNode node) {
    if (node.fields.isEmpty) {
      reporter.report(EmptyStructDefinitionError(node.span));
    }
  }
}
