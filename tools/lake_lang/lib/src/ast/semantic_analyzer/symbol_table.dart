import 'package:source_span/source_span.dart';

import '../../../lake_lang.dart';
import 'semantic_types.dart';

class SymbolEntry {
  const SymbolEntry(this.name, this.declaration, [this.resolvedType]);

  final String name;
  final AstNode declaration;
  final SemanticType? resolvedType;
}

class Scope {
  Scope({this.parent});

  final Map<String, SymbolEntry> _symbols = {};
  final Scope? parent;

  void addSymbol(
    String name,
    AstNode declaration,
    SemanticType? resolvedType,
    SourceSpan span,
    ErrorReporter reporter,
  ) {
    if (_symbols.containsKey(name)) {
      reporter.reportDuplicateDeclaration(name, span);
      return;
    }

    _symbols[name] = SymbolEntry(name, declaration, resolvedType);
  }

  SymbolEntry? lookup(String name) {
    final entry = _symbols[name];
    if (entry != null) {
      return entry;
    }

    return parent?.lookup(name);
  }

  bool contains(String name) => _symbols.containsKey(name);

  Map<String, SymbolEntry> get symbolsInScope => Map.unmodifiable(_symbols);
}

class SymbolTable {
  /// Creates a new symbol table and initializes it with a global scope.
  SymbolTable(this._errorReporter) {
    _currentScope = Scope();
  }

  Scope? _currentScope;
  final ErrorReporter _errorReporter;

  void pushScope() {
    final newScope = Scope(parent: _currentScope);
    _currentScope = newScope;
  }

  void popScope() {
    if (_currentScope?.parent == null) {
      _errorReporter.reportError(
        'Cannot pop the global scope.',
        SourceSpan(SourceLocation(0), SourceLocation(0), ''),
      );
      return;
    }

    _currentScope = _currentScope!.parent;
  }

  void addSymbol(
    String name,
    AstNode declaration,
    SourceSpan span, [
    SemanticType? resolvedType,
  ]) {
    if (_currentScope == null) {
      _errorReporter.reportError(
        'Cannot add symbol "$name": no active scope. '
        'This is an internal error.',
        span,
      );
      return;
    }

    _currentScope!.addSymbol(
      name,
      declaration,
      resolvedType,
      span,
      _errorReporter,
    );
  }

  SymbolEntry? lookup(String name, SourceSpan span) {
    if (_currentScope == null) {
      _errorReporter.reportError(
        'Cannot lookup symbol "$name": no active scope. '
        'This is an internal error.',
        span,
      );
      return null;
    }

    final symbol = _currentScope!.lookup(name);

    if (symbol == null) {
      _errorReporter.reportUndefinedSymbol(name, span);
      return null;
    }

    return symbol;
  }

  Scope? get currentScope => _currentScope;
}
