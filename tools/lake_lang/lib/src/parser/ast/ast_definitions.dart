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
}

sealed class DefinitionNode extends AstNode {
  const DefinitionNode({required super.startOffset, required super.endOffset});
}

final class ConstDefinitionNode extends DefinitionNode {
  const ConstDefinitionNode({
    required this.type,
    required this.identifier,
    required this.value,
    required super.startOffset,
    required super.endOffset,
  });

  final TypeNode type;
  final IdentifierNode identifier;
  final LiteralValueNode value;
}

final class TypedefDefinitionNode extends DefinitionNode {
  const TypedefDefinitionNode({
    required this.type,
    required this.identifier,
    required super.startOffset,
    required super.endOffset,
  });

  final TypeNode type;
  final IdentifierNode identifier;
}

final class EnumValueNode extends AstNode {
  const EnumValueNode({
    required this.identifier,
    required super.startOffset,
    required super.endOffset,
    this.value,
  });

  final IdentifierNode identifier;
  final IntLiteralNode? value;
}

final class EnumDefinitionNode extends DefinitionNode {
  const EnumDefinitionNode({
    required this.identifier,
    required this.members,
    required super.startOffset,
    required super.endOffset,
  });

  final IdentifierNode identifier;
  final List<EnumValueNode> members;
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
  });

  final IntLiteralNode? fieldId;
  final bool isRequired;
  final TypeNode type;
  final IdentifierNode identifier;
  final LiteralValueNode? defaultValue;
}

final class StructDefinitionNode extends DefinitionNode {
  const StructDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.startOffset,
    required super.endOffset,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;
}

final class UnionDefinitionNode extends DefinitionNode {
  const UnionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.startOffset,
    required super.endOffset,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;
}

final class ExceptionDefinitionNode extends DefinitionNode {
  const ExceptionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.startOffset,
    required super.endOffset,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;
}

final class MethodNode extends AstNode {
  const MethodNode({
    required this.returnType,
    required this.identifier,
    required this.parameters,
    required this.throws,
    required super.startOffset,
    required super.endOffset,
  });

  final TypeNode returnType;
  final IdentifierNode identifier;
  final List<FieldNode> parameters;
  final List<FieldNode> throws;
}

final class ServiceDefinitionNode extends DefinitionNode {
  const ServiceDefinitionNode({
    required this.identifier,
    required this.methods,
    required super.startOffset,
    required super.endOffset,
    this.extendsService,
  });

  final IdentifierNode identifier;
  final IdentifierNode? extendsService;
  final List<MethodNode> methods;
}
