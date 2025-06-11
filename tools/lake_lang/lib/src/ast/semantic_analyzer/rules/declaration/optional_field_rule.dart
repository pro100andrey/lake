import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';
import '../utils.dart';

final class _BaseTypeCheckRule extends BaseRule<FieldNode> {
  /// Creates a rule that checks constant values against base types.
  const _BaseTypeCheckRule(super.reporter);

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

final class OptionalFiledCheckRule extends BaseRule<FieldNode> {
  /// Creates a [OptionalFiledCheckRule] with the given error [reporter].
  OptionalFiledCheckRule(super.reporter);

  late final _baseTypeCheckRule = _BaseTypeCheckRule(reporter);

  @override
  void check(FieldNode node) {
    if (node.requirement case FieldRequirementNode(isRequired: false)) {
      _baseTypeCheckRule.check(node);
    }
  }
}
