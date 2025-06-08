// ignore_for_file: avoid_print

import '../../ast_visitor.dart';
import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';
import '../rules/semantic_rule.dart';
import '../semantic_types.dart';
import '../symbol_table.dart';

class TypeCheckingVisitor implements AstVisitor<void> {
  TypeCheckingVisitor(this._symbolTable, this._reporter)
    : _rules = [
        NoDuplicateDeclarationsRule(_reporter, _symbolTable),
        NoUndefinedSymbolsRule(_reporter, _symbolTable),
      ];

  final SymbolTable _symbolTable;
  final ErrorReporter _reporter;
  final List<SemanticRule> _rules;

  void _applyRules(AstNode node) {
    for (final rule in _rules) {
      rule.check(node);
    }
  }

  SemanticType? _getSemanticType(TypeNode astTypeNode) {
    switch (astTypeNode) {
      case BaseTypeNode(:final value):
        final type = BaseType.byName[value];

        if (type == null) {
          _reporter.reportError(
            'Unknown base type: $value',
            astTypeNode.span,
          );
          return null;
        }

        return type;
      case CustomTypeNode(:final value):
        final _ = _symbolTable.lookup(value, astTypeNode.span);

      case _:
        // For custom types, lists, maps, sets, streams, and void,
        // we will handle them in their respective visit methods.
        break;
    }

    if (astTypeNode is BaseTypeNode) {
      return BaseType.values.firstWhere(
        (t) => t.name == astTypeNode.value,
        orElse: () {
          _reporter.reportError(
            'Unknown base type: ${astTypeNode.value}',
            astTypeNode.span,
          );
          throw ArgumentError('Unknown base type: ${astTypeNode.value}');
        },
      );
    } else if (astTypeNode is CustomTypeNode) {
      final entry = _symbolTable.lookup(astTypeNode.value, astTypeNode.span);
      // lookup will report an error if not found.
      // If found, ensure it's a type definition (struct, enum, typedef).
      if (entry != null) {
        if (entry.resolvedType != null) {
          return entry.resolvedType;
        } else {
          _reporter.reportError(
            'Internal error: Semantic type not resolved for '
            '"${astTypeNode.value}"',
            astTypeNode.span,
          );
        }
      }
      return null;
    } else if (astTypeNode is ListTypeNode) {
      final elementType = _getSemanticType(astTypeNode.elementType);

      return elementType != null ? ListType(elementType) : null;
    } else if (astTypeNode is MapTypeNode) {
      final keyType = _getSemanticType(astTypeNode.keyType);
      final valueType = _getSemanticType(astTypeNode.valueType);

      return (keyType != null && valueType != null)
          ? MapType(keyType, valueType)
          : null;
    } else if (astTypeNode is SetTypeNode) {
      final elementType = _getSemanticType(astTypeNode.elementType);

      return elementType != null ? SetType(elementType) : null;
    } else if (astTypeNode is StreamTypeNode) {
      final innerType = _getSemanticType(astTypeNode.elementType);

      return innerType != null ? StreamType(innerType) : null;
    } else if (astTypeNode is VoidTypeNode) {
      return BaseType.voidT;
    }

    _reporter.reportError(
      'Unknown type node kind: ${astTypeNode.runtimeType}',
      astTypeNode.span,
    );

    return null;
  }

  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {
    _applyRules(node);

    for (final header in node.headers) {
      header.accept(this);
    }

    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {
    _applyRules(node);
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    _applyRules(node);
  }

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _applyRules(node);

    node.value.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _applyRules(node);

    node.type.accept(this);

    final entry = _symbolTable.lookup(node.identifier.value, node.span);
    if (entry != null && entry.resolvedType is TypedefType) {
      final typedefType = entry.resolvedType! as TypedefType;
      final targetType = _getSemanticType(node.type);

      if (targetType != null) {
        typedefType.setTargetType(targetType);
      }
    }
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {}

  @override
  void visitEnumValueNode(EnumValueNode node) {}

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {}

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {}

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {}

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {}

  @override
  void visitFieldNode(FieldNode node) {}

  @override
  void visitFunctionNode(FunctionNode node) {}

  // Type nodes

  @override
  void visitBaseTypeNode(BaseTypeNode node) {
    _applyRules(node);
  }

  @override
  void visitMapTypeNode(MapTypeNode node) {
    _applyRules(node);

    node.keyType.accept(this);
    node.valueType.accept(this);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    _applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    _applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    _applyRules(node);

    node.elementType.accept(this);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {
    _applyRules(node);
  }

  @override
  void visitVoidTypeNode(VoidTypeNode node) {
    _applyRules(node);
  }

  // Constant value nodes

  @override
  void visitIntConstantNode(IntConstantNode node) {}

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) {}

  @override
  void visitLiteralNode(LiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitConstListNode(ConstListNode node) {}

  @override
  void visitConstMapNode(ConstMapNode node) {}
}
