import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

final class NonEmptyEnumDefinitionRule extends BaseRule<EnumDefinitionNode> {
  /// Creates a rule that checks if an enum definition is non-empty.
  const NonEmptyEnumDefinitionRule(super.reporter);

  @override
  void check(EnumDefinitionNode node) {
    if (node.members.isEmpty) {
      reporter.reportEmptyEnumDefinition(node.span);
    }
  }
}
