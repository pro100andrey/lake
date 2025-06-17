import '../../../ast/nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';
import '../utils.dart';

final class _BaseTypeRule extends BaseRule<FieldNode> {
  /// Creates a rule that checks constant values against base types.
  const _BaseTypeRule({required super.reporter});

  @override
  void check(FieldNode node) {
    if ((node.type, node.defaultValue) case (
      BaseTypeNode(value: final constTypeName),
      ConstValueNode(:final valueKind, :final valueType, :final span),
    )) {
      if (!isConstValueCompatibleWithBaseType(
        constTypeName,
        node.defaultValue!,
      )) {
        reporter.reportConstValueCannotBeAssigned(
          constTypeName: constTypeName,
          valueKindName: valueKind,
          valueSpan: span,
          valueTypeName: valueType,
          constTypeSpan: node.type.span,
        );
      }
    }
  }
}

final class OptionalFieldRule extends BaseRule<FieldNode> {
  /// Creates a [OptionalFieldRule] with the given error [reporter].
  OptionalFieldRule({required super.reporter});

  late final _baseTypeCheckRule = _BaseTypeRule(reporter: reporter);

  @override
  void check(FieldNode node) {
    if (node.requirement case FieldRequirementNode(isRequired: false)) {
      _baseTypeCheckRule.check(node);
    }
  }
}
