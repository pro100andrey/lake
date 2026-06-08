import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';
import '../utils.dart';

/// A private base rule that checks if a constant's value is compatible
/// with its declared **base (primitive) type**.
///
/// This rule handles types like `i32`, `bool`, `string`, `double`, etc.
/// It uses the `_expectedCheck` map to determine type compatibility.
final class _BaseTypeRule extends BaseRule<ConstDefinitionNode> {
  /// Creates a rule that checks literal values against base types.
  const _BaseTypeRule({required super.reporter});

  @override
  void check(ConstDefinitionNode node) {
    if ((node.type, node.value) case (
      BaseTypeNode(name: final constTypeName),
      LiteralValueNode(:final span),
    )) {
      if (!isLiteralValueCompatibleWithBaseType(constTypeName, node.value)) {
        reporter.reportLiteralValueCannotBeAssigned(
          literalTypeName: constTypeName,
          valueKindName: 'literal',
          valueSpan: span,
          valueTypeName: node.value.runtimeType.toString(),
          literalTypeSpan: node.type.span,
        );
      }
    }
  }
}

/// A private rule that checks literal values against **list types**
/// (e.g., `list<i32>`).
///
/// It ensures that all elements within a literal list are compatible
/// with the list's declared element type. It also checks if the list's element
/// type is supported (e.g., only primitive types are allowed for now).
final class _ListTypeRule extends BaseRule<ConstDefinitionNode> {
  const _ListTypeRule({required super.reporter});

  @override
  void check(ConstDefinitionNode node) {
    if ((node.type, node.value) case (
      ListTypeNode(:final elementType),
      ListLiteralNode(:final elements),
    )) {
      if (elementType case BaseTypeNode(name: final expectedType)) {
        for (final element in elements) {
          if (element is IdentifierNode) {
            // Skip identifiers in list literal elements for now.
            // Their type compatibility will be checked in TypeCheckingVisitor.
            continue;
          }

          if (!isLiteralValueCompatibleWithBaseType(expectedType, element)) {
            reporter.reportListElementTypeMismatch(
              // (e.g., 'i32')
              expectedType: expectedType,
              // (e.g., 'integer', 'string', etc.)
              actualType: element.runtimeType.toString(),
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
      MapLiteralNode(:final entries),
    )) {
      for (final entry in entries) {
        if (!isLiteralValueCompatibleWithBaseType(
          getTypeName(keyType),
          entry.key,
        )) {
          reporter.reportMapValueTypeMismatch(
            expectedType: getTypeName(keyType),
            actualType: entry.key.runtimeType.toString(),
            span: entry.key.span,
          );
        }

        if (!isLiteralValueCompatibleWithBaseType(
          getTypeName(valueType),
          entry.value,
        )) {
          reporter.reportMapValueTypeMismatch(
            expectedType: getTypeName(valueType),
            actualType: entry.value.runtimeType.toString(),
            span: entry.value.span,
          );
        }
      }
    }
  }
}

/// A semantic rule that checks whether literal values are assignable
/// to their declared types (e.g., `i32`, `bool`, `string`, `list<i32>`, etc.).
///
/// This rule dispatches to specialized sub-rules (`_BaseTypeCheckRule` and
/// `_ListTypeCheckRule`) to handle different literal type definitions.
final class LiteralAssignmentTypeRule extends BaseRule<ConstDefinitionNode> {
  /// Creates a rule that checks literal values against base types.
  LiteralAssignmentTypeRule({required super.reporter});

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
