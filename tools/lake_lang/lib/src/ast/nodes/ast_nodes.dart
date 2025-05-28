import 'package:equatable/equatable.dart';
import 'package:source_span/source_span.dart';

import '../ast_visitor.dart';

/// Base sealed class for all AST nodes.
/// All concrete AST nodes must be defined in this file (or library).
sealed class AstNode extends Equatable {
  const AstNode({this.span});

  /// Optional span for source location information.
  final SourceSpan? span;

  /// Add an accept method for the Visitor pattern
  T accept<T>(AstVisitor<T> visitor);

  // Equatable requires props, but the base AstNode itself has no specific
  // properties that define its equality beyond its type and children, which
  // are handled by concrete implementations.
  @override
  List<Object?> get props => throw UnimplementedError(
    'props should be implemented in subclasses of AstNode',
  );

  @override
  bool get stringify => false;
}


// --- Concrete AST Node Classes ---

final class DocumentNode extends AstNode {
  const DocumentNode({
    required this.headers,
    required this.definitions,
    required super.span,
  });

  final List<HeaderNode> headers;
  final List<DefinitionNode> definitions;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDocumentNode(this);

  @override
  List<Object?> get props => [headers, definitions, span];
}

sealed class HeaderNode extends AstNode {
  const HeaderNode({super.span});
}

final class ImportNode extends HeaderNode {
  const ImportNode({required this.path, required super.span});

  final String path;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitImportNode(this);

  @override
  List<Object?> get props => [path, span];
}

final class NamespaceNode extends HeaderNode {
  const NamespaceNode({
    required this.scope,
    required this.name,
    required super.span,
  });

  final String scope;
  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitNamespaceNode(this);

  @override
  List<Object?> get props => [scope, name, span];
}

sealed class DefinitionNode extends AstNode {
  const DefinitionNode({super.span});
}

final class ConstDefinitionNode extends DefinitionNode {
  const ConstDefinitionNode({
    required this.type,
    required this.name,
    required this.value,
    required super.span,
  });

  final TypeNode type;
  final IdentifierNode name;
  final ConstValueNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstDefinitionNode(this);

  @override
  List<Object?> get props => [type, name, value, span];
}

final class TypedefDefinitionNode extends DefinitionNode {
  const TypedefDefinitionNode({
    required this.type,
    required this.name,
    required super.span,
  });

  final TypeNode type;
  final IdentifierNode name;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitTypedefDefinitionNode(this);

  @override
  List<Object?> get props => [type, name, span];
}

final class EnumDefinitionNode extends DefinitionNode {
  const EnumDefinitionNode({
    required this.name,
    required this.values,
    required super.span,
  });

  final IdentifierNode name;
  final List<EnumValueNode> values;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumDefinitionNode(this);

  @override
  List<Object?> get props => [name, values, span];
}

final class EnumValueNode extends AstNode {
  const EnumValueNode({
    required this.memberName,
    required super.span,
    this.value,
  });

  final IdentifierNode memberName;
  final IntConstantNode? value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumValueNode(this);

  @override
  List<Object?> get props => [memberName, value, span];
}

final class StructDefinitionNode extends DefinitionNode {
  const StructDefinitionNode({
    required this.name,
    required this.fields,
    required super.span,
  });

  final IdentifierNode name;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStructDefinitionNode(this);

  @override
  List<Object?> get props => [name, fields, span];
}

final class ExceptionDefinitionNode extends DefinitionNode {
  const ExceptionDefinitionNode({
    required this.name,
    required this.fields,
    required super.span,
  });

  final IdentifierNode name;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitExceptionDefinitionNode(this);

  @override
  List<Object?> get props => [name, fields, span];
}

final class ServiceDefinitionNode extends DefinitionNode {
  const ServiceDefinitionNode({
    required this.name,
    required this.extendsService,
    required this.functions,
    required super.span,
  });

  final IdentifierNode name;
  final IdentifierNode? extendsService;
  final List<FunctionNode> functions;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitServiceDefinitionNode(this);

  @override
  List<Object?> get props => [name, extendsService, functions, span];
}

final class FieldRequirementNode extends AstNode {
  const FieldRequirementNode({required this.requirement, required super.span});

  final String requirement;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldRequirementNode(this);

  @override
  List<Object?> get props => [requirement, span];
}

final class FieldNode extends AstNode {
  const FieldNode({
    required this.id,
    required this.requirement,
    required this.type,
    required this.name,
    required this.defaultValue,
    required super.span,
  });

  final IntConstantNode id;
  final FieldRequirementNode? requirement;
  final TypeNode type;
  final IdentifierNode name;
  final ConstValueNode? defaultValue;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldNode(this);

  @override
  List<Object?> get props => [id, requirement, type, name, defaultValue, span];
}

final class FunctionNode extends AstNode {
  const FunctionNode({
    required this.returnType,
    required this.name,
    required this.parameters,
    required this.throwsExceptions,
    required super.span,
  });

  final TypeNode returnType;
  final IdentifierNode name;
  final List<FieldNode> parameters;
  final List<IdentifierNode> throwsExceptions;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunctionNode(this);

  @override
  List<Object?> get props => [
    returnType,
    name,
    parameters,
    throwsExceptions,
    span,
  ];
}

// Types
sealed class TypeNode extends AstNode {
  const TypeNode({super.span});
}

final class BaseTypeNode extends TypeNode {
  const BaseTypeNode({required this.type, required super.span});

  final String type;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBaseTypeNode(this);

  @override
  List<Object?> get props => [type, span];
}

sealed class ContainerTypeNode extends TypeNode {
  const ContainerTypeNode({super.span});
}

final class MapTypeNode extends ContainerTypeNode {
  const MapTypeNode({
    required this.keyType,
    required this.valueType,
    required super.span,
  });

  final TypeNode keyType;
  final TypeNode valueType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMapTypeNode(this);

  @override
  List<Object?> get props => [keyType, valueType, span];
}

final class SetTypeNode extends ContainerTypeNode {
  const SetTypeNode({required this.itemType, required super.span});

  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSetTypeNode(this);

  @override
  List<Object?> get props => [itemType, span];
}

final class ListTypeNode extends ContainerTypeNode {
  const ListTypeNode({required this.itemType, required super.span});

  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListTypeNode(this);

  @override
  List<Object?> get props => [itemType, span];
}

final class StreamTypeNode extends TypeNode {
  const StreamTypeNode({required this.itemType, required super.span});
  final TypeNode itemType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStreamTypeNode(this);

  @override
  List<Object?> get props => [itemType, span];
}

final class CustomTypeNode extends TypeNode {
  const CustomTypeNode({required this.type, required super.span});

  final IdentifierNode type;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCustomTypeNode(this);

  @override
  List<Object?> get props => [type, span];
}

class VoidTypeNode extends TypeNode {
  const VoidTypeNode({required super.span});

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVoidTypeNode(this);

  @override
  List<Object?> get props => [span];
}

final class IdentifierNode extends AstNode {
  const IdentifierNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIdentifierNode(this);

  @override
  List<Object?> get props => [value, span];
}

// Constants
sealed class ConstValueNode extends AstNode {
  const ConstValueNode({super.span});
}

final class IntConstantNode extends ConstValueNode {
  const IntConstantNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIntConstantNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class DoubleConstantNode extends ConstValueNode {
  const DoubleConstantNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDoubleConstantNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class EnumConstantNode extends ConstValueNode {
  const EnumConstantNode({
    required this.type,
    required this.value,
    required super.span,
  });

  final IdentifierNode type;
  final IdentifierNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumConstantNode(this);

  @override
  List<Object?> get props => [type, value, span];
}

final class LiteralNode extends ConstValueNode {
  const LiteralNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteralNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class ConstListNode extends ConstValueNode {
  const ConstListNode({required this.elements, required super.span});

  final List<ConstValueNode> elements;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstListNode(this);

  @override
  List<Object?> get props => [elements, span];
}

final class ConstMapNode extends ConstValueNode {
  const ConstMapNode({required this.entries, required super.span});

  final Map<ConstValueNode, ConstValueNode> entries;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstMapNode(this);

  @override
  List<Object?> get props => [entries, span];
}
