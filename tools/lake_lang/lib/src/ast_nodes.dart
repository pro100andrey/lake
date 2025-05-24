// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'package:equatable/equatable.dart';

sealed class AstNode extends Equatable {
  const AstNode();

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  bool get stringify => true;
}

/// Base class for all Abstract Syntax Tree nodes.
/// No need for Equatable on base class unless it has properties

/// Represents the top-level document structure.
final class Document extends AstNode {
  const Document(this.headers, this.definitions);

  final List<Header> headers;
  final List<Definition> definitions;

  @override
  List<Object?> get props => [headers, definitions];
}

/// --- Headers ---

/// Base class for header definitions (e.g., import, namespace).
abstract class Header extends AstNode {
  const Header();
}

/// Represents an 'import' declaration.
final class Import extends Header {
  const Import(this.literal);

  final String literal;

  @override
  List<Object?> get props => [literal];
}

/// Represents a 'namespace' declaration.
final class Namespace extends Header {
  const Namespace(this.scope, this.identifier);

  final String scope;
  final Identifier identifier;

  @override
  List<Object?> get props => [scope, identifier];
}

/// --- Identifiers ---

/// Represents an identifier (e.g., variable names, type names).
final class Identifier extends AstNode {
  const Identifier(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// --- Definitions ---

/// Base class for all top-level definitions (e.g., const, enum, struct,
/// service).
abstract class Definition extends AstNode {
  const Definition();
}

/// Represents a 'const' definition.
final class Const extends AstNode {
  const Const(this.name, this.type, this.value);

  final Identifier name;
  final TypeAnnotation type;
  final ConstValue value;

  @override
  List<Object?> get props => [name, type, value];
}

/// Represents a 'typedef' definition.
final class Typedef extends Definition {
  const Typedef(this.name, this.type);

  final Identifier name;
  final TypeAnnotation type;

  @override
  List<Object?> get props => [name, type];
}

/// Represents an 'enum' definition.
final class Enum extends Definition {
  const Enum(this.name, this.values);

  final Identifier name;
  final List<EnumValue> values;

  @override
  List<Object?> get props => [name, values];
}

/// Represents an entry within an 'enum' definition.
final class EnumValue extends AstNode {
  const EnumValue(this.identifier, {this.intConstant});

  final Identifier identifier;
  final IntConstant? intConstant;

  @override
  List<Object?> get props => [identifier, intConstant];
}

/// Represents a 'struct' definition.
final class Struct extends Definition {
  const Struct(this.name, this.fields);

  final Identifier name;
  final List<Field> fields;

  @override
  List<Object?> get props => [name, fields];
}

/// Represents an 'exception' definition.
final class ExceptionDef extends Definition {
  const ExceptionDef(this.name, this.fields);

  final Identifier name;
  final List<Field> fields;

  @override
  List<Object?> get props => [name, fields];
}

/// Represents a 'service' definition.
final class Service extends Definition {
  const Service(this.name, this.methods, {this.extendedService});
  final Identifier name;
  final Identifier? extendedService;
  final List<Method> methods;

  @override
  List<Object?> get props => [name, methods, extendedService];
}

/// --- Fields ---

/// Represents a field within a struct or exception.
final class Field extends AstNode {
  const Field(
    this.name,
    this.type, {
    this.fieldId,
    this.isRequired = false,
    this.defaultValue,
  });

  final int? fieldId;
  final Identifier name;
  final TypeAnnotation type;
  final bool isRequired;
  final ConstValue? defaultValue;

  @override
  List<Object?> get props => [fieldId, name, type, isRequired, defaultValue];
}

/// --- Methods ---

/// Represents a function/method within a service.
final class Method extends AstNode {
  const Method(
    this.name,
    this.returnType, {
    this.parameters = const [],
    this.throws,
  });

  final Identifier name;
  final TypeAnnotation returnType;
  final List<Field> parameters;
  final Throws? throws;

  @override
  List<Object?> get props => [name, returnType, parameters, throws];
}

/// Represents a 'throws' clause on a method.
final class Throws extends AstNode {
  const Throws(this.exceptions);

  final List<Field> exceptions;

  @override
  List<Object?> get props => [exceptions];
}

/// --- Type Annotations ---

/// Base class for all type annotations (e.g., BaseType, ContainerType, Identifier).
abstract class TypeAnnotation extends AstNode {
  const TypeAnnotation();
}

/// Represents a base type (e.g., 'bool', 'string', 'i32') or a custom identifier type.
final class BaseType extends TypeAnnotation {
  const BaseType(this.identifier);

  final Identifier identifier; // e.g., 'bool', 'string', 'MyStruct'

  @override
  List<Object?> get props => [identifier];
}

/// Base class for container types (Map, Set, List, Stream).
abstract class ContainerType extends TypeAnnotation {
  const ContainerType();
}

/// Represents a 'map' container type.
final class MapType extends ContainerType {
  const MapType(this.keyType, this.valueType);

  final TypeAnnotation keyType;
  final TypeAnnotation valueType;

  @override
  List<Object?> get props => [keyType, valueType];
}

/// Represents a 'set' container type.
final class SetType extends ContainerType {
  const SetType(this.itemType);
  final TypeAnnotation itemType;

  @override
  List<Object?> get props => [itemType];
}

/// Represents a 'list' container type.
final class ListType extends ContainerType {
  const ListType(this.itemType);

  final TypeAnnotation itemType;

  @override
  List<Object?> get props => [itemType];
}

/// Represents a 'stream' container type.
final class StreamType extends ContainerType {
  const StreamType(this.itemType);

  final TypeAnnotation itemType;

  @override
  List<Object?> get props => [itemType];
}

/// --- Constant Values ---

/// Base class for all constant values.
abstract class ConstValue extends AstNode {
  const ConstValue();
}

/// Represents an integer constant value.
final class IntConstant extends ConstValue {
  const IntConstant(this.value);
  final int value;

  @override
  List<Object?> get props => [value];
}

/// Represents a double/floating-point constant value.
final class DoubleConstant extends ConstValue {
  const DoubleConstant(this.value);
  final String value; // Store as String to preserve exact representation

  @override
  List<Object?> get props => [value];
}

/// Represents a string literal constant value.
final class StringLiteral extends ConstValue {
  const StringLiteral(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

/// Represents an identifier used as a constant value (e.g., another const).
final class ConstIdentifier extends ConstValue {
  const ConstIdentifier(this.identifier);

  final Identifier identifier;

  @override
  List<Object?> get props => [identifier];
}

/// Represents a list of constant values.
final class ConstList extends ConstValue {
  const ConstList(this.values);

  final List<ConstValue> values;

  @override
  List<Object?> get props => [values];
}

/// Represents a map of constant values.
final class ConstMap extends ConstValue {
  const ConstMap(this.entries);

  final Map<ConstValue, ConstValue> entries;

  @override
  List<Object?> get props => [entries];
}
