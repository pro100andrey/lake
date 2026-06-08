import '../parser/ast/ast_base.dart';
import 'errors/error_reporter.dart';
import 'semantic_types.dart';
import 'symbols/symbol_table.dart';

SemanticType? getSemanticType(
  TypeNode typeNode,
  ErrorReporter reporter,
  SymbolTable symbolTable,
) {
  if (typeNode case BaseTypeNode(
    :final name,
    :final startOffset,
    :final endOffset,
  )) {
    final type = BaseType.byName[name];

    if (type == null) {
      reporter.reportGeneric(
        message: 'Unknown base type: $name',
        startOffset: startOffset,
        endOffset: endOffset,
      );
    }

    return type;
  }

  if (typeNode case CustomTypeNode(
    :final name,
    :final startOffset,
    :final endOffset,
  )) {
    final entry = symbolTable.lookup(name, typeNode);

    if (entry?.declaration != null) {
      return entry!.resolvedType;
    } else {
      reporter.reportGeneric(
        message: 'Unknown custom type: $name',
        startOffset: startOffset,
        endOffset: endOffset,
      );
    }

    return entry?.resolvedType;
  }

  if (typeNode case ListTypeNode(
    :final elementType,
    :final startOffset,
    :final endOffset,
  )) {
    final elementSemanticType = getSemanticType(
      elementType,
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid element type in list',
        startOffset: startOffset,
        endOffset: endOffset,
      );

      return null;
    }

    return ListType(elementSemanticType);
  }

  if (typeNode case MapTypeNode(
    :final keyType,
    :final valueType,
    :final startOffset,
    :final endOffset,
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
      reporter.reportGeneric(
        message: 'Invalid key type in map',
        startOffset: startOffset,
        endOffset: endOffset,
      );
    }

    if (valueSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid value type in map',
        startOffset: startOffset,
        endOffset: endOffset,
      );
    }

    if (keySemanticType == null || valueSemanticType == null) {
      return null;
    }

    return MapType(keySemanticType, valueSemanticType);
  }

  if (typeNode case SetTypeNode(
    :final elementType,
    :final startOffset,
    :final endOffset,
  )) {
    final elementSemanticType = getSemanticType(
      elementType,
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid element type in set',
        startOffset: startOffset,
        endOffset: endOffset,
      );

      return null;
    }

    return SetType(elementSemanticType);
  }

  if (typeNode case StreamTypeNode(
    :final elementType,
    :final startOffset,
    :final endOffset,
  )) {
    final elementSemanticType = getSemanticType(
      elementType,
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.reportGeneric(
        message: 'Invalid element type in stream',
        startOffset: startOffset,
        endOffset: endOffset,
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
    startOffset: typeNode.startOffset,
    endOffset: typeNode.endOffset,
  );

  return null;
}

SemanticType? getLiteralValueSemanticType(
  LiteralValueNode node,
  ErrorReporter reporter,
  SymbolTable symbolTable,
) {
  if (node case IntLiteralNode()) {
    // Assuming all integer literals default to i64, or determine based on
    //value range.
    return BaseType.byName['i32'];
    // For a more precise check, you'd need to parse the string value
    // and determine if it fits i8, i16, i32, i64. For now, i64 is a safe
    // default.
  }

  if (node case DoubleLiteralNode()) {
    return BaseType.doubleT;
  }

  if (node case BoolLiteralNode()) {
    return BaseType.boolT;
  }

  if (node case StringLiteralNode()) {
    // Assuming LiteralNode is for string literals
    return BaseType.stringT;
  }

  if (node case IdentifierNode(:final name)) {
    // This handles cases like `const double PI_APPROXIMATION = PI;`
    final symbolEntry = symbolTable.lookup(name, node);

    if (symbolEntry == null) {
      // Error already reported by symbolTable.lookup
      return null;
    }

    // The resolvedType for literals is set by SymbolTableVisitor.
    return symbolEntry.resolvedType;
  }

  if (node case ListLiteralNode(:final elements)) {
    if (elements.isEmpty) {
      return ListType(const VoidType());
    }
    // Infer common element type for non-empty lists
    SemanticType? commonElementType;

    for (final element in elements) {
      final elementType = getLiteralValueSemanticType(
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
              'Inconsistent types in list literal. '
              'Expected ${commonElementType.name}, got ${elementType.name}.',
          startOffset: element.startOffset,
          endOffset: element.endOffset,
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
