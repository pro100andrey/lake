import '../../ast/nodes/ast_nodes.dart';

/// Helper function to get a string representation of a [TypeNode].
String getTypeName(TypeNode type) => switch (type) {
  BaseTypeNode(:final value) => value,
  ListTypeNode(:final elementType) => 'list<${getTypeName(elementType)}>',
  MapTypeNode(:final keyType, :final valueType) =>
    'map<${getTypeName(keyType)}, ${getTypeName(valueType)}>',
  _ => 'unknown',
};

/// Checks if a given [literalValueNode] is compatible with the
/// [expectedType].
///
/// Returns `true` if the value is compatible or if there's no specific check
/// defined for the expected type. Returns `false` if a check exists and the
/// value is not compatible.
bool isLiteralValueCompatibleWithBaseType(
  String expectedType,
  LiteralValueNode literalValueNode,
) {
  final check = _expectedConstValueCheck[expectedType];
  // If no specific check is defined for the declared type, we assume
  // compatibility or that it will be handled by a more specific rule
  //(e.g., custom types). If a check exists, we return the result of that check.
  return check == null || check(literalValueNode);
}

/// A mapping from base type names (e.g., `i32`, `bool`) to validation
/// functions that determine whether a [LiteralValueNode] is compatible with
/// that type.
final Map<String, bool Function(LiteralValueNode)> _expectedConstValueCheck = {
  'bool': (v) => v is BoolLiteralNode,
  'string': (v) => v is StringLiteralNode,
  'double': (v) => v is DoubleLiteralNode,
  'byte': (v) => v is IntLiteralNode,
  'i8': (v) => v is IntLiteralNode,
  'i16': (v) => v is IntLiteralNode,
  'i32': (v) => v is IntLiteralNode,
  'i64': (v) => v is IntLiteralNode,
};
