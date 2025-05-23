import 'package:equatable/equatable.dart';

/// Base class for all Abstract Syntax Tree nodes.
/// No need for Equatable on base class unless it has properties

/// Represents the top-level document structure.
final class Document extends Equatable {
  const Document(this.headers, this.definitions);

  final List<Header> headers;
  final List<Definition> definitions;

  @override
  List<Object?> get props => [headers, definitions];

  @override
  String toString() => 'Document(headers: $headers, definitions: $definitions)';
}

/// --- Headers ---

/// Base class for header definitions (e.g., import, namespace).
abstract class Header extends Equatable {
  const Header();
}

/// Represents an 'import' declaration.
final class Import extends Header {
  const Import(this.literal);

  final String literal;

  @override
  List<Object?> get props => [literal];

  @override
  String toString() => 'Import("$literal")';
}

/// Represents a 'namespace' declaration.
final class Namespace extends Header {
  const Namespace(this.scope, this.identifier);

  final String scope;
  final Identifier identifier;

  @override
  List<Object?> get props => [scope, identifier];

  @override
  String toString() => 'Namespace(scope: $scope, name: $identifier)';
}

/// --- Identifiers ---

/// Represents an identifier (e.g., variable names, type names).
final class Identifier extends Equatable {
  const Identifier(this.name);

  final String name;

  @override
  List<Object?> get props => [name];

  @override
  String toString() => 'Identifier($name)';
}

/// --- Definitions ---

/// Base class for all top-level definitions (e.g., const, enum, struct,
/// service).
abstract class Definition extends Equatable {
  const Definition();
}

/// Represents a 'const' definition.
final class Const extends Definition {
  const Const(this.name, this.type, this.value);

  final Identifier name;
  final TypeAnnotation type;
  final ConstValue value;

  @override
  List<Object?> get props => [name, type, value];

  @override
  String toString() => 'Const($name: $type = $value)';
}

/// Represents a 'typedef' definition.
final class Typedef extends Definition {
  const Typedef(this.name, this.type);

  final Identifier name;
  final TypeAnnotation type;

  @override
  List<Object?> get props => [name, type];

  @override
  String toString() => 'Typedef($name = $type)';
}

/// Represents an 'enum' definition.
final class Enum extends Definition {
  const Enum(this.name, this.values);

  final Identifier name;
  final List<EnumValue> values;

  @override
  List<Object?> get props => [name, values];

  @override
  String toString() =>
      'Enum($name, values: [${values.map((v) => v.toString()).join(', ')}])';
}

/// Represents an entry within an 'enum' definition.
final class EnumValue extends Equatable {
  const EnumValue(this.identifier, this.intConstant);

  final Identifier identifier;
  final IntConstantValue? intConstant;

  @override
  List<Object?> get props => [identifier, intConstant];

  @override
  String toString() =>
      'EnumValue($identifier${intConstant != null ? ' = $intConstant' : ''})';
}

/// Represents a 'struct' definition.
final class Struct extends Definition {
  const Struct(this.name, this.fields);

  final Identifier name;
  final List<Field> fields;

  @override
  List<Object?> get props => [name, fields];

  @override
  String toString() =>
      'Struct($name, fields: [${fields.map((f) => f.toString()).join(', ')}])';
}

/// Represents an 'exception' definition.
final class ExceptionDef extends Definition {
  const ExceptionDef(this.name, this.fields);

  final Identifier name;
  final List<Field> fields;

  @override
  List<Object?> get props => [name, fields];

  @override
  String toString() {
    final buffer = StringBuffer('ExceptionDef($name, fields: [');
    for (var i = 0; i < fields.length; i++) {
      buffer.write(fields[i].toString());
      if (i < fields.length - 1) {
        buffer.write(', ');
      }
    }

    buffer.write('])');

    return buffer.toString();
  }
}

/// Represents a 'service' definition.
final class Service extends Definition {
  const Service(this.name, this.methods, {this.extendedService});
  final Identifier name;
  final Identifier? extendedService;
  final List<Method> methods;

  @override
  List<Object?> get props => [name, methods, extendedService];

  @override
  String toString() {
    final buffer = StringBuffer('Service($name');

    if (extendedService != null) {
      buffer.write(' extends $extendedService');
    }

    buffer.write(
      ', methods: [${methods.map((m) => m.toString()).join(', ')}])',
    );

    return buffer.toString();
  }
}

/// --- Fields ---

/// Represents a field within a struct or exception.
final class Field extends Equatable {
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

  @override
  String toString() {
    final buffer = StringBuffer();
    if (fieldId != null) {
      buffer.write('$fieldId: ');
    }

    if (isRequired) {
      buffer.write('required ');
    }

    buffer.write('$type ${name.name}');

    if (defaultValue != null) {
      buffer.write(' = $defaultValue');
    }

    return 'Field($buffer)';
  }
}

/// --- Methods ---

/// Represents a function/method within a service.
final class Method extends Equatable {
  const Method(
    this.name,
    this.returnType, {
    this.parameters = const [],
    this.throws,
  });

  final Identifier name;
  final TypeAnnotation returnType;
  final List<Field> parameters; // Input fields
  final Throws? throws; // Throws clause

  @override
  List<Object?> get props => [name, returnType, parameters, throws];

  @override
  String toString() {
    final buffer = StringBuffer('Method($name(')
      ..write(parameters.map((p) => p.toString()).join(', '))
      ..write(') -> $returnType');

    if (throws != null) {
      buffer.write(' throws $throws');
    }

    buffer.write(')');

    return buffer.toString();
  }
}

/// Represents a 'throws' clause on a method.
final class Throws extends Equatable {
  const Throws(this.exceptions);

  final List<Field> exceptions;

  @override
  List<Object?> get props => [exceptions];

  @override
  String toString() =>
      'Throws([${exceptions.map((e) => e.toString()).join(', ')}])';
}

/// --- Type Annotations ---

/// Represents a type annotation for fields, function return types, etc.
final class TypeAnnotation extends Equatable {
  const TypeAnnotation(this.referenceIdentifier, {this.isList = false});
  final Identifier referenceIdentifier;
  final bool isList;

  @override
  List<Object?> get props => [referenceIdentifier, isList];

  @override
  String toString() => isList
      ? 'List<${referenceIdentifier.name}>'
      : referenceIdentifier.toString();
}

/// Base class for container types (Map, Set, Stream).
abstract class ContainerType extends Equatable {
  const ContainerType();
}

/// Represents a 'map' container type.
final class MapType extends ContainerType {
  const MapType(this.keyType, this.valueType);
  final TypeAnnotation keyType;
  final TypeAnnotation valueType;

  @override
  List<Object?> get props => [keyType, valueType];

  @override
  String toString() => 'Map<$keyType, $valueType>';
}

/// Represents a 'set' container type.
final class SetType extends ContainerType {
  const SetType(this.itemType);
  final TypeAnnotation itemType;

  @override
  List<Object?> get props => [itemType];

  @override
  String toString() => 'Set<$itemType>';
}

/// Represents a 'stream' container type.
final class StreamType extends ContainerType {
  const StreamType(this.itemType);

  final TypeAnnotation itemType;

  @override
  List<Object?> get props => [itemType];

  @override
  String toString() => 'Stream<$itemType>';
}

/// --- Constant Values ---

/// Base class for all constant values.
abstract class ConstValue extends Equatable {
  const ConstValue();
}

/// Represents an integer constant value.
final class IntConstantValue extends ConstValue {
  const IntConstantValue(this.value);
  final String value; // Store as String to preserve exact representation

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'IntConstantValue($value)';
}

/// Represents a double/floating-point constant value.
final class DoubleConstantValue extends ConstValue {
  const DoubleConstantValue(this.value);
  final String value; // Store as String to preserve exact representation

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'DoubleConstantValue($value)';
}

/// Represents a string literal constant value.
final class StringLiteral extends ConstValue {
  const StringLiteral(this.value);
  final String value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'StringLiteral("$value")';
}

/// Represents an identifier used as a constant value (e.g., another const).
final class ConstIdentifier extends ConstValue {
  const ConstIdentifier(this.identifier);

  final Identifier identifier;

  @override
  List<Object?> get props => [identifier];

  @override
  String toString() => 'ConstIdentifier(${identifier.name})';
}

/// Represents a list of constant values.
final class ConstList extends ConstValue {
  const ConstList(this.values);

  final List<ConstValue> values;

  @override
  List<Object?> get props => [values];

  @override
  String toString() =>
      'ConstList([${values.map((v) => v.toString()).join(', ')}])';
}

/// Represents a map of constant values.
final class ConstMap extends ConstValue {
  const ConstMap(this.entries);

  final Map<ConstValue, ConstValue> entries;

  @override
  List<Object?> get props => [entries];

  @override
  String toString() {
    final buffer = StringBuffer('ConstMap({');

    entries.forEach((key, value) {
      buffer.write('$key: $value, ');
    });

    buffer.write('})');

    return buffer.toString();
  }
}
