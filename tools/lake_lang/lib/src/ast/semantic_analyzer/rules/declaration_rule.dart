import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';

sealed class DeclarationRule {
  const DeclarationRule(this.reporter);

  final ErrorReporter reporter;

  void check(AstNode node);
}

final class ConstValueBasicTypeRule extends DeclarationRule {
  const ConstValueBasicTypeRule(super.reporter);

  @override
  void check(covariant ConstDefinitionNode node) {
    if (node.type case BaseTypeNode(isBase: true, :final value)) {
      final check = _expectedCheck[value];
      final valueType = _getTypeName(node.value);

      if (check != null && !check(node.value)) {
        reporter.reportValueCannotBeAssigned(
          valueType,
          value,
          node.value.span,
        );
      }
    }
  }
}

String _getTypeName(ConstValueNode node) => switch (node) {
  IntConstantNode() => 'int',
  DoubleConstantNode() => 'double',
  BoolConstantNode() => 'bool',
  LiteralNode() => 'string',
  IdentifierNode() => 'identifier',
  _ => 'unknown',
};

final Map<String, bool Function(ConstValueNode)> _expectedCheck = {
  'bool': (v) => v.isBool,
  'string': (v) => v.isLiteral,
  'double': (v) => v.isDouble,
  'byte': (v) => v.isInt,
  'i8': (v) => v.isInt,
  'i16': (v) => v.isInt,
  'i32': (v) => v.isInt,
  'i64': (v) => v.isInt,
};
