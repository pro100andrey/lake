part of 'ast_base.dart';

// --- TYPES ---

sealed class TypeNode extends AstNode {
  const TypeNode({required super.startOffset, required super.endOffset});
}

final class BaseTypeNode extends TypeNode {
  const BaseTypeNode({
    required this.name,
    required super.startOffset,
    required super.endOffset,
  });
  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBaseTypeNode(this);
}

sealed class ContainerTypeNode extends TypeNode {
  const ContainerTypeNode({
    required super.startOffset,
    required super.endOffset,
  });
}

final class MapTypeNode extends ContainerTypeNode {
  const MapTypeNode({
    required this.keyType,
    required this.valueType,
    required super.startOffset,
    required super.endOffset,
  });
  final TypeNode keyType;
  final TypeNode valueType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMapTypeNode(this);
}

final class SetTypeNode extends ContainerTypeNode {
  const SetTypeNode({
    required this.elementType,
    required super.startOffset,
    required super.endOffset,
  });
  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSetTypeNode(this);
}

final class ListTypeNode extends ContainerTypeNode {
  const ListTypeNode({
    required this.elementType,
    required super.startOffset,
    required super.endOffset,
  });
  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListTypeNode(this);
}

final class StreamTypeNode extends TypeNode {
  const StreamTypeNode({
    required this.elementType,
    required super.startOffset,
    required super.endOffset,
  });
  final TypeNode elementType;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStreamTypeNode(this);
}

final class CustomTypeNode extends TypeNode {
  const CustomTypeNode({
    required this.name,
    required super.startOffset,
    required super.endOffset,
  });
  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCustomTypeNode(this);
}

final class VoidTypeNode extends TypeNode {
  const VoidTypeNode({required super.startOffset, required super.endOffset});

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVoidTypeNode(this);
}

// --- LITERALS & EXPRESSIONS ---

sealed class LiteralValueNode extends AstNode {
  const LiteralValueNode({
    required super.startOffset,
    required super.endOffset,
  });
}

final class IntLiteralNode extends LiteralValueNode {
  const IntLiteralNode({
    required this.value,
    required super.startOffset,
    required super.endOffset,
  });
  final int value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIntLiteralNode(this);
}

final class DoubleLiteralNode extends LiteralValueNode {
  const DoubleLiteralNode({
    required this.value,
    required super.startOffset,
    required super.endOffset,
  });
  final double value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitDoubleLiteralNode(this);
}

final class BoolLiteralNode extends LiteralValueNode {
  const BoolLiteralNode({
    required this.value,
    required super.startOffset,
    required super.endOffset,
  });
  final bool value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBoolLiteralNode(this);
}

final class StringLiteralNode extends LiteralValueNode {
  const StringLiteralNode({
    required this.value,
    required super.startOffset,
    required super.endOffset,
  });
  final String value;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitStringLiteralNode(this);
}

final class IdentifierNode extends LiteralValueNode {
  const IdentifierNode({
    required this.name,
    required super.startOffset,
    required super.endOffset,
  });
  final String name;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIdentifierNode(this);
}

final class ListLiteralNode extends LiteralValueNode {
  const ListLiteralNode({
    required this.elements,
    required super.startOffset,
    required super.endOffset,
  });
  final List<LiteralValueNode> elements;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitListLiteralNode(this);
}

typedef MapLiteralEntry = ({LiteralValueNode key, LiteralValueNode value});

final class MapLiteralNode extends LiteralValueNode {
  const MapLiteralNode({
    required this.entries,
    required super.startOffset,
    required super.endOffset,
  });
  final List<MapLiteralEntry> entries;

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitMapLiteralNode(this);
}
