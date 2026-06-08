import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// A rule that checks if a struct definition is non-empty.
///
/// This rule ensures that all [StructDefinitionNode]s contain at least one
/// field, preventing the declaration of empty structs which are typically
/// invalid or semantically meaningless.
final class NonEmptyStructDefinitionRule
    extends BaseRule<StructDefinitionNode> {
  /// Creates a [NonEmptyStructDefinitionRule] with the given error [reporter].
  const NonEmptyStructDefinitionRule({required super.reporter});

  @override
  void check(StructDefinitionNode node) {
    if (node.fields.isEmpty) {
      reporter.reportEmptyStructDefinition(span: node.span);
    }
  }
}
