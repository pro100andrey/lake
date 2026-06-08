import 'package:source_span/source_span.dart';
import '../../parser/ast/ast_base.dart';
import '../errors/error_reporter.dart';
import '../semantic_types.dart';
import 'symbol_entry.dart';

class Scope {
  Scope({this.parent});

  final Map<String, SymbolEntry> _symbols = {};
  final Scope? parent;

  void addSymbol({
    required String name,
    required SymbolKind kind,
    required AstNode declaration,
    required SourceSpan span,
    required ErrorReporter reporter,
    SemanticType? resolvedType,
  }) {
    if (_symbols.containsKey(name)) {
      final existingEntry = _symbols[name]!;
      reporter.reportDuplicateDeclaration(
        name: name,
        span: span,
        previousDeclarationSpan: existingEntry.span,
      );

      return;
    }

    _symbols[name] = SymbolEntry(
      name: name,
      kind: kind,
      declaration: declaration,
      resolvedType: resolvedType,
      span: span,
    );
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
      _errorReporter.reportGeneric(
        message: 'Cannot pop the global scope.',
        span: SourceSpan(SourceLocation(0), SourceLocation(0), ''),
      );
      return;
    }

    _currentScope = _currentScope!.parent;
  }

  void addSymbol({
    required String name,
    required SymbolKind kind,
    required AstNode declaration,
    required SourceSpan span,
    required SemanticType? resolvedType,
  }) {
    if (_currentScope == null) {
      _errorReporter.reportGeneric(
        message:
            'Cannot add symbol "$name": no active scope. '
            'This is an internal error.',
        span: span,
      );
      return;
    }

    _currentScope!.addSymbol(
      name: name,
      kind: kind,
      declaration: declaration,
      span: span,
      reporter: _errorReporter,
      resolvedType: resolvedType,
    );
  }

  SymbolEntry? lookup(String name, SourceSpan span) {
    if (_currentScope == null) {
      _errorReporter.reportGeneric(
        message:
            'Cannot lookup symbol "$name": no active scope. '
            'This is an internal error.',
        span: span,
      );
      return null;
    }

    final symbol = _currentScope!.lookup(name);

    if (symbol == null) {
      _errorReporter.reportUndefinedSymbol(name: name, span: span);
      return null;
    }

    return symbol;
  }

  Scope? get currentScope => _currentScope;
}
