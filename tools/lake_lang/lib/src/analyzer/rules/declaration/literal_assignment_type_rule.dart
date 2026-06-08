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
      LiteralValueNode(),
    )) {
      if (!isLiteralValueCompatibleWithBaseType(constTypeName, node.value)) {
        reporter.reportLiteralValueCannotBeAssigned(
          literalTypeName: constTypeName,
          valueKindName: 'literal',
          startOffset: node.value.startOffset,
          endOffset: node.value.endOffset,
          valueTypeName: node.value.runtimeType.toString(),
          literalTypeStart: node.type.startOffset,
          literalTypeEnd: node.type.endOffset,
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
              startOffset: element.startOffset,
              endOffset: element.endOffset,
            );
          }
        }
      } else {
        reporter.reportUnsupportedListElementType(
          elementType: getTypeName(elementType),
          startOffset: node.type.startOffset,
          endOffset: node.type.endOffset,
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
        final keyTypeName = getTypeName(keyType);

        if (!isLiteralValueCompatibleWithBaseType(keyTypeName, entry.key)) {
          reporter.reportMapValueTypeMismatch(
            expectedType: keyTypeName,
            actualType: entry.key.runtimeType.toString(),
            startOffset: entry.key.startOffset,
            endOffset: entry.key.endOffset,
          );
        }

        final valueTypeName = getTypeName(valueType);

        if (!isLiteralValueCompatibleWithBaseType(valueTypeName, entry.value)) {
          reporter.reportMapValueTypeMismatch(
            expectedType: valueTypeName,
            actualType: entry.value.runtimeType.toString(),
            startOffset: entry.value.startOffset,
            endOffset: entry.value.endOffset,
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
