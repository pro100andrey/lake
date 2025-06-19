import 'package:equatable/equatable.dart';

import '../../analyzer/semantic_types.dart';
import '../../ast/base/types.dart';
import '../../ast/nodes/ast_nodes.dart';

base class SymbolEntry extends Equatable {
  const SymbolEntry({
    required this.name,
    required this.declaration,
    required this.span,
    this.resolvedType = const SemanticUnresolvedType(),
  });

  /// The name of the symbol as it appears in the source code.
  final String name;

  /// The Abstract Syntax Tree (AST) node that corresponds to the declaration
  /// of this symbol. This provides direct access to the syntactic details.
  final AstNode declaration;

  /// The [Span] that indicating the location of the symbol's declaration
  /// in the source code. Useful for error reporting and debugging.
  final Span span;

  final SemanticType resolvedType;

  SymbolEntry copyWith({
    String? name,
    AstNode? declaration,
    Span? span,
    SemanticType? resolvedType,
  }) => SymbolEntry(
    name: name ?? this.name,
    declaration: declaration ?? this.declaration,
    span: span ?? this.span,
    resolvedType: resolvedType ?? this.resolvedType,
  );

  @override
  List<Object?> get props => [name, declaration, span];
}

sealed class TypedSymbolEntry extends SymbolEntry {
  const TypedSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });

  // final SemanticType resolvedType;

  // final Scope? childScope;

  /// copyWith constructor for creating a new instance with the same
  /// properties, but allowing for changes to the `resolvedType`.
  // TypedSymbolEntry copyWith({
  //   String? name,
  //   AstNode? declaration,
  //   Span? span,
  //   SemanticType? resolvedType,
  //   Scope? childScope,
  // }) => TypedSymbolEntry(
  //   name: name ?? this.name,
  //   declaration: declaration ?? this.declaration,
  //   span: span ?? this.span,
  //   resolvedType: resolvedType ?? this.resolvedType,
  //   childScope: childScope ?? this.childScope,
  // );

  @override
  List<Object?> get props => [name, declaration, span, resolvedType];
}

final class ConstSymbolEntry extends TypedSymbolEntry {
  const ConstSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });

  LiteralValueNode get value => declaration.cast<ConstDefinitionNode>().value;
}

final class FieldSymbolEntry extends TypedSymbolEntry {
  const FieldSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class ParameterSymbolEntry extends TypedSymbolEntry {
  const ParameterSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class TypedefSymbolEntry extends TypedSymbolEntry {
  const TypedefSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class StructSymbolEntry extends TypedSymbolEntry {
  const StructSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class EnumSymbolEntry extends TypedSymbolEntry {
  const EnumSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class EnumMemberSymbolEntry extends TypedSymbolEntry {
  const EnumMemberSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class UnionSymbolEntry extends TypedSymbolEntry {
  const UnionSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class ExceptionSymbolEntry extends TypedSymbolEntry {
  const ExceptionSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class ServiceSymbolEntry extends TypedSymbolEntry {
  const ServiceSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

final class MethodSymbolEntry extends TypedSymbolEntry {
  const MethodSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
  });
}

extension SemanticTypeCastExtension on SymbolEntry {
  T cast<T extends SymbolEntry>() => this as T;
}
