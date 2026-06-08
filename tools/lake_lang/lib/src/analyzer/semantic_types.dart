import '../parser/ast/ast_base.dart';

sealed class SemanticType {
  const SemanticType(this.name);

  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SemanticType &&
          other.runtimeType == runtimeType &&
          other.name == name);

  @override
  int get hashCode => name.hashCode;

  bool isAssignableTo(SemanticType other);
}

extension SemanticTypesCastExtension on SemanticType {
  T cast<T extends SemanticType>() => this as T;
}

final class BaseType extends SemanticType {
  const BaseType(super.name);

  static const boolT = BaseType('bool');
  static const byteT = BaseType('byte');
  static const i8T = BaseType('i8');
  static const i16T = BaseType('i16');
  static const i32T = BaseType('i32');
  static const i64T = BaseType('i64');
  static const doubleT = BaseType('double');
  static const stringT = BaseType('string');
  static const binaryT = BaseType('binary');
  static const uuidT = BaseType('uuid');

  static const values = [
    boolT,
    byteT,
    i8T,
    i16T,
    i32T,
    i64T,
    doubleT,
    stringT,
    binaryT,
    uuidT,
  ];

  static Map<String, BaseType> byName = {
    for (final type in values) type.name: type,
  };

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! BaseType) {
      return false;
    }

    const intTypes = [
      BaseType.i8T,
      BaseType.i16T,
      BaseType.i32T,
      BaseType.i64T,
    ];

    final thisIndex = intTypes.indexOf(this);
    final otherIndex = intTypes.indexOf(other);

    // If both are integer types, allow assignment from smaller to larger.
    if (thisIndex != -1 && otherIndex != -1) {
      return thisIndex <= otherIndex;
    }

    // Specific rules for other primitive types:

    if (this == BaseType.boolT && other == BaseType.byteT) {
      //  boolean (1 byte) can be assigned to byte (1 byte)
      return true;
    }

    if (this == BaseType.byteT && other == BaseType.i8T) {
      // byte (unsigned) can be assigned to i8 (signed)
      return true;
    }

    if (this == BaseType.i64T && other == BaseType.doubleT) {
      // i64 can be assigned to double (implicit conversion)
      return true;
    }

    return false;
  }
}

final class ListType extends SemanticType {
  ListType(this.elementType) : super('List<${elementType.name}>');

  final SemanticType elementType;

  @override
  bool operator ==(Object other) =>
      super == other && other is ListType && elementType == other.elementType;

  @override
  int get hashCode => Object.hash(super.hashCode, elementType);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ListType) {
      return false;
    }

    return elementType.isAssignableTo(other.elementType);
  }
}

final class MapType extends SemanticType {
  MapType(this.keyType, this.valueType)
    : super('Map<${keyType.name}, ${valueType.name}>');

  final SemanticType keyType;
  final SemanticType valueType;

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is MapType &&
      keyType == other.keyType &&
      valueType == other.valueType;

  @override
  int get hashCode => Object.hash(super.hashCode, keyType, valueType);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! MapType) {
      return false;
    }

    return keyType.isAssignableTo(other.keyType) &&
        valueType.isAssignableTo(other.valueType);
  }
}

final class SetType extends SemanticType {
  SetType(this.elementType) : super('Set<${elementType.name}>');

  final SemanticType elementType;

  @override
  bool operator ==(Object other) =>
      super == other && other is SetType && elementType == other.elementType;

  @override
  int get hashCode => Object.hash(super.hashCode, elementType);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! SetType) {
      return false;
    }

    return elementType.isAssignableTo(other.elementType);
  }
}

final class StreamType extends SemanticType {
  StreamType(this.elementType) : super('Stream<${elementType.name}>');

  final SemanticType elementType;

  @override
  bool operator ==(Object other) =>
      super == other && other is StreamType && elementType == other.elementType;

  @override
  int get hashCode => Object.hash(super.hashCode, elementType);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! StreamType) {
      return false;
    }

    return elementType.isAssignableTo(other.elementType);
  }
}

final class VoidType extends SemanticType {
  const VoidType() : super('void');

  @override
  bool isAssignableTo(SemanticType other) =>
      other is VoidType || other.name == 'void';
}

final class StructType extends SemanticType {
  StructType(this.declaration) : super(declaration.identifier.name);

  final StructDefinitionNode declaration;

  @override
  bool operator ==(Object other) =>
      super == other && other is StructType && declaration == other.declaration;

  @override
  int get hashCode => Object.hash(super.hashCode, declaration);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! StructType) {
      return false;
    }

    // For now, we assume struct types are not assignable to each other
    // unless they are the same type.
    return declaration.identifier.name == other.declaration.identifier.name;
  }
}

final class UnionType extends SemanticType {
  UnionType(this.declaration) : super(declaration.identifier.name);

  final UnionDefinitionNode declaration;

  @override
  bool operator ==(Object other) =>
      super == other && other is UnionType && declaration == other.declaration;

  @override
  int get hashCode => Object.hash(super.hashCode, declaration);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! UnionType) {
      return false;
    }

    // For now, we assume union types are not assignable to each other
    // unless they are the same type.
    return declaration.identifier.name == other.declaration.identifier.name;
  }
}

final class EnumType extends SemanticType {
  EnumType(this.declaration) : super(declaration.identifier.name);

  final EnumDefinitionNode declaration;

  @override
  bool operator ==(Object other) =>
      super == other && other is EnumType && declaration == other.declaration;

  @override
  int get hashCode => Object.hash(super.hashCode, declaration);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! EnumType) {
      return false;
    }

    // For now, we assume enum types are not assignable to each other
    // unless they are the same type.
    return declaration.identifier.name == other.declaration.identifier.name;
  }
}

final class TypedefType extends SemanticType {
  TypedefType(this.declaration) : super(declaration.identifier.name);

  final TypedefDefinitionNode declaration;

  late final SemanticType targetType;

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is TypedefType &&
      declaration == other.declaration;

  @override
  int get hashCode => Object.hash(super.hashCode, declaration);

  @override
  bool isAssignableTo(SemanticType other) => targetType.isAssignableTo(other);
}

final class ServiceType extends SemanticType {
  ServiceType(this.declaration) : super(declaration.identifier.name);

  final ServiceDefinitionNode declaration;

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is ServiceType &&
      declaration == other.declaration;

  @override
  int get hashCode => Object.hash(super.hashCode, declaration);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ServiceType) {
      return false;
    }

    // For now, we assume service types are not assignable to each other
    // unless they are the same type.
    return declaration.identifier.name == other.declaration.identifier.name;
  }
}

final class ExceptionType extends SemanticType {
  ExceptionType(this.declaration) : super(declaration.identifier.name);

  final ExceptionDefinitionNode declaration;

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is ExceptionType &&
      declaration == other.declaration;

  @override
  int get hashCode => Object.hash(super.hashCode, declaration);

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ExceptionType) {
      return false;
    }

    // For now, we assume exception types are not assignable to each other
    // unless they are the same type.
    return declaration.identifier.name == other.declaration.identifier.name;
  }
}
