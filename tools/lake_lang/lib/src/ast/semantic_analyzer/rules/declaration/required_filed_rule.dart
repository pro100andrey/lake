import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// A rule that checks if a field is required and does not have a default value.
// This rule is used to ensure that fields marked as `required` do not
// also have a default value, which would contradict the semantics of
// the language.
final class RequiredFiledRule extends BaseRule<FieldNode> {
  /// Creates a [RequiredFiledRule] with the given error [reporter].
  const RequiredFiledRule(super.reporter);

  @override
  void check(FieldNode node) {
    if (node.requirement case FieldRequirementNode(
      isRequired: true,
      :final span,
    )) {
      if (node.defaultValue != null) {
        reporter.reportRequiredFieldCannotHaveDefaultValue(
          fieldName: node.identifier.value,
          span: span,
        );
      }
    }
  }
}
