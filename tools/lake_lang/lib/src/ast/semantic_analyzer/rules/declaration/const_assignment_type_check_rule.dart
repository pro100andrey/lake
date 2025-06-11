import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';
import '../utils.dart';

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
      BaseTypeNode(value: final constTypeName),
      ConstValueNode(:final valueKind, :final valueType, :final span),
    )) {
      if (!isConstValueCompatibleWithBaseType(constTypeName, node.value)) {
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
      if (elementType case BaseTypeNode(value: final expectedType)) {
        for (final element in elements) {
          if (element is IdentifierNode) {
            // Skip identifiers in constant list elements for now.
            // Their type compatibility will be checked in TypeCheckingVisitor.
            continue;
          }

          if (!isConstValueCompatibleWithBaseType(expectedType, element)) {
            reporter.reportListElementTypeMismatch(
              // (e.g., 'i32')
              expectedType: expectedType,
              // (e.g., 'integer', 'string', etc.)
              actualType: element.valueType,
              span: element.span,
            );
          }
        }
      } else {
        reporter.reportUnsupportedListElementType(
          elementType: getTypeName(elementType),
          span: node.type.span,
        );
      }
    }
  }
}

final class _MapTypeCheckRule extends BaseRule<ConstDefinitionNode> {
  const _MapTypeCheckRule(super.reporter);

  @override
  void check(ConstDefinitionNode node) {
    if ((node.type, node.value) case (
      MapTypeNode(:final keyType, :final valueType),
      ConstMapNode(:final entries),
    )) {
      for (final entry in entries) {
        if (!isConstValueCompatibleWithBaseType(
          getTypeName(keyType),
          entry.key,
        )) {
          reporter.reportMapValueTypeMismatch(
            expectedType: getTypeName(keyType),
            actualType: entry.key.valueType,
            span: entry.key.span,
          );
        }

        if (!isConstValueCompatibleWithBaseType(
          getTypeName(valueType),
          entry.value,
        )) {
          reporter.reportMapValueTypeMismatch(
            expectedType: getTypeName(valueType),
            actualType: entry.value.valueType,
            span: entry.value.span,
          );
        }
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

  late final baseTypeCheckRule = _BaseTypeCheckRule(reporter);
  late final listTypeCheckRule = _ListTypeCheckRule(reporter);
  late final mapTypeCheckRule = _MapTypeCheckRule(reporter);

  @override
  void check(ConstDefinitionNode node) {
    // If the node is an identifier, skip type checking.
    // This is because identifiers are resolved separately and do not
    // have a value at this point in the analysis.
    if (node.value is IdentifierNode) {
      return;
    }

    baseTypeCheckRule.check(node);
    listTypeCheckRule.check(node);
    mapTypeCheckRule.check(node);
  }
}
