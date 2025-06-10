import 'package:equatable/equatable.dart';
import 'package:source_span/source_span.dart';

import '../ast_visitor.dart';

/// Base sealed class for all AST nodes.
/// All concrete AST nodes must be defined in this file (or library).
sealed class AstNode extends Equatable {
  const AstNode({required this.span});

  /// Optional span for source location information.
  final SourceSpan span;

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
  const HeaderNode({required super.span});
}

final class ImportNode extends HeaderNode {
  const ImportNode({required this.path, required super.span});

  final LiteralNode path;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitImportNode(this);

  @override
  List<Object?> get props => [path, span];
}

final class NamespaceNode extends HeaderNode {
  const NamespaceNode({
    required this.scope,
    required this.identifier,
    required super.span,
  });

  final LiteralNode scope;
  final IdentifierNode identifier;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitNamespaceNode(this);

  @override
  List<Object?> get props => [scope, identifier, span];
}

sealed class DefinitionNode extends AstNode {
  const DefinitionNode({required super.span});
}

final class ConstDefinitionNode extends DefinitionNode {
  const ConstDefinitionNode({
    required this.type,
    required this.identifier,
    required this.value,
    required super.span,
  });

  final TypeNode type;
  final IdentifierNode identifier;
  final ConstValueNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstDefinitionNode(this);

  @override
  List<Object?> get props => [type, identifier, value, span];
}

final class TypedefDefinitionNode extends DefinitionNode {
  const TypedefDefinitionNode({
    required this.type,
    required this.identifier,
    required super.span,
  });

  final TypeNode type;
  final IdentifierNode identifier;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitTypedefDefinitionNode(this);

  @override
  List<Object?> get props => [type, identifier, span];
}

final class EnumDefinitionNode extends DefinitionNode {
  const EnumDefinitionNode({
    required this.identifier,
    required this.members,
    required super.span,
  });

  final IdentifierNode identifier;
  final List<EnumValueNode> members;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, members, span];
}

final class EnumValueNode extends AstNode {
  const EnumValueNode({
    required this.identifier,
    required super.span,
    this.value,
  });

  final IdentifierNode identifier;
  final IntConstantNode? value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumValueNode(this);

  @override
  List<Object?> get props => [identifier, value, span];
}

final class StructDefinitionNode extends DefinitionNode {
  const StructDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.span,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStructDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, fields, span];
}

final class ExceptionDefinitionNode extends DefinitionNode {
  const ExceptionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.span,
  });

  final IdentifierNode identifier;
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitExceptionDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, fields, span];
}

final class ServiceDefinitionNode extends DefinitionNode {
  const ServiceDefinitionNode({
    required this.identifier,
    required this.extendsService,
    required this.functions,
    required super.span,
  });

  final IdentifierNode identifier;
  final IdentifierNode? extendsService;
  final List<FunctionNode> functions;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitServiceDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, extendsService, functions, span];
}

final class FieldRequirementNode extends AstNode {
  const FieldRequirementNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldRequirementNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class FieldNode extends AstNode {
  const FieldNode({
    required this.fieldId,
    required this.requirement,
    required this.type,
    required this.identifier,
    required this.defaultValue,
    required super.span,
  });

  final IntConstantNode? fieldId;
  final FieldRequirementNode? requirement;
  final TypeNode type;
  final IdentifierNode identifier;
  final ConstValueNode? defaultValue;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldNode(this);

  @override
  List<Object?> get props => [
    fieldId,
    requirement,
    type,
    identifier,
    defaultValue,
    span,
  ];
}

final class FunctionNode extends AstNode {
  const FunctionNode({
    required this.returnType,
    required this.identifier,
    required this.parameters,
    required this.throws,
    required super.span,
  });

  final TypeNode returnType;
  final IdentifierNode identifier;
  final List<FieldNode> parameters;
  final List<FieldNode> throws;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunctionNode(this);

  @override
  List<Object?> get props => [returnType, identifier, parameters, throws, span];
}

// Types
sealed class TypeNode extends AstNode {
  const TypeNode({required super.span});
}

final class BaseTypeNode extends TypeNode {
  const BaseTypeNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBaseTypeNode(this);

  @override
  List<Object?> get props => [value, span];
}

sealed class ContainerTypeNode extends TypeNode {
  const ContainerTypeNode({required super.span});
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
  const SetTypeNode({required this.elementType, required super.span});

  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSetTypeNode(this);

  @override
  List<Object?> get props => [elementType, span];
}

final class ListTypeNode extends ContainerTypeNode {
  const ListTypeNode({required this.elementType, required super.span});

  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListTypeNode(this);

  @override
  List<Object?> get props => [elementType, span];
}

final class StreamTypeNode extends TypeNode {
  const StreamTypeNode({required this.elementType, required super.span});

  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStreamTypeNode(this);

  @override
  List<Object?> get props => [elementType, span];
}

final class CustomTypeNode extends TypeNode {
  const CustomTypeNode({required this.value, required super.span});

  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCustomTypeNode(this);

  @override
  List<Object?> get props => [value, span];
}

class VoidTypeNode extends TypeNode {
  const VoidTypeNode({required super.span});

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVoidTypeNode(this);

  @override
  List<Object?> get props => [span];
}

// Constants
sealed class ConstValueNode extends AstNode {
  const ConstValueNode({required super.span});

  String get valueKind;
  String get valueType;
}

final class IntConstantNode extends ConstValueNode {
  const IntConstantNode({required this.value, required super.span});

  final String value;

  @override
  String get valueKind => 'literal';

  @override
  String get valueType => 'int';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIntConstantNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class DoubleConstantNode extends ConstValueNode {
  const DoubleConstantNode({required this.value, required super.span});

  final String value;

  @override
  String get valueKind => 'literal';

  @override
  String get valueType => 'double';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDoubleConstantNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class BoolConstantNode extends ConstValueNode {
  const BoolConstantNode({required this.value, required super.span});

  final bool value;

  @override
  String get valueKind => 'literal';

  @override
  String get valueType => 'bool';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBoolConstantNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class LiteralNode extends ConstValueNode {
  const LiteralNode({required this.value, required super.span});

  final String value;

  @override
  String get valueKind => 'literal';

  @override
  String get valueType => 'string';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteralNode(this);

  @override
  List<Object?> get props => [value, span];
}

final class ConstListNode extends ConstValueNode {
  const ConstListNode({required this.elements, required super.span});

  final List<ConstValueNode> elements;

  @override
  String get valueKind => 'list';

  @override
  String get valueType => 'list';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstListNode(this);

  @override
  List<Object?> get props => [elements, span];
}

final class ConstMapNode extends ConstValueNode {
  const ConstMapNode({required this.entries, required super.span});

  final List<MapEntry<ConstValueNode, ConstValueNode>> entries;

  @override
  String get valueKind => 'map';

  @override
  String get valueType => 'map';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstMapNode(this);

  @override
  List<Object?> get props => [entries, span];
}

final class IdentifierNode extends ConstValueNode {
  const IdentifierNode({required this.value, required super.span});

  final String value;

  @override
  String get valueKind => 'identifier';

  @override
  String get valueType => 'identifier';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIdentifierNode(this);

  @override
  List<Object?> get props => [value, span];
}
