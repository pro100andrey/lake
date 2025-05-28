import '../../lake_lang.dart';

/// Abstract base class for all AST Visitors
// (AstVisitor interface remains mostly the same, ensuring exhaustive checking)
abstract class AstVisitor<T> {
  // Visit methods for each specific AST node type
  T visitDocumentNode(DocumentNode node);
  T visitImportNode(ImportNode node);
  T visitNamespaceNode(NamespaceNode node);
  T visitConstDefinitionNode(ConstDefinitionNode node);
  T visitTypedefDefinitionNode(TypedefDefinitionNode node);
  T visitEnumDefinitionNode(EnumDefinitionNode node);
  T visitEnumValueNode(EnumValueNode node);
  T visitStructDefinitionNode(StructDefinitionNode node);
  T visitExceptionDefinitionNode(ExceptionDefinitionNode node);
  T visitServiceDefinitionNode(ServiceDefinitionNode node);
  T visitFieldRequirementNode(FieldRequirementNode node);
  T visitFieldNode(FieldNode node);
  T visitFunctionNode(FunctionNode node);

  // Type nodes
  T visitBaseTypeNode(BaseTypeNode node);
  T visitMapTypeNode(MapTypeNode node);
  T visitSetTypeNode(SetTypeNode node);
  T visitListTypeNode(ListTypeNode node);
  T visitStreamTypeNode(StreamTypeNode node);
  T visitCustomTypeNode(CustomTypeNode node);
  T visitVoidTypeNode(VoidTypeNode node);

  // Constant value nodes
  T visitIntConstantNode(IntConstantNode node);
  T visitDoubleConstantNode(DoubleConstantNode node);
  T visitEnumConstantNode(EnumConstantNode node);
  T visitLiteralNode(LiteralNode node);
  T visitIdentifierNode(IdentifierNode node);
  T visitConstListNode(ConstListNode node);
  T visitConstMapNode(ConstMapNode node);
}
