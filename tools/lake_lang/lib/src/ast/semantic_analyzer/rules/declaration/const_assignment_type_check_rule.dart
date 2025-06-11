import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// A private base rule that checks if a constant's value is compatible
/// with its declared **base (primitive) type**.
///
/// This rule handles types like `i32`, `bool`, `string`, `double`, etc.
/// It uses the `_expectedCheck` map to determine type compatibility.
final class _BaseTypeCheckRule extends BaseRule<ConstDefinitionNode> {
  /// Creates a rule that checks constant values against base types.
  const _BaseTypeCheckRule(super.reporter);

  @override
  void check(ConstDefinitionNode node) {
    if ((node.type, node.value) case (
      BaseTypeNode(value: final value),
      ConstValueNode(:final valueKind, :final valueType, :final span),
    )) {
      final check = _expectedCheck[value];

      if (check != null && !check(node.value)) {
        reporter.reportConstValueCannotBeAssigned(
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

/// A private rule that checks constant values against **list types**
/// (e.g., `list<i32>`).
///
/// It ensures that all elements within a constant list literal are compatible
/// with the list's declared element type. It also checks if the list's element
/// type is supported (e.g., only primitive types are allowed for now).
final class _ListTypeCheckRule extends BaseRule<ConstDefinitionNode> {
  const _ListTypeCheckRule(super.reporter);

  @override
  void check(ConstDefinitionNode node) {
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
/// to their declared types (e.g., `i32`, `bool`, `string`, `list<i32>`, etc.).
///
/// This rule dispatches to specialized sub-rules (`_BaseTypeCheckRule` and
/// `_ListTypeCheckRule`) to handle different constant type definitions.
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

/// Helper function to get a string representation of a [TypeNode].
///
/// This is used to generate human-readable type names for error messages.
String _typeName(TypeNode type) => switch (type) {
  BaseTypeNode(:final value) => value,
  ListTypeNode(:final elementType) => 'list<${_typeName(elementType)}>',
  _ => 'unknown',
};

/// A mapping from base type names (e.g., `i32`, `bool`) to validation
/// functions that determine whether a [ConstValueNode] is compatible with that
/// type.
///
/// These functions are used by [_BaseTypeCheckRule] and [_ListTypeCheckRule]
/// to verify the type correctness of constant values during semantic analysis.
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
