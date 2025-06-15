import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';
import '../utils.dart';

/// A private base rule that checks if a constant's value is compatible
/// with its declared **base (primitive) type**.
///
/// This rule handles types like `i32`, `bool`, `string`, `double`, etc.
/// It uses the `_expectedCheck` map to determine type compatibility.
final class _BaseTypeRule extends BaseRule<ConstDefinitionNode> {
  /// Creates a rule that checks constant values against base types.
  const _BaseTypeRule({required super.reporter});

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
final class _ListTypeRule extends BaseRule<ConstDefinitionNode> {
  const _ListTypeRule({required super.reporter});

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

final class _MapTypeRule extends BaseRule<ConstDefinitionNode> {
  const _MapTypeRule({required super.reporter});

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
final class ConstAssignmentTypeRule extends BaseRule<ConstDefinitionNode> {
  /// Creates a rule that checks constant values against base types.
  ConstAssignmentTypeRule({required super.reporter});

  late final _baseTypeRule = _BaseTypeRule(reporter: reporter);
  late final _listTypeRule = _ListTypeRule(reporter: reporter);
  late final _mapTypeRule = _MapTypeRule(reporter: reporter);

  @override
  void check(ConstDefinitionNode node) {
    // If the node is an identifier, skip type checking.
    // This is because identifiers are resolved separately and do not
    // have a value at this point in the analysis.
    if (node.value is IdentifierNode) {
      return;
    }

    _baseTypeRule.check(node);
    _listTypeRule.check(node);
    _mapTypeRule.check(node);
  }
}
