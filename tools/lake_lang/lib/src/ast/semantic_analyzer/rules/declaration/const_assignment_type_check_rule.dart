import '../../../nodes/ast_nodes.dart';
import '../base_rule.dart';

/// A semantic rule that checks whether constant values are assignable
/// to their declared primitive types (e.g., `i32`, `bool`, `string`, etc.).
final class ConstAssignmentTypeCheckRule extends BaseRule {
  /// Creates a rule that checks constant values against base types.
  const ConstAssignmentTypeCheckRule(super.reporter);

  @override
  void check(covariant ConstDefinitionNode node) {
    if (node.type case BaseTypeNode(:final value)) {
      final check = _expectedCheck[value];

      if (check != null && !check(node.value)) {
        reporter.reportValueCannotBeAssigned(
          node.value.valueType,
          node.value.valueKind,
          value,
          node.value.span,
        );
      }
    }
  }
}

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
