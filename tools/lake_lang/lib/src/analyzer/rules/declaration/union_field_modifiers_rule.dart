import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// Rule that ensures fields within a union are not marked as 'required'
/// and do not have default values.
class UnionFieldModifiersRule extends BaseRule<UnionDefinitionNode> {
  const UnionFieldModifiersRule({required super.reporter});

  @override
  void check(UnionDefinitionNode node) {
    for (final field in node.fields) {
      if (field.isRequired || field.defaultValue != null) {
        reporter.reportInvalidUnionFieldModifier(
          startOffset: field.startOffset,
          endOffset: field.endOffset,
        );
      }
    }
  }
}
