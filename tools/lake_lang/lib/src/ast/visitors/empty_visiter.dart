// ignore_for_file: avoid_print

import '../ast_visitor.dart';
import '../nodes/ast_nodes.dart';

class EmptyVisitor implements AstVisitor<void> {
  /// Visits the root node of the AST.
  @override
  void visitDocumentNode(DocumentNode node) {}

  @override
  void visitImportNode(ImportNode node) {}

  @override
  void visitNamespaceNode(NamespaceNode node) {}

  @override
  void visitConstDefinitionNode(ConstDefinitionNode node) {}

  @override
  void visitTypedefDefinitionNode(TypedefDefinitionNode node) {}

  @override
  void visitEnumDefinitionNode(EnumDefinitionNode node) {}

  @override
  void visitEnumValueNode(EnumValueNode node) {}

  @override
  void visitStructDefinitionNode(StructDefinitionNode node) {}

  @override
  void visitUnionDefinitionNode(UnionDefinitionNode node) {}

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
  void visitBaseTypeNode(BaseTypeNode node) {}

  @override
  void visitMapTypeNode(MapTypeNode node) {}

  @override
  void visitSetTypeNode(SetTypeNode node) {}

  @override
  void visitListTypeNode(ListTypeNode node) {}

  @override
  void visitStreamTypeNode(StreamTypeNode node) {}

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
  void visitBoolConstantNode(BoolConstantNode node) {}

  @override
  void visitLiteralNode(LiteralNode node) {}

  @override
  void visitIdentifierNode(IdentifierNode node) {}

  @override
  void visitConstListNode(ConstListNode node) {}

  @override
  void visitConstMapNode(ConstMapNode node) {}
}
