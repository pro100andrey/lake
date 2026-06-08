import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

// A rule that checks if an enum definition is non-empty.
///
/// This rule ensures that all [EnumDefinitionNode]s contain at least one
/// member, preventing the declaration of empty enums which are typically
/// invalid or semantically meaningless.
final class NonEmptyEnumDefinitionRule extends BaseRule<EnumDefinitionNode> {
  /// Creates a [NonEmptyEnumDefinitionRule] with the given error [reporter].
  const NonEmptyEnumDefinitionRule({required super.reporter});

  @override
  void check(EnumDefinitionNode node) {
    if (node.members.isEmpty) {
      reporter.reportEmptyEnumDefinition(
        startOffset: node.startOffset,
        endOffset: node.endOffset,
      );
    }
  }
}
