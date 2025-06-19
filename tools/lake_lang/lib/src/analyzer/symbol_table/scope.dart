// ignore_for_file: avoid_print

import 'package:equatable/equatable.dart';


import '../errors/error_reporter.dart';
import 'symbol_entry.dart';

/// Represents a single lexical scope in the Lake language.
///
/// A scope manages the symbols declared directly within its boundaries and
/// provides a link to its parent scope for symbol resolution.
class Scope extends Equatable {
  /// Creates a new scope.
  ///
  /// [parent]: The parent scope of this new scope. If `null`, this scope
  /// is considered a root (global) scope.
  Scope({this.parent, SymbolEntry? ownerSymbol, ErrorReporter? errorReporter})
    : _ownerSymbol = ownerSymbol,
      _errorReporter = errorReporter;

  /// The parent scope, or `null` if this is the global (root) scope.
  final Scope? parent;

  final SymbolEntry? _ownerSymbol;

  SymbolEntry? get ownerSymbol => _ownerSymbol;

  /// The error reporter instance for reporting errors related to this scope.
  final ErrorReporter? _errorReporter;

  /// A map storing symbols directly declared within this scope.
  /// Keys are symbol names (String), values are the corresponding SymbolEntry
  /// objects.
  final Map<String, SymbolEntry> _symbols = {};

  /// Adds a new symbol to this scope.
  ///
  /// Reports a SemanticError if a symbol with the same name already exists
  /// in this specific scope.
  ///
  /// [symbol]: The specialized [SymbolEntry] to add.
  bool addSymbol(SymbolEntry symbol, String filePath) {
    print(
      'Scope: '
      'Adding symbol: $symbol to scope: '
      '${_ownerSymbol?.name ?? 'global'}',
    );

    if (_symbols.containsKey(symbol.name)) {
      final existingEntry = _symbols[symbol.name]!;
      _errorReporter?.reportDuplicateDeclaration(
        name: symbol.name,
        span: symbol.span, // Span of the new (duplicate) declaration
        // Span of the original declaration
        previousDeclarationSpan: existingEntry.span,
        filePath: filePath,
      );

      return false;
    }

    _symbols[symbol.name] = symbol;
    return true;
  }

  /// Looks up a symbol by [name], searching from this scope upwards through
  /// its parent scopes.
  ///
  /// Returns the [SymbolEntry] if found, otherwise `null`.
  /// This method does *not* report an error if the symbol is not found;
  /// error reporting is left to the caller (e.g., SymbolTableBuilder).
  SymbolEntry? lookup(String name) {
    final entry = _symbols[name];
    
    if (entry != null) {
      return entry;
    }
    // If not found in this scope, try the parent scope.
    return parent?.lookup(name);
  }

  /// Replaces an existing symbol in *this* scope with an updated version.
  ///
  /// This is used during the second pass to enrich symbol entries with
  /// resolved types and members. It only replaces if the symbol already exists
  /// in *this* specific scope, not in parent scopes.
  ///
  /// Returns `true` if the symbol was replaced, `false` if the symbol
  /// with the given name was not found in this scope.
  bool replaceSymbol(SymbolEntry updatedEntry) {
    if (_symbols.containsKey(updatedEntry.name)) {
      _symbols[updatedEntry.name] = updatedEntry;

      return true;
    }

    return false; // Symbol not found in this specific scope
  }

  /// Checks if a symbol with the given [name] is declared directly within this
  /// scope.
  bool contains(String name) => _symbols.containsKey(name);

  /// Returns an unmodifiable map of symbols directly defined in this scope.
  /// This provides a snapshot of the symbols without allowing external
  /// modification.
  Map<String, SymbolEntry> get symbolsInScope => Map.unmodifiable(_symbols);

  @override
  List<Object?> get props => [_ownerSymbol, _symbols];
}
