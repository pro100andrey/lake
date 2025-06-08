import 'package:equatable/equatable.dart';

import '../nodes/ast_nodes.dart';

sealed class SemanticType extends Equatable {
  const SemanticType(this.name);

  final String name;

  @override
  List<Object?> get props => [name];

  bool isAssignableTo(SemanticType other);
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
  static const voidT = BaseType('void');

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
    voidT,
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

    if (this == BaseType.boolT && other == BaseType.byteT) {
      // bool can be assigned to byte
      return true;
    }

    if (this == BaseType.byteT && other == BaseType.i8T) {
      // byte can be assigned to i8
      return true;
    }

    if (this == BaseType.i32T && other == BaseType.i64T) {
      // i32 can be assigned to i64
      return true;
    }

    return false;
  }
}

final class ListType extends SemanticType {
  ListType(this.elementType) : super('List<${elementType.name}>');

  final SemanticType elementType;

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

final class StructType extends SemanticType {
  StructType(this.declaration) : super(declaration.identifier.value);

  final StructDefinitionNode declaration;

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
    return declaration.identifier.value == other.declaration.identifier.value;
  }
}

final class StreamType extends SemanticType {
  StreamType(this.innerType) : super('Stream<${innerType.name}>');

  final SemanticType innerType;

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! StreamType) {
      return false;
    }

    return innerType.isAssignableTo(other.innerType);
  }
}

final class EnumType extends SemanticType {
  EnumType(this.declaration) : super(declaration.identifier.value);

  final EnumDefinitionNode declaration;

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
    return declaration.identifier.value == other.declaration.identifier.value;
  }
}

final class TypedefType extends SemanticType {
  TypedefType(this.declaration) : super(declaration.identifier.value);

  final TypedefDefinitionNode declaration;

  void setTargetType(SemanticType targetType) {
    // This method can be used to set the target type of the typedef.
    // It can be extended later to handle more complex scenarios.
    // declaration.targetType = targetType;
  }

  @override
  bool isAssignableTo(SemanticType other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! TypedefType) {
      return false;
    }

    // For now, we assume typedef types are not assignable to each other
    // unless they are the same type.
    return declaration.identifier.value == other.declaration.identifier.value;
  }
}

final class ServiceType extends SemanticType {
  ServiceType(this.declaration) : super(declaration.identifier.value);

  final ServiceDefinitionNode declaration;

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
    return declaration.identifier.value == other.declaration.identifier.value;
  }
}

final class ExceptionType extends SemanticType {
  ExceptionType(this.declaration) : super(declaration.identifier.value);

  final ExceptionDefinitionNode declaration;

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
    return declaration.identifier.value == other.declaration.identifier.value;
  }
}
