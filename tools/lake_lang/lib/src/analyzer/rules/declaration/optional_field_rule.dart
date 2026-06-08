import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';
import '../utils.dart';

final class _BaseTypeRule extends BaseRule<FieldNode> {
  /// Creates a rule that checks literal values against base types.
  const _BaseTypeRule({required super.reporter});

  @override
  void check(FieldNode node) {
    if ((node.type, node.defaultValue) case (
      BaseTypeNode(name: final literalTypeName),
      LiteralValueNode(:final span),
    )) {
      if (!isLiteralValueCompatibleWithBaseType(
        literalTypeName,
        node.defaultValue!,
      )) {
        reporter.reportLiteralValueCannotBeAssigned(
          literalTypeName: literalTypeName,
          valueKindName: 'default value',
          valueSpan: span,
          valueTypeName: node.defaultValue!.runtimeType.toString(),
          literalTypeSpan: node.type.span,
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
    if (!node.isRequired) {
      _baseTypeCheckRule.check(node);
    }
  }
}
