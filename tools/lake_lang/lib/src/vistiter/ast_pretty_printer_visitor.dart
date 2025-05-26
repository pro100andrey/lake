// ignore_for_file: avoid_print

import '../../lake_lang.dart';

/// An AST visitor that pretty-prints the Lake AST.
class AstPrettyPrinterVisitor implements AstVisitor<void> {
  int _indentationLevel = 0;
  String _indent() => '  ' * _indentationLevel;

  void _withIndentation(void Function() body) {
    _indentationLevel++;
    try {
      body();
    } finally {
      _indentationLevel--;
    }
  }

  @override
  void visitDocumentNode(DocumentNode node) {
    print('DocumentNode:');

    _withIndentation(() {
      if (node.headers.isNotEmpty) {
        print('${_indent()}Headers:');

        _withIndentation(() {
          for (final header in node.headers) {
            header.accept(this);
          }
        });
      }

      if (node.definitions.isNotEmpty) {
        print('${_indent()}Definitions:');

        _withIndentation(() {
          for (final definition in node.definitions) {
            definition.accept(this);
          }
        });
      }
    });

    print('End');
  }

  @override
  void visitImportNode(ImportNode node) {
    print('${_indent()}ImportNode(path: ${node.path})');
  }

  @override
  void visitNamespaceNode(NamespaceNode node) {
    print(
      '${_indent()}NamespaceNode(scope: "${node.scope}", name: "${node.name}")',
    );
  }

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {
    print('${_indent()}TypedefDefinitionNode:');
    _withIndentation(() {
      print('${_indent()}Name: ${node.name}');
      print('${_indent()}Type: ${node.type}');
    });
  }

  @override
  void visitBaseTypeNode(BaseTypeNode node) {}

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {
    print('${_indent()}ConstDefinitionNode:');
    _withIndentation(() {
      print('${_indent()}Name: ${node.name}');
      print('${_indent()}Type: ${node.type}');
      print('${_indent()}Value: ${node.value}');
    });
  }

  @override
  void visitConstListNode(ConstListNode node) {}

  @override
  void visitConstMapNode(ConstMapNode node) {}

  @override
  void visitCustomTypeNode(CustomTypeNode node) {}

  @override
  void visitDoubleConstantNode(DoubleConstantNode node) {}

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {}

  @override
  void visitEnumValueNode(EnumValueNode node) {}

  @override
  void visitExceptionDefinitionNode(ExceptionDefinitionNode node) {}

  @override
  void visitFieldNode(FieldNode node) {}

  @override
  void visitFieldRequirementNode(FieldRequirementNode node) {}

  @override
  void visitFunctionNode(FunctionNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitIntConstantNode(IntConstantNode node) {}

  @override
  void visitListTypeNode(ListTypeNode node) {}

  @override
  void visitLiteralNode(LiteralNode node) {}

  @override
  void visitMapTypeNode(MapTypeNode node) {}

  @override
  void visitServiceDefinitionNode(ServiceDefinitionNode node) {}

  @override
  void visitSetTypeNode(SetTypeNode node) {}

  @override
  void visitStreamTypeNode(StreamTypeNode node) {}

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {}

  @override
  void visitVoidTypeNode(VoidTypeNode node) {}
}
