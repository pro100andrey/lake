import 'nodes/ast_nodes.dart';

/// Abstract base class for all AST Visitors
// (AstVisitor interface remains mostly the same, ensuring exhaustive checking)
abstract class AstVisitor<T> {
  /// Creates a new instance of [AstVisitor].
  const AstVisitor();
  // Visit methods for each specific AST node type
  T visitDocumentNode(DocumentNode node);
  T visitImportNode(ImportNode node);
  T visitNamespaceNode(NamespaceNode node);
  T visitConstDefinitionNode(ConstDefinitionNode node);
  T visitTypedefDefinitionNode(TypedefDefinitionNode node);
  T visitEnumDefinitionNode(EnumDefinitionNode node);
  T visitEnumMemberNode(EnumMemberNode node);
  T visitStructDefinitionNode(StructDefinitionNode node);
  T visitUnionDefinitionNode(UnionDefinitionNode node);
  T visitExceptionDefinitionNode(ExceptionDefinitionNode node);
  T visitServiceDefinitionNode(ServiceDefinitionNode node);
  T visitFieldRequirementNode(FieldRequirementNode node);
  T visitFieldNode(FieldNode node);
  T visitMethodNode(MethodNode node);

  // Type nodes
  T visitBaseTypeNode(BaseTypeNode node);
  T visitMapTypeNode(MapTypeNode node);
  T visitSetTypeNode(SetTypeNode node);
  T visitListTypeNode(ListTypeNode node);
  T visitStreamTypeNode(StreamTypeNode node);
  T visitCustomTypeNode(CustomTypeNode node);
  T visitVoidTypeNode(VoidTypeNode node);

  // Literal value nodes
  T visitIntLiteralNode(IntLiteralNode node);
  T visitDoubleLiteralNode(DoubleLiteralNode node);
  T visitBoolLiteralNode(BoolLiteralNode node);
  T visitStringLiteralNode(StringLiteralNode node);
  T visitIdentifierNode(IdentifierNode node);
  T visitListLiteralNode(ListLiteralNode node);
  T visitMapLiteralNode(MapLiteralNode node);
}
