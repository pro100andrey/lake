import '../../ast/nodes/ast_nodes.dart';
import '../diagnostics/diagnostic_system.dart';
import '../diagnostics/diagnostics.dart';
import '../semantic_types.dart';
import '../symbols/symbol_table.dart';

SemanticType? getSemanticType(
  TypeNode typeNode,
  DiagnosticSystem diagnosticSystem,
  SymbolTable symbolTable,
) {
  if (typeNode case BaseTypeNode(:final value, :final span)) {
    final type = BaseType.byName[value];

    if (type == null) {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Unknown base type: $value',
          span: span,
          filePath: '<file_path>',
        ),
      );
    }

    return type;
  }

  if (typeNode case CustomTypeNode(:final value, :final span)) {
    final entry = symbolTable.lookup(value, span);

    if (entry?.declaration != null) {
      return entry!.resolvedType;
    } else {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Unknown custom type: $value',
          span: span,
          filePath: '<file_path>',
        ),
      );
    }

    return entry?.resolvedType;
  }

  if (typeNode case ListTypeNode(:final elementType, :final span)) {
    final elementSemanticType = getSemanticType(
      elementType,
      diagnosticSystem,
      symbolTable,
    );

    if (elementSemanticType == null) {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Invalid element type in list',
          span: span,
          filePath: '<file_path>',
        ),
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
      diagnosticSystem,
      symbolTable,
    );

    final valueSemanticType = getSemanticType(
      valueType,
      diagnosticSystem,
      symbolTable,
    );

    if (keySemanticType == null) {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Invalid key type in map',
          span: span,
          filePath: '<file_path>',
        ),
      );
    }

    if (valueSemanticType == null) {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Invalid value type in map',
          span: span,
          filePath: '<file_path>',
        ),
      );
    }

    if (keySemanticType == null || valueSemanticType == null) {
      return null;
    }

    return MapType(keySemanticType, valueSemanticType);
  }

  if (typeNode case SetTypeNode(:final elementType, :final span)) {
    final elementSemanticType = getSemanticType(
      elementType,
      diagnosticSystem,
      symbolTable,
    );

    if (elementSemanticType == null) {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Invalid element type in set',
          span: span,
          filePath: '<file_path>',
        ),
      );

      return null;
    }

    return SetType(elementSemanticType);
  }

  if (typeNode case StreamTypeNode(:final elementType, :final span)) {
    final elementSemanticType = getSemanticType(
      elementType,
      diagnosticSystem,
      symbolTable,
    );

    if (elementSemanticType == null) {
      diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Invalid element type in stream',
          span: span,
          filePath: '<file_path>',
        ),
      );

      return null;
    }

    return StreamType(elementSemanticType);
  }

  if (typeNode case VoidTypeNode()) {
    return const VoidType();
  }

  diagnosticSystem.report(
    GenericDiagnostic(
      message: 'Unsupported type node: ${typeNode.runtimeType}',
      span: typeNode.span,
      filePath: '<file_path>',
    ),
  );

  return null;
}

SemanticType? getLiteralValueSemanticType(
  LiteralValueNode node,
  DiagnosticSystem diagnosticSystem,
  SymbolTable symbolTable,
) {
  if (node case IntLiteralNode()) {
    // Assuming all integer literals default to i64, or determine based on
    //value range.
    return BaseType.byName[node.valueType];
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

  if (node case IdentifierNode(:final value, :final span)) {
    // This handles cases like `const double PI_APPROXIMATION = PI;`
    final symbolEntry = symbolTable.lookup(value, span);

    if (symbolEntry == null) {
      // Error already reported by symbolTable.lookup
      return null;
    }

    // The resolvedType for literals is set by SymbolTableVisitor.
    return symbolEntry.resolvedType;
  }

  if (node case ListLiteralNode(:final elements, :final span)) {
    final _ = span;

    if (elements.isEmpty) {
      return ListType(const VoidType());
    }
    // Infer common element type for non-empty lists
    SemanticType? commonElementType;

    for (final element in elements) {
      final elementType = getLiteralValueSemanticType(
        element,
        diagnosticSystem,
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
        diagnosticSystem.report(
          GenericDiagnostic(
            message:
                'Inconsistent types in list literal. '
                'Expected ${commonElementType.name}, got ${elementType.name}.',
            span: element.span,
            filePath: '<file_path>',
          ),
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
