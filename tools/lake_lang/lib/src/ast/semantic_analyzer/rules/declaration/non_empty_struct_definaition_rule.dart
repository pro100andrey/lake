import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

final class NonEmptyStructDefinitionRule
    extends BaseRule<StructDefinitionNode> {
  /// Creates a rule that checks if a struct definition is non-empty.
  const NonEmptyStructDefinitionRule(super.reporter);

  @override
  void check(StructDefinitionNode node) {
    if (node.fields.isEmpty) {
      reporter.reportEmptyStructDefinition(node.span);
    }
  }
}
