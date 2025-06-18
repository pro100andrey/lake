import 'package:equatable/equatable.dart';

import '../../analyzer/semantic_types.dart';
import '../../ast/base/types.dart';
import '../../ast/nodes/ast_nodes.dart';

sealed class SymbolEntry extends Equatable {
  const SymbolEntry({
    required this.name,
    required this.declaration,
    required this.span,
  });

  /// The name of the symbol as it appears in the source code.
  final String name;

  /// The Abstract Syntax Tree (AST) node that corresponds to the declaration
  /// of this symbol. This provides direct access to the syntactic details.
  final AstNode declaration;

  /// The [Span] that indicating the location of the symbol's declaration
  /// in the source code. Useful for error reporting and debugging.
  final Span span;

  @override
  List<Object?> get props => [name, declaration, span];
}

final class TypedSymbolEntry extends SymbolEntry {
  const TypedSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
    this.resolvedType = const SemanticUnresolvedType(),
  });

  final SemanticType resolvedType;

  /// copyWith constructor for creating a new instance with the same
  /// properties, but allowing for changes to the `resolvedType`.
  TypedSymbolEntry copyWith({
    String? name,
    AstNode? declaration,
    Span? span,
    SemanticType? resolvedType,
  }) => TypedSymbolEntry(
    name: name ?? this.name,
    declaration: declaration ?? this.declaration,
    span: span ?? this.span,
    resolvedType: resolvedType ?? this.resolvedType,
  );

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
    required super.resolvedType,
  });
}

final class FunctionSymbolEntry extends TypedSymbolEntry {
  const FunctionSymbolEntry({
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
    required super.resolvedType,
  });
}

final class EnumSymbolEntry extends TypedSymbolEntry {
  const EnumSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
    required super.resolvedType,
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
    required super.resolvedType,
  });
}

final class ExceptionSymbolEntry extends TypedSymbolEntry {
  const ExceptionSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
    required super.resolvedType,
  });
}

final class ServiceSymbolEntry extends TypedSymbolEntry {
  const ServiceSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
    required super.resolvedType,
  });
}

final class MethodSymbolEntry extends TypedSymbolEntry {
  const MethodSymbolEntry({
    required super.name,
    required super.declaration,
    required super.span,
    required super.resolvedType,
  });
}
