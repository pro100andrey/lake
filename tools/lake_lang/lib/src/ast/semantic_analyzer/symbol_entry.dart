import 'package:equatable/equatable.dart';
import 'package:source_span/source_span.dart';

import '../../../lake_lang.dart';
import 'semantic_types.dart';

enum SymbolKind {
  constant,
  type,
  field,
  function,
  parameter,
  enumMember,
  service,
  exception,
}

final class SymbolEntry extends Equatable {
  const SymbolEntry({
    required this.name,
    required this.kind,
    required this.declaration,
    required this.span,
    this.resolvedType,
  });

  /// The name of the symbol as it appears in the source code.
  final String name;

  /// The kind of symbol (e.g., constant, type, function).
  final SymbolKind kind;

  /// The Abstract Syntax Tree (AST) node that corresponds to the declaration
  /// of this symbol. This provides direct access to the syntactic details.
  final AstNode declaration;

  /// The resolved [SemanticType] of this symbol, if available.
  /// This will be determined during type-checking phase. It can be null if the
  /// type has't been resolved yet or if it's a symbol kind that  doesn't
  /// directly have a single semantic type (e.g., a service itself).
  final SemanticType? resolvedType;

  /// The [SourceSpan] that indicating the location of the symbol's declaration
  /// in the source code. Useful for error reporting and debugging.
  final SourceSpan span;

  @override
  List<Object?> get props => [name, kind, declaration, resolvedType, span];
}
