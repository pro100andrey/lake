import 'package:equatable/equatable.dart';

import '../ast_visitor.dart';
import '../base/types.dart';

/// This file defines the complete AST (Abstract Syntax Tree) node structure for
/// the Lake language. All nodes are immutable and implement the [Equatable]
/// interface for equality checks. Each node also carries a [Span] for
/// source location tracking.

/// Base sealed class for all AST nodes.
///
/// Each AST node includes a [Span] for precise location tracking in the
/// source file. All nodes must implement [accept] for the Visitor pattern.
/// Subclasses must implement [props] for value equality.
sealed class AstNode extends Equatable {
  /// Constructs an AST node with the given [span].
  const AstNode({required this.span});

  /// The source location of the node in the original text.
  final Span span;

  /// Accepts a visitor to perform operations over this AST node.
  T accept<T>(AstVisitor<T> visitor);

  @override
  List<Object?> get props => throw UnimplementedError(
    'props should be implemented in subclasses of AstNode',
  );

  @override
  bool get stringify => false;
}

/// The root node of a parsed document.
///
/// Represents the entire Lake document, containing all header nodes
/// (such as imports and namespaces) and all top-level definitions
/// (constants, typedefs, enums, structs, exceptions, and services).
final class DocumentNode extends AstNode {
  /// Creates a [DocumentNode] with the given [headers], [definitions], and
  /// [span].
  const DocumentNode({
    required this.headers,
    required this.definitions,
    required super.span,
  });

  /// List of header nodes such as imports and namespaces.
  final List<HeaderNode> headers;

  /// List of top-level definition nodes in the document.
  final List<DefinitionNode> definitions;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDocumentNode(this);

  @override
  List<Object?> get props => [headers, definitions, span];
}

/// Base class for all header nodes (e.g., imports, namespaces).
sealed class HeaderNode extends AstNode {
  /// Constructs a [HeaderNode] with the given [span].
  const HeaderNode({required super.span});
}

/// Represents an import statement in the Lake language.
final class ImportNode extends HeaderNode {
  /// Creates an [ImportNode] with the given [path] and [span].
  const ImportNode({required this.path, required super.span});

  /// The path being imported, as a string literal node.
  final LiteralNode path;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitImportNode(this);

  @override
  List<Object?> get props => [path, span];
}

/// Represents a namespace declaration in the Lake language.
final class NamespaceNode extends HeaderNode {
  /// Creates a [NamespaceNode] with the given [scope], [identifier], and
  /// [span].
  const NamespaceNode({
    required this.scope,
    required this.identifier,
    required super.span,
  });

  /// The scope of the namespace, as a string literal node.
  final IdentifierNode scope;

  /// The identifier for the namespace.
  final IdentifierNode identifier;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitNamespaceNode(this);

  @override
  List<Object?> get props => [scope, identifier, span];
}

/// Base class for all top-level definition nodes.
sealed class DefinitionNode extends AstNode {
  /// Constructs a [DefinitionNode] with the given [span].
  const DefinitionNode({required super.span});
}

/// Represents a constant definition in the Lake language.
final class ConstDefinitionNode extends DefinitionNode {
  /// Creates a [ConstDefinitionNode] with the given [type], [identifier],
  /// [value], and [span].
  const ConstDefinitionNode({
    required this.type,
    required this.identifier,
    required this.value,
    required super.span,
  });

  /// The type of the constant.
  final TypeNode type;

  /// The identifier for the constant.
  final IdentifierNode identifier;

  /// The value assigned to the constant.
  final ConstValueNode value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstDefinitionNode(this);

  @override
  List<Object?> get props => [type, identifier, value, span];
}

/// Represents a typedef definition in the Lake language.
final class TypedefDefinitionNode extends DefinitionNode {
  /// Creates a [TypedefDefinitionNode] with the given [type], [identifier], and
  /// [span].
  const TypedefDefinitionNode({
    required this.type,
    required this.identifier,
    required super.span,
  });

  /// The type being aliased.
  final TypeNode type;

  /// The identifier for the typedef.
  final IdentifierNode identifier;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitTypedefDefinitionNode(this);

  @override
  List<Object?> get props => [type, identifier, span];
}

/// Represents an enum definition in the Lake language.
final class EnumDefinitionNode extends DefinitionNode {
  /// Creates an [EnumDefinitionNode] with the given [identifier], [members],
  /// and [span].
  const EnumDefinitionNode({
    required this.identifier,
    required this.members,
    required super.span,
  });

  /// The identifier for the enum.
  final IdentifierNode identifier;

  /// The list of enum value nodes.
  final List<EnumValueNode> members;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, members, span];
}

/// Represents a single value/member of an enum.
final class EnumValueNode extends AstNode {
  /// Creates an [EnumValueNode] with the given [identifier], optional [value],
  /// and [span].
  const EnumValueNode({
    required this.identifier,
    required super.span,
    this.value,
  });

  /// The identifier for the enum value.
  final IdentifierNode identifier;

  /// The optional integer value assigned to the enum member.
  final IntConstantNode? value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitEnumValueNode(this);

  @override
  List<Object?> get props => [identifier, value, span];
}

/// Represents a struct definition in the Lake language.
final class StructDefinitionNode extends DefinitionNode {
  /// Creates a [StructDefinitionNode] with the given [identifier], [fields],
  /// and [span].
  const StructDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.span,
  });

  /// The identifier for the struct.
  final IdentifierNode identifier;

  /// The list of fields in the struct.
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStructDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, fields, span];
}

final class UnionDefinitionNode extends DefinitionNode {
  /// Creates a [UnionDefinitionNode] with the given [identifier], [fields],
  /// and [span].
  const UnionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.span,
  });

  /// The identifier for the union.
  final IdentifierNode identifier;

  /// The list of fields in the union.
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitUnionDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, fields, span];
}

/// Represents an exception definition in the Lake language.
final class ExceptionDefinitionNode extends DefinitionNode {
  /// Creates an [ExceptionDefinitionNode] with the given [identifier],
  /// [fields], and [span].
  const ExceptionDefinitionNode({
    required this.identifier,
    required this.fields,
    required super.span,
  });

  /// The identifier for the exception.
  final IdentifierNode identifier;

  /// The list of fields in the exception.
  final List<FieldNode> fields;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitExceptionDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, fields, span];
}

/// Represents a service definition in the Lake language.
final class ServiceDefinitionNode extends DefinitionNode {
  /// Creates a [ServiceDefinitionNode] with the given [identifier], optional
  /// [extendsService], [functions], and [span].
  const ServiceDefinitionNode({
    required this.identifier,
    required this.extendsService,
    required this.functions,
    required super.span,
  });

  /// The identifier for the service.
  final IdentifierNode identifier;

  /// The optional identifier of the service being extended.
  final IdentifierNode? extendsService;

  /// The list of function nodes defined in the service.
  final List<FunctionNode> functions;

  @override
  T accept<T>(AstVisitor<T> visitor) =>
      visitor.visitServiceDefinitionNode(this);

  @override
  List<Object?> get props => [identifier, extendsService, functions, span];
}

/// Represents the requirement (e.g., required/optional) of a field.
final class FieldRequirementNode extends AstNode {
  /// Creates a [FieldRequirementNode] with the given [value] and [span].
  const FieldRequirementNode({required this.value, required super.span});

  /// The requirement value (e.g., "required", "optional").
  final String value;

  bool get isRequired => value == 'required';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFieldRequirementNode(this);

  @override
  List<Object?> get props => [value, span];
}

/// Represents a field in a struct, exception, or function parameter list.
final class FieldNode extends AstNode {
  /// Creates a [FieldNode] with the given [fieldId], [requirement], [type],
  /// [identifier], [defaultValue], and [span].
  const FieldNode({
    required this.fieldId,
    required this.requirement,
    required this.type,
    required this.identifier,
    required this.defaultValue,
    required super.span,
  });

  /// The optional field ID (for explicit field numbering).
  final IntConstantNode? fieldId;

  /// The optional requirement node (e.g., required/optional).
  final FieldRequirementNode? requirement;

  /// The type of the field.
  final TypeNode type;

  /// The identifier for the field.
  final IdentifierNode identifier;

  /// The optional default value for the field.
  final ConstValueNode? defaultValue;

  /// Whether the field is required based on its requirement node.
  bool get isRequired => requirement?.isRequired ?? false;

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

/// Represents a function (method) in a service definition.
final class FunctionNode extends AstNode {
  /// Creates a [FunctionNode] with the given [returnType], [identifier],
  /// [parameters], [throws], and [span].
  const FunctionNode({
    required this.returnType,
    required this.identifier,
    required this.parameters,
    required this.throws,
    required super.span,
  });

  /// The return type of the function.
  final TypeNode returnType;

  /// The identifier for the function.
  final IdentifierNode identifier;

  /// The list of parameter fields for the function.
  final List<FieldNode> parameters;

  /// The list of fields representing exceptions that the function may throw.
  final List<FieldNode> throws;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunctionNode(this);

  @override
  List<Object?> get props => [returnType, identifier, parameters, throws, span];
}

// Types

/// Base class for all type nodes in the Lake language.
sealed class TypeNode extends AstNode {
  /// Constructs a [TypeNode] with the given [span].
  const TypeNode({required super.span});
}

/// Represents a built-in base type (e.g., "i32", "string").
final class BaseTypeNode extends TypeNode {
  /// Creates a [BaseTypeNode] with the given [value] and [span].
  const BaseTypeNode({required this.value, required super.span});

  /// The name of the base type.
  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBaseTypeNode(this);

  @override
  List<Object?> get props => [value, span];
}

/// Base class for container type nodes (e.g., map, set, list).
sealed class ContainerTypeNode extends TypeNode {
  /// Constructs a [ContainerTypeNode] with the given [span].
  const ContainerTypeNode({required super.span});
}

/// Represents a map type (e.g., map<string, i32>).
final class MapTypeNode extends ContainerTypeNode {
  /// Creates a [MapTypeNode] with the given [keyType], [valueType], and [span].
  const MapTypeNode({
    required this.keyType,
    required this.valueType,
    required super.span,
  });

  /// The type of the map keys.
  final TypeNode keyType;

  /// The type of the map values.
  final TypeNode valueType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMapTypeNode(this);

  @override
  List<Object?> get props => [keyType, valueType, span];
}

/// Represents a set type (e.g., set<i32>).
final class SetTypeNode extends ContainerTypeNode {
  /// Creates a [SetTypeNode] with the given [elementType] and [span].
  const SetTypeNode({required this.elementType, required super.span});

  /// The type of the set elements.
  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSetTypeNode(this);

  @override
  List<Object?> get props => [elementType, span];
}

/// Represents a list type (e.g., list<string>).
final class ListTypeNode extends ContainerTypeNode {
  /// Creates a [ListTypeNode] with the given [elementType] and [span].
  const ListTypeNode({required this.elementType, required super.span});

  /// The type of the list elements.
  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListTypeNode(this);

  @override
  List<Object?> get props => [elementType, span];
}

/// Represents a stream type (e.g., stream<i32>).
final class StreamTypeNode extends TypeNode {
  /// Creates a [StreamTypeNode] with the given [elementType] and [span].
  const StreamTypeNode({required this.elementType, required super.span});

  /// The type of the stream elements.
  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStreamTypeNode(this);

  @override
  List<Object?> get props => [elementType, span];
}

/// Represents a user-defined or custom type.
final class CustomTypeNode extends TypeNode {
  /// Creates a [CustomTypeNode] with the given [value] and [span].
  const CustomTypeNode({required this.value, required super.span});

  /// The name of the custom type.
  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCustomTypeNode(this);

  @override
  List<Object?> get props => [value, span];
}

/// Represents the void type.
class VoidTypeNode extends TypeNode {
  /// Creates a [VoidTypeNode] with the given [span].
  const VoidTypeNode({required super.span});

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVoidTypeNode(this);

  @override
  List<Object?> get props => [span];
}

// Constants

/// Base class for all constant value nodes.
sealed class ConstValueNode extends AstNode {
  /// Constructs a [ConstValueNode] with the given [span].
  const ConstValueNode({required super.span});

  /// The kind of value (e.g., "literal integer", "identifier").
  String get valueKind;

  /// The type of value (e.g., "integer", "string").
  String get valueType;
}

/// Represents an integer constant value.
final class IntConstantNode extends ConstValueNode {
  /// Creates an [IntConstantNode] with the given [rawValue] and [span].
  IntConstantNode({required this.rawValue, required super.span});

  /// The integer value as a string.
  final String rawValue;

  /// The parsed integer value.
  late final int value = int.parse(rawValue);

  @override
  String get valueKind => 'literal integer';

  @override
  String get valueType => 'integer';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIntConstantNode(this);

  @override
  List<Object?> get props => [rawValue, span];
}

/// Represents a double constant value.
final class DoubleConstantNode extends ConstValueNode {
  /// Creates a [DoubleConstantNode] with the given [rawValue] and [span].
  DoubleConstantNode({required this.rawValue, required super.span});

  /// The double value as a string.
  final String rawValue;

  /// The parsed double value.
  late final double value = double.parse(rawValue);

  @override
  String get valueKind => 'literal double';

  @override
  String get valueType => 'double';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDoubleConstantNode(this);

  @override
  List<Object?> get props => [rawValue, span];
}

/// Represents a boolean constant value.
final class BoolConstantNode extends ConstValueNode {
  /// Creates a [BoolConstantNode] with the given [rawValue] and [span].
  BoolConstantNode({required this.rawValue, required super.span});

  /// The boolean value.
  final String rawValue;

  /// The parsed boolean value.
  late final bool value = rawValue == 'true';

  @override
  String get valueKind => 'literal boolean';

  @override
  String get valueType => 'bool';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBoolConstantNode(this);

  @override
  List<Object?> get props => [rawValue, span];
}

/// Represents a string literal constant value.
final class LiteralNode extends ConstValueNode {
  /// Creates a [LiteralNode] with the given [rawValue] and [span].
  LiteralNode({required this.rawValue, required super.span});

  /// The string literal value.
  final String rawValue;

  late final String value = rawValue.substring(1, rawValue.length - 1);

  @override
  String get valueKind => 'literal string';

  @override
  String get valueType => 'string';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteralNode(this);

  @override
  List<Object?> get props => [rawValue, span];
}

/// Represents a list constant value.
final class ConstListNode extends ConstValueNode {
  /// Creates a [ConstListNode] with the given [elements] and [span].
  const ConstListNode({required this.elements, required super.span});

  /// The list of constant value elements.
  final List<ConstValueNode> elements;

  @override
  String get valueKind => 'literal list';

  @override
  String get valueType => 'list';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstListNode(this);

  @override
  List<Object?> get props => [elements, span];
}

/// Represents a pair of constant values used in map entries.
/// This is a tuple-like structure for key-value pairs in a constant map.
typedef ConstMapNodePair = ({ConstValueNode key, ConstValueNode value});

/// Represents a map constant value.
final class ConstMapNode extends ConstValueNode {
  /// Creates a [ConstMapNode] with the given [entries] and [span].
  const ConstMapNode({required this.entries, required super.span});

  /// The list of map entries, each as a key-value pair of constant values.
  final List<ConstMapNodePair> entries;

  @override
  String get valueKind => 'literal map';

  @override
  String get valueType => 'map';

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitConstMapNode(this);

  @override
  List<Object?> get props => [entries, span];
}

/// Represents an identifier (reference to a named value).
final class IdentifierNode extends ConstValueNode {
  /// Creates an [IdentifierNode] with the given [value] and [span].
  const IdentifierNode({required this.value, required super.span});

  /// The identifier name.
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
