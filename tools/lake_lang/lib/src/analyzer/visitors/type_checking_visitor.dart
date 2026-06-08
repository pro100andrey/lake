import '../../ast/ast_visitor.dart';
import '../../parser/ast/ast_base.dart';
import '../errors/error_reporter.dart';

import '../rules/type_checking/const_identifier_resolution_rule.dart';
import '../rules/type_checking/service_extends_resolution_rule.dart';
import '../rules/type_checking/service_method_throws_rule.dart';
import '../semantic_types.dart';
import '../symbols/symbol_table.dart';
import '../utils.dart';

class TypeCheckingVisitor implements AstVisitor<void> {
  TypeCheckingVisitor(this._symbolTable, this._reporter) {
    _constIdentifierResolutionRule = ConstIdentifierResolutionRule(
      reporter: _reporter,
      symbolTable: _symbolTable,
    );
    _serviceExtendsResolutionRule = ServiceExtendsResolutionRule(
      reporter: _reporter,
      symbolTable: _symbolTable,
    );
    _serviceMethodThrowsRule = ServiceMethodThrowsRule(
      reporter: _reporter,
      symbolTable: _symbolTable,
    );
  }

  final SymbolTable _symbolTable;
  final ErrorReporter _reporter;

  late final ConstIdentifierResolutionRule _constIdentifierResolutionRule;
  late final ServiceExtendsResolutionRule _serviceExtendsResolutionRule;
  late final ServiceMethodThrowsRule _serviceMethodThrowsRule;

  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {
    for (final header in node.headers) {
      header.accept(this);
    }

    for (final definition in node.definitions) {
      definition.accept(this);
    }
  }

  @override
  void visitImportNode(ImportNode node) {}

  @override
  void visitNamespaceNode(NamespaceNode node) {}

  @override
  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _constIdentifierResolutionRule.check(node);
    node.type.accept(this);
    node.value.accept(this);

    final targetType = getSemanticType(node.type, _reporter, _symbolTable);
    final entry = _symbolTable.lookup(node.identifier.name, node);
    if (entry != null) {
      entry.resolvedType = targetType;
    }
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    node.type.accept(this);

    final entry = _symbolTable.lookup(node.identifier.name, node);

    if (entry != null && entry.resolvedType is TypedefType) {
      final typedefSemanticType = entry.resolvedType!.cast<TypedefType>();
      final targetType = getSemanticType(node.type, _reporter, _symbolTable);

      if (targetType != null) {
        typedefSemanticType.targetType = targetType;
      }
    }
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    for (final member in node.members) {
      member.accept(this);
    }
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    node.value?.accept(this);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    for (final field in node.fields) {
      field.accept(this);
    }
  }

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {
    for (final field in node.fields) {
      field.accept(this);
    }
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    for (final field in node.fields) {
      field.accept(this);
    }
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _serviceExtendsResolutionRule.check(node);

    node.extendsService?.accept(this);
    for (final method in node.methods) {
      method.accept(this);
    }
  }

  @override
  void visitFieldNode(FieldNode node) {
    final fieldSemanticType = getSemanticType(
      node.type,
      _reporter,
      _symbolTable,
    );

    if (node.defaultValue != null && fieldSemanticType != null) {
      final defaultValueSemanticType = getLiteralValueSemanticType(
        node.defaultValue!,
        _reporter,
        _symbolTable,
      );

      if (defaultValueSemanticType != null) {
        if (!defaultValueSemanticType.isAssignableTo(fieldSemanticType)) {
          _reporter.reportLiteralValueCannotBeAssigned(
            literalTypeName: fieldSemanticType.name,
            valueKindName: 'default value',
            valueTypeName: defaultValueSemanticType.name,
            startOffset: node.defaultValue!.startOffset,
            endOffset: node.defaultValue!.endOffset,
            literalTypeStart: node.type.startOffset,
            literalTypeEnd: node.type.endOffset,
          );
        }
      }
    }

    node.type.accept(this);
  }

  @override
  void visitMethodNode(MethodNode node) {
    _serviceMethodThrowsRule.check(node);

    getSemanticType(node.returnType, _reporter, _symbolTable);
    node.returnType.accept(this);

    for (final parameter in node.parameters) {
      parameter.accept(this);
    }

    for (final throwType in node.throws) {
      throwType.accept(this);
    }
  }

  // Type nodes

  @override
  void visitBaseTypeNode(BaseTypeNode node) {}

  @override
  void visitMapTypeNode(MapTypeNode node) {
    node.keyType.accept(this);
    node.valueType.accept(this);
  }

  @override
  void visitSetTypeNode(SetTypeNode node) {
    node.elementType.accept(this);
  }

  @override
  void visitListTypeNode(ListTypeNode node) {
    node.elementType.accept(this);
  }

  @override
  void visitStreamTypeNode(StreamTypeNode node) {
    node.elementType.accept(this);
  }

  @override
  void visitCustomTypeNode(CustomTypeNode node) {}

  @override
  void visitVoidTypeNode(VoidTypeNode node) {}

  // Literal value nodes

  @override
  void visitIntLiteralNode(IntLiteralNode node) {}

  @override
  void visitDoubleLiteralNode(DoubleLiteralNode node) {}

  @override
  void visitBoolLiteralNode(BoolLiteralNode node) {}

  @override
  void visitStringLiteralNode(StringLiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitListLiteralNode(ListLiteralNode node) {}

  @override
  void visitMapLiteralNode(MapLiteralNode node) {
    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
  }
}
