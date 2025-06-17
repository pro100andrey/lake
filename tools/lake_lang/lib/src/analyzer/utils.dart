import '../ast/nodes/ast_nodes.dart';
import 'errors/error_reporter.dart';
import 'semantic_types.dart';
import 'symbols/symbol_table.dart';

SemanticType? getSemanticType(
  TypeNode typeNode,
  ErrorReporter reporter,
  SymbolTable symbolTable,
) {
  if (typeNode case BaseTypeNode(:final value, :final span)) {
    final type = BaseType.byName[value];

    if (type == null) {
      reporter.reportGeneric(message: 'Unknown base type: $value', span: span);
    }

    return type;
  }

  if (typeNode case CustomTypeNode(:final value, :final span)) {
    final entry = symbolTable.lookup(value, span);

    if (entry?.declaration != null) {
      return entry!.resolvedType;
    } else {
      reporter.reportGeneric(
        message: 'Unknown custom type: $value',
        span: span,
      );
    }

    return entry?.resolvedType;
  }

  if (typeNode case ListTypeNode(:final elementType, :final span)) {
    final elementSemanticType = getSemanticType(
      elementType,
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid element type in list',
        span: span,
      );

      return null;
    }

    return ListType(elementSemanticType);
  }

  if (typeNode case MapTypeNode(
    :final keyType,
    :final valueType,
    :final span,
  )) {
    final keySemanticType = getSemanticType(
      keyType,
      reporter,
      symbolTable,
    );

    final valueSemanticType = getSemanticType(
      valueType,
      reporter,
      symbolTable,
    );

    if (keySemanticType == null) {
      reporter.reportGeneric(message: 'Invalid key type in map', span: span);
    }

    if (valueSemanticType == null) {
      reporter.reportGeneric(message: 'Invalid value type in map', span: span);
    }

    if (keySemanticType == null || valueSemanticType == null) {
      return null;
    }

    return MapType(keySemanticType, valueSemanticType);
  }

  if (typeNode case SetTypeNode(:final elementType, :final span)) {
    final elementSemanticType = getSemanticType(
      elementType,
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid element type in set',
        span: span,
      );

      return null;
    }

    return SetType(elementSemanticType);
  }

  if (typeNode case StreamTypeNode(:final elementType, :final span)) {
    final elementSemanticType = getSemanticType(
      elementType,
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid element type in stream',
        span: span,
      );

      return null;
    }

    return StreamType(elementSemanticType);
  }

  if (typeNode case VoidTypeNode()) {
    return const VoidType();
  }

  reporter.reportGeneric(
    message: 'Unsupported type node: ${typeNode.runtimeType}',
    span: typeNode.span,
  );

  return null;
}

SemanticType? getConstantValueSemanticType(
  ConstValueNode node,
  ErrorReporter reporter,
  SymbolTable symbolTable,
) {
  if (node case IntConstantNode()) {
    // Assuming all integer literals default to i64, or determine based on
    //value range.
    return BaseType.byName[node.valueType];
    // For a more precise check, you'd need to parse the string value
    // and determine if it fits i8, i16, i32, i64. For now, i64 is a safe
    // default.
  }

  if (node case DoubleConstantNode()) {
    return BaseType.doubleT;
  }

  if (node case BoolConstantNode()) {
    return BaseType.boolT;
  }

  if (node case LiteralNode()) {
    // Assuming LiteralNode is for string literals
    return BaseType.stringT;
  }

  if (node case IdentifierNode(:final value, :final span)) {
    // This handles cases like `const double PI_APPROXIMATION = PI;`
    final symbolEntry = symbolTable.lookup(value, span);

    if (symbolEntry == null) {
      // Error already reported by symbolTable.lookup
      return null;
    }

    // The resolvedType for constants is set by SymbolTableVisitor.
    return symbolEntry.resolvedType;
  }

  if (node case ConstListNode(:final elements, :final span)) {
    if (elements.isEmpty) {
      return ListType(const VoidType());
    }
    // Infer common element type for non-empty lists
    SemanticType? commonElementType;

    for (final element in elements) {
      final elementType = getConstantValueSemanticType(
        element,
        reporter,
        symbolTable,
      );

      if (elementType == null) {
        // Error already reported for this element
        return null;
      }

      if (commonElementType == null) {
        commonElementType = elementType;
      } else if (!elementType.isAssignableTo(commonElementType) &&
          !commonElementType.isAssignableTo(elementType)) {
        reporter.reportGeneric(
          message:
              'Inconsistent types in constant list. '
              'Expected ${commonElementType.name}, got ${elementType.name}.',
          span: element.span,
        );

        return null; // Mixed types, cannot infer single type
      }

      if (commonElementType.isAssignableTo(elementType) &&
          !identical(commonElementType, elementType)) {
        commonElementType = elementType;
      }

      return ListType(commonElementType);
    }
  }

  return null;
}
