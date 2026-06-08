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
      LiteralValueNode(),
    )) {
      if (!isLiteralValueCompatibleWithBaseType(
        literalTypeName,
        node.defaultValue!,
      )) {
        reporter.reportLiteralValueCannotBeAssigned(
          literalTypeName: literalTypeName,
          valueKindName: 'default value',
          startOffset: node.defaultValue!.startOffset,
          endOffset: node.defaultValue!.endOffset,
          valueTypeName: node.defaultValue!.runtimeType.toString(),
          literalTypeStart: node.type.startOffset,
          literalTypeEnd: node.type.endOffset,
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
