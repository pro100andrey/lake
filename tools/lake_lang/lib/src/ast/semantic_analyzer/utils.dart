import '../nodes/ast_nodes.dart';
import 'error_reporter.dart';
import 'semantic_error.dart';
import 'semantic_types.dart';
import 'symbol_table.dart';

SemanticType? getSemanticType(
  TypeNode typeNode,
  ErrorReporter reporter,
  SymbolTable symbolTable,
) {
  if (typeNode case BaseTypeNode(:final value, :final span)) {
    final type = BaseType.byName[value];

    if (type == null) {
      reporter.report(
        GenericSemanticError('Unknown base type: $value', span),
      );
    }

    return type;
  }

  if (typeNode case CustomTypeNode(:final value, :final span)) {
    final entry = symbolTable.lookup(value, span);

    if (entry?.declaration != null) {
      return entry!.resolvedType;
    } else {
      reporter.report(
        GenericSemanticError('Unknown custom type: $value', span),
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
      reporter.report(
        GenericSemanticError('Invalid element type in list', span),
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
      reporter.report(
        GenericSemanticError('Invalid key type in map', span),
      );
    }

    if (valueSemanticType == null) {
      reporter.report(
        GenericSemanticError('Invalid value type in map', span),
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
      reporter,
      symbolTable,
    );

    if (elementSemanticType == null) {
      reporter.report(
        GenericSemanticError('Invalid element type in set', span),
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
      reporter.report(
        GenericSemanticError('Invalid element type in stream', span),
      );

      return null;
    }

    return StreamType(elementSemanticType);
  }

  if (typeNode case VoidTypeNode()) {
    return const VoidType();
  }

  reporter.report(
    GenericSemanticError(
      'Cannot resolve semantic type for AST node of type '
      '${typeNode.runtimeType}',
      typeNode.span,
    ),
  );

  return null;
}
