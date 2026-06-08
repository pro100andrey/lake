part of 'ast_base.dart';

final class DocumentNode extends AstNode {
  const DocumentNode({
    required this.headers,
    required this.definitions,
    required super.startOffset,
    required super.endOffset,
  });

  final List<HeaderNode> headers;
  final List<DefinitionNode> definitions;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDocumentNode(this);
}

sealed class HeaderNode extends AstNode {
  const HeaderNode({required super.startOffset, required super.endOffset});
}

final class ImportNode extends HeaderNode {
  const ImportNode({
    required this.path,
    required super.startOffset,
    required super.endOffset,
  });

  final StringLiteralNode path;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitImportNode(this);
}

final class NamespaceNode extends HeaderNode {
  const NamespaceNode({
    required this.scope,
    required this.identifier,
    required super.startOffset,
    required super.endOffset,
  });

  final IdentifierNode scope;
  final IdentifierNode identifier;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitNamespaceNode(this);
}

sealed class DefinitionNode extends AstNode {
  const DefinitionNode({
    required super.startOffset,
    required super.endOffset,
    this.docComment,
  });

  final String? docComment;
}

final class ConstDefinitionNode extends DefinitionNode {
  const ConstDefinitionNode({
    required this.type,
    required this.identifier,
    required this.value,
    required super.startOffset,
    required super.endOffset,
    super.docComment,
  });

  final TypeNode type;
  final IdentifierNode identifier;
  final LiteralValueNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstDefinitionNode(this);
}

final class TypedefDefinitionNode extends DefinitionNode {
  const TypedefDefinitionNode({
    required this.type,
    required this.identifier,
    required super.startOffset,
    required super.endOffset,
    super.docComment,
  });

  final TypeNode type;
  final IdentifierNode identifier;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitTypedefDefinitionNode(this);
}

final class EnumValueNode extends AstNode {
  const EnumValueNode({
    required this.identifier,
    required super.startOffset,
    required super.endOffset,
    this.value,
    this.docComment,
  });

  final IdentifierNode identifier;
  final IntLiteralNode? value;
  final String? docComment;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumValueNode(this);
}

final class EnumDefinitionNode extends DefinitionNode {
  const EnumDefinitionNode({
    required this.identifier,
    required this.members,
    required super.startOffset,
    required super.endOffset,
    super.docComment,
  });

  final IdentifierNode identifier;
  final List<EnumValueNode> members;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumDefinitionNode(this);
}

final class FieldNode extends AstNode {
  const FieldNode({
    required this.isRequired,
    required this.type,
    required this.identifier,
    required super.startOffset,
    required super.endOffset,
    this.fieldId,
    this.defaultValue,
    this.docComment,
  });

  final IntLiteralNode? fieldId;
  final bool isRequired;
  final TypeNode type;
  final IdentifierNode identifier;
  final LiteralValueNode? defaultValue;
  final String? docComment;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldNode(this);
}

final class StructDefinitionNode extends DefinitionNode {
  const StructDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.startOffset,
    required super.endOffset,
    super.docComment,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStructDefinitionNode(this);
}

final class UnionDefinitionNode extends DefinitionNode {
  const UnionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.startOffset,
    required super.endOffset,
    super.docComment,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitUnionDefinitionNode(this);
}

final class ExceptionDefinitionNode extends DefinitionNode {
  const ExceptionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.startOffset,
    required super.endOffset,
    super.docComment,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitExceptionDefinitionNode(this);
}

final class MethodNode extends AstNode {
  const MethodNode({
    required this.returnType,
    required this.identifier,
    required this.parameters,
    required this.throws,
    required super.startOffset,
    required super.endOffset,
    this.docComment,
  });

  final TypeNode returnType;
  final IdentifierNode identifier;
  final List<FieldNode> parameters;
  final List<FieldNode> throws;
  final String? docComment;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMethodNode(this);
}

final class ServiceDefinitionNode extends DefinitionNode {
  const ServiceDefinitionNode({
    required this.identifier,
    required this.methods,
    required super.startOffset,
    required super.endOffset,
    this.extendsService,
    super.docComment,
  });

  final IdentifierNode identifier;
  final IdentifierNode? extendsService;
  final List<MethodNode> methods;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitServiceDefinitionNode(this);
}
