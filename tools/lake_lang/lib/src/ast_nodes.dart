import 'package:equatable/equatable.dart';

/// Base sealed class for all AST nodes.
/// All concrete AST nodes must be defined in this file (or library).
sealed class AstNode extends Equatable {
  const AstNode();
  // Add an accept method for the Visitor pattern
  T accept<T>(AstVisitor<T> visitor);

  // Equatable requires props, but the base AstNode itself has no specific
  // properties that define its equality beyond its type and children, which
  // are handled by concrete implementations.
  @override
  List<Object?> get props => throw UnimplementedError(
    'props should be implemented in subclasses of AstNode',
  );

  @override
  bool get stringify => true; // Make toString() more useful for debugging
}

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
  T visitLiteralNode(LiteralNode node);
  T visitIdentifierNode(IdentifierNode node);
  T visitConstListNode(ConstListNode node);
  T visitConstMapNode(ConstMapNode node);
}

// --- Concrete AST Node Classes ---

final class DocumentNode extends AstNode {
  const DocumentNode({required this.headers, required this.definitions});

  final List<HeaderNode> headers;
  final List<DefinitionNode> definitions;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDocumentNode(this);

  @override
  List<Object?> get props => [headers, definitions];
}

sealed class HeaderNode extends AstNode {
  const HeaderNode();
}

final class ImportNode extends HeaderNode {
  const ImportNode({required this.path});

  final String path;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitImportNode(this);

  @override
  List<Object?> get props => [path];
}

final class NamespaceNode extends HeaderNode {
  const NamespaceNode({required this.scope, required this.name});

  final String scope;
  final IdentifierNode name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitNamespaceNode(this);

  @override
  List<Object?> get props => [scope, name];
}

sealed class DefinitionNode extends AstNode {
  const DefinitionNode();
}

final class ConstDefinitionNode extends DefinitionNode {
  const ConstDefinitionNode({
    required this.type,
    required this.name,
    required this.value,
  });

  final TypeNode type;
  final IdentifierNode name;
  final ConstValueNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstDefinitionNode(this);

  @override
  List<Object?> get props => [type, name, value];
}

final class TypedefDefinitionNode extends DefinitionNode {
  const TypedefDefinitionNode({required this.type, required this.name});

  final TypeNode type;
  final IdentifierNode name;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitTypedefDefinitionNode(this);

  @override
  List<Object?> get props => [type, name];
}

final class EnumDefinitionNode extends DefinitionNode {
  const EnumDefinitionNode({required this.name, required this.values});

  final IdentifierNode name;
  final List<EnumValueNode> values;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumDefinitionNode(this);

  @override
  List<Object?> get props => [name, values];
}

final class EnumValueNode extends AstNode {
  const EnumValueNode(this.name, this.value);

  final IdentifierNode name;
  final int? value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumValueNode(this);

  @override
  List<Object?> get props => [name, value];
}

final class StructDefinitionNode extends DefinitionNode {
  const StructDefinitionNode({required this.name, required this.fields});

  final IdentifierNode name;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStructDefinitionNode(this);

  @override
  List<Object?> get props => [name, fields];
}

final class ExceptionDefinitionNode extends DefinitionNode {
  const ExceptionDefinitionNode({required this.name, required this.fields});

  final IdentifierNode name;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitExceptionDefinitionNode(this);

  @override
  List<Object?> get props => [name, fields];
}

final class ServiceDefinitionNode extends DefinitionNode {
  const ServiceDefinitionNode({
    required this.name,
    required this.extendsService,
    required this.functions,
  });

  final IdentifierNode name;
  final IdentifierNode? extendsService;
  final List<FunctionNode> functions;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitServiceDefinitionNode(this);

  @override
  List<Object?> get props => [name, extendsService, functions];
}

final class FieldRequirementNode extends AstNode {
  const FieldRequirementNode({required this.requirement});

  final String requirement;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldRequirementNode(this);

  @override
  List<Object?> get props => [requirement];
}

final class FieldNode extends AstNode {
  const FieldNode({
    required this.id,
    required this.requirement,
    required this.type,
    required this.name,
    required this.defaultValue,
  });

  final int id;
  final FieldRequirementNode? requirement;
  final TypeNode type;
  final IdentifierNode name;
  final ConstValueNode? defaultValue;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldNode(this);

  @override
  List<Object?> get props => [id, requirement, type, name, defaultValue];
}

final class FunctionNode extends AstNode {
  const FunctionNode({
    required this.returnType,
    required this.name,
    required this.parameters,
    required this.throwsExceptions,
  });

  final TypeNode returnType;
  final IdentifierNode name;
  final List<FieldNode> parameters;
  final List<IdentifierNode> throwsExceptions;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunctionNode(this);

  @override
  List<Object?> get props => [returnType, name, parameters, throwsExceptions];
}

// Types
sealed class TypeNode extends AstNode {
  const TypeNode();
}

final class BaseTypeNode extends TypeNode {
  const BaseTypeNode({required this.name});

  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBaseTypeNode(this);

  @override
  List<Object?> get props => [name];
}

sealed class ContainerTypeNode extends TypeNode {
  const ContainerTypeNode();
}

final class MapTypeNode extends ContainerTypeNode {
  const MapTypeNode({required this.keyType, required this.valueType});

  final TypeNode keyType;
  final TypeNode valueType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMapTypeNode(this);

  @override
  List<Object?> get props => [keyType, valueType];
}

final class SetTypeNode extends ContainerTypeNode {
  const SetTypeNode({required this.itemType});

  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSetTypeNode(this);

  @override
  List<Object?> get props => [itemType];
}

final class ListTypeNode extends ContainerTypeNode {
  const ListTypeNode({required this.itemType});

  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListTypeNode(this);

  @override
  List<Object?> get props => [itemType];
}

final class StreamTypeNode extends ContainerTypeNode {
  const StreamTypeNode({required this.itemType});
  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStreamTypeNode(this);

  @override
  List<Object?> get props => [itemType];
}

final class CustomTypeNode extends TypeNode {
  const CustomTypeNode({required this.name});

  final IdentifierNode name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCustomTypeNode(this);

  @override
  List<Object?> get props => [name];
}

class VoidTypeNode extends TypeNode {
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVoidTypeNode(this);

  @override
  List<Object?> get props => [];
}

// Constants
sealed class ConstValueNode extends AstNode {
  const ConstValueNode();
}

final class IntConstantNode extends ConstValueNode {
  const IntConstantNode({required this.value, required this.intValue});

  final String value;

  final int intValue;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIntConstantNode(this);

  @override
  List<Object?> get props => [value, intValue];
}

final class DoubleConstantNode extends ConstValueNode {
  const DoubleConstantNode({required this.value});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDoubleConstantNode(this);

  @override
  List<Object?> get props => [value];
}

final class LiteralNode extends ConstValueNode {
  const LiteralNode({required this.value});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteralNode(this);

  @override
  List<Object?> get props => [value];
}

final class IdentifierNode extends AstNode {
  const IdentifierNode({required this.name});

  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIdentifierNode(this);

  @override
  List<Object?> get props => [name];
}

final class ConstListNode extends ConstValueNode {
  const ConstListNode({required this.elements});

  final List<ConstValueNode> elements;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstListNode(this);

  @override
  List<Object?> get props => [elements];
}

final class ConstMapNode extends ConstValueNode {
  const ConstMapNode({required this.entries});

  final Map<ConstValueNode, ConstValueNode> entries;
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstMapNode(this);

  @override
  List<Object?> get props => [entries];
}
