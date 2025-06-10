import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

abstract class _TypeCheckRule extends BaseRule<ConstDefinitionNode> {
  const _TypeCheckRule(super.reporter);

  @override
  void check(ConstDefinitionNode node) {
    // Skip identifiers (resolved elsewhere).
    if (node.value case IdentifierNode()) {
      return;
    }

    checkType(node);
  }

  void checkType(ConstDefinitionNode node);
}

final class _BaseTypeCheckRule extends _TypeCheckRule {
  /// Creates a rule that checks constant values against base types.
  const _BaseTypeCheckRule(super.reporter);

  @override
  void checkType(ConstDefinitionNode node) {
    if ((node.type, node.value) case (
      BaseTypeNode(value: final value),
      ConstValueNode(:final valueKind, :final valueType, :final span),
    )) {
      final check = _expectedCheck[value];

      if (check != null && !check(node.value)) {
        reporter.reportValueCannotBeAssigned(
          constTypeName: value,
          valueKindName: valueKind,
          valueSpan: span,
          valueTypeName: valueType,
          constTypeSpan: node.type.span,
        );
      }
    }
  }
}

/// Checks constant values against list types (e.g., list<i32>).
final class _ListTypeCheckRule extends _TypeCheckRule {
  const _ListTypeCheckRule(super.reporter);

  @override
  void checkType(ConstDefinitionNode node) {
    if ((node.type, node.value) case (
      ListTypeNode(:final elementType),
      ConstListNode(:final elements),
    )) {
      if (elementType case BaseTypeNode(:final value)) {
        for (final element in elements) {
          if (element is IdentifierNode) {
            // Skip identifiers in constant list elements for now.
            // Their type compatibility will be checked in TypeCheckingVisitor.
            continue;
          }

          final check = _expectedCheck[value];
          if (check != null && !check(element)) {
            reporter.reportListElementTypeMismatch(
              // (e.g., 'i32')
              expectedType: value,
              // (e.g., 'integer', 'string', etc.)
              actualType: element.valueType,
              span: element.span,
            );
          }
        }
      } else {
        reporter.reportUnsupportedListElementType(
          _typeName(elementType),
          node.type.span,
        );
      }
    }
  }
}

/// A semantic rule that checks whether constant values are assignable
/// to their declared primitive types (e.g., `i32`, `bool`, `string`, etc.).
final class ConstAssignmentTypeCheckRule extends BaseRule<ConstDefinitionNode> {
  /// Creates a rule that checks constant values against base types.
  ConstAssignmentTypeCheckRule(super.reporter);

  late final _baseTypeCheckRule = _BaseTypeCheckRule(reporter);
  late final _listTypeCheckRule = _ListTypeCheckRule(reporter);

  @override
  void check(ConstDefinitionNode node) {
    // If the node is an identifier, skip type checking.
    // This is because identifiers are resolved separately and do not
    // have a value at this point in the analysis.
    if (node.value is IdentifierNode) {
      return;
    }

    _baseTypeCheckRule.check(node);
    _listTypeCheckRule.check(node);
  }
}

String _typeName(TypeNode type) => switch (type) {
  BaseTypeNode(:final value) => value,
  ListTypeNode(:final elementType) => 'list<${_typeName(elementType)}>',
  _ => 'unknown',
};

/// A mapping from base type names (e.g., `i32`, `bool`) to validation
/// functions that determine whether a [ConstValueNode] is compatible.
///
/// These functions are used to verify type correctness of constant values.
final Map<String, bool Function(ConstValueNode)> _expectedCheck = {
  'bool': (v) => v is BoolConstantNode,
  'string': (v) => v is LiteralNode,
  'double': (v) => v is DoubleConstantNode,
  'byte': (v) => v is IntConstantNode,
  'i8': (v) => v is IntConstantNode,
  'i16': (v) => v is IntConstantNode,
  'i32': (v) => v is IntConstantNode,
  'i64': (v) => v is IntConstantNode,
};
