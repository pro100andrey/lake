import '../../ast_visitor.dart';
import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';
import '../symbol_table.dart';

class SymbolTableVisitor extends AstVisitor<void> {
  SymbolTableVisitor(this._symbolTable, this._reporter);

  final SymbolTable _symbolTable;
  final ErrorReporter _reporter;

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
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    _symbolTable.addSymbol(node.identifier.value, node, node.span);

    node.type.accept(this);
    node.value.accept(this);
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    _symbolTable.addSymbol(node.identifier.value, node, node.span);

    node.type.accept(this);
  }

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {
    _symbolTable
      ..addSymbol(node.identifier.value, node, node.span)
      ..pushScope();

    for (final value in node.values) {
      value.accept(this);
    }

    _symbolTable.popScope();
  }

  @override
  void visitEnumValueNode(EnumValueNode node) {
    _symbolTable.addSymbol(node.identifier.value, node, node.span);
    node.value?.accept(this);
  }

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {
    _symbolTable
      ..addSymbol(node.identifier.value, node, node.span)
      ..pushScope();

    for (final field in node.fields) {
      field.accept(this);
    }

    _symbolTable.popScope();
  }

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {
    _symbolTable
      ..addSymbol(node.identifier.value, node, node.span)
      ..pushScope();

    for (final field in node.fields) {
      field.accept(this);
    }

    _symbolTable.popScope();
  }

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {
    _symbolTable
      ..addSymbol(node.identifier.value, node, node.span)
      ..pushScope();

    if (node.extendsService != null) {
      node.extendsService!.accept(this);
    }

    for (final method in node.functions) {
      method.accept(this);
    }

    _symbolTable.popScope();
  }

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {}

  @override
  void visitFieldNode(FieldNode node) {
    node.type.accept(this);
    node.defaultValue?.accept(this);
    node.requirement?.accept(this);
  }

  @override
  void visitFunctionNode(FunctionNode node) {
    _symbolTable
      ..addSymbol(node.identifier.value, node, node.span)
      ..pushScope();

    node.returnType.accept(this);

    for (final param in node.parameters) {
      _symbolTable.addSymbol(param.identifier.value, param, param.span);
      param.type.accept(this);
    }

    for (final th in node.throws) {
      th.type.accept(this);
    }

    _symbolTable.popScope();
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
  void visitConstListNode(ConstListNode node) {
    for (final element in node.elements) {
      element.accept(this);
    }
  }

  @override
  void visitConstMapNode(ConstMapNode node) {
    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
  }
}
