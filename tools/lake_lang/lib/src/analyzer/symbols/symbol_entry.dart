import '../../parser/ast/ast_base.dart';
import '../semantic_types.dart';

enum SymbolKind {
  constant,
  type,
  field,
  method,
  parameter,
  enumMember,
  service,
  exception,
}

class SymbolEntry {
  SymbolEntry({
    required this.name,
    required this.kind,
    required this.declaration,
    this.resolvedType,
  });

  /// The name of the symbol as it appears in the source code.
  final String name;

  /// The kind of symbol (e.g., constant, type, method).
  final SymbolKind kind;

  /// The Abstract Syntax Tree (AST) node that corresponds to the declaration
  /// of this symbol. This provides direct access to the syntactic details.
  final AstNode declaration;

  /// The resolved [SemanticType] of this symbol, if available.
  /// This will be determined during type-checking phase. It can be null if the
  /// type has't been resolved yet or if it's a symbol kind that  doesn't
  /// directly have a single semantic type (e.g., a service itself).
  SemanticType? resolvedType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymbolEntry &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          kind == other.kind &&
          declaration == other.declaration &&
          resolvedType == other.resolvedType;

  @override
  int get hashCode => Object.hash(name, kind, declaration, resolvedType);
}
