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
  const DocumentNode(this.headers, this.definitions);

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
  const ImportNode(this.path);

  final String path;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitImportNode(this);

  @override
  List<Object?> get props => [path];
}

class NamespaceNode extends HeaderNode {
  const NamespaceNode(this.scope, this.name);

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

class ConstDefinitionNode extends DefinitionNode {
  const ConstDefinitionNode(this.type, this.name, this.value);

  final TypeNode type;
  final IdentifierNode name;
  final ConstValueNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstDefinitionNode(this);

  @override
  List<Object?> get props => [type, name, value];
}

class TypedefDefinitionNode extends DefinitionNode {
  const TypedefDefinitionNode(this.type, this.name);

  final TypeNode type;
  final IdentifierNode name;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitTypedefDefinitionNode(this);

  @override
  List<Object?> get props => [type, name];
}

class EnumDefinitionNode extends DefinitionNode {
  const EnumDefinitionNode(this.name, this.values);

  final IdentifierNode name;
  final List<EnumValueNode> values;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumDefinitionNode(this);

  @override
  List<Object?> get props => [name, values];
}

class EnumValueNode extends AstNode {
  const EnumValueNode(this.name, this.value);

  final IdentifierNode name;
  final int? value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumValueNode(this);

  @override
  List<Object?> get props => [name, value];
}

class StructDefinitionNode extends DefinitionNode {
  const StructDefinitionNode(this.name, this.fields);

  final IdentifierNode name;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStructDefinitionNode(this);

  @override
  List<Object?> get props => [name, fields];
}

class ExceptionDefinitionNode extends DefinitionNode {
  const ExceptionDefinitionNode(this.name, this.fields);

  final IdentifierNode name;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitExceptionDefinitionNode(this);

  @override
  List<Object?> get props => [name, fields];
}

class ServiceDefinitionNode extends DefinitionNode {
  const ServiceDefinitionNode(this.name, this.extendsService, this.functions);

  final IdentifierNode name;
  final IdentifierNode? extendsService;
  final List<FunctionNode> functions;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitServiceDefinitionNode(this);

  @override
  List<Object?> get props => [name, extendsService, functions];
}

class FieldNode extends AstNode {
  const FieldNode(
    this.id,
    this.requirement,
    this.type,
    this.name,
    this.defaultValue,
  );

  final int? id;
  final String? requirement;
  final TypeNode type;
  final IdentifierNode name;
  final ConstValueNode? defaultValue;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldNode(this);

  @override
  List<Object?> get props => [id, requirement, type, name, defaultValue];
}

class FunctionNode extends AstNode {
  const FunctionNode(
    this.returnType,
    this.name,
    this.parameters,
    this.throwsExceptions,
  );

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

class BaseTypeNode extends TypeNode {
  const BaseTypeNode(this.name);

  final String name;
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBaseTypeNode(this);

  @override
  List<Object?> get props => [name];
}

sealed class ContainerTypeNode extends TypeNode {
  const ContainerTypeNode();
}

class MapTypeNode extends ContainerTypeNode {
  const MapTypeNode(this.keyType, this.valueType);

  final TypeNode keyType;
  final TypeNode valueType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMapTypeNode(this);

  @override
  List<Object?> get props => [keyType, valueType];
}

class SetTypeNode extends ContainerTypeNode {
  const SetTypeNode(this.itemType);

  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSetTypeNode(this);

  @override
  List<Object?> get props => [itemType];
}

class ListTypeNode extends ContainerTypeNode {
  const ListTypeNode(this.itemType);

  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListTypeNode(this);

  @override
  List<Object?> get props => [itemType];
}

class StreamTypeNode extends ContainerTypeNode {
  const StreamTypeNode(this.itemType);
  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStreamTypeNode(this);

  @override
  List<Object?> get props => [itemType];
}

class CustomTypeNode extends TypeNode {
  const CustomTypeNode(this.name);

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

class IntConstantNode extends ConstValueNode {
  const IntConstantNode(this.value);

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIntConstantNode(this);

  @override
  List<Object?> get props => [value];
}

class DoubleConstantNode extends ConstValueNode {
  const DoubleConstantNode(this.value);
  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDoubleConstantNode(this);

  @override
  List<Object?> get props => [value];
}

class LiteralNode extends ConstValueNode {
  const LiteralNode(this.value);
  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteralNode(this);

  @override
  List<Object?> get props => [value];
}

class IdentifierNode extends ConstValueNode {
  const IdentifierNode(this.name);

  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIdentifierNode(this);

  @override
  List<Object?> get props => [name];
}

class ConstListNode extends ConstValueNode {
  const ConstListNode(this.elements);

  final List<ConstValueNode> elements;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstListNode(this);

  @override
  List<Object?> get props => [elements];
}

class ConstMapNode extends ConstValueNode {
  const ConstMapNode(this.entries);

  final Map<ConstValueNode, ConstValueNode> entries;
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstMapNode(this);

  @override
  List<Object?> get props => [entries];
}
