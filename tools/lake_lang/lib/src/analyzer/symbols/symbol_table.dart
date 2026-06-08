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
    required ErrorReporter reporter,
    SemanticType? resolvedType,
  }) {
    if (_symbols.containsKey(name)) {
      final existingEntry = _symbols[name]!;
      reporter.reportDuplicateDeclaration(
        name: name,
        startOffset: declaration.startOffset,
        endOffset: declaration.endOffset,
        prevStart: existingEntry.declaration.startOffset,
        prevEnd: existingEntry.declaration.endOffset,
      );

      return;
    }

    _symbols[name] = SymbolEntry(
      name: name,
      kind: kind,
      declaration: declaration,
      resolvedType: resolvedType,
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
    _globalScope = Scope();
    _currentScope = _globalScope;
  }

  late final Scope _globalScope;
  Scope? _currentScope;
  final ErrorReporter _errorReporter;
  final List<SymbolTable> importedTables = [];

  void pushScope() {
    final newScope = Scope(parent: _currentScope);
    _currentScope = newScope;
  }

  void popScope() {
    if (_currentScope?.parent == null) {
      _errorReporter.reportGeneric(
        message: 'Cannot pop the global scope.',
        startOffset: 0,
        endOffset: 0,
      );
      return;
    }

    _currentScope = _currentScope!.parent;
  }

  void addSymbol({
    required String name,
    required SymbolKind kind,
    required AstNode declaration,
    required SemanticType? resolvedType,
  }) {
    if (_currentScope == null) {
      _errorReporter.reportGeneric(
        message:
            'Cannot add symbol "$name": no active scope. '
            'This is an internal error.',
        startOffset: declaration.startOffset,
        endOffset: declaration.endOffset,
      );
      return;
    }

    _currentScope!.addSymbol(
      name: name,
      kind: kind,
      declaration: declaration,
      reporter: _errorReporter,
      resolvedType: resolvedType,
    );
  }

  SymbolEntry? lookup(String name, AstNode referencingNode) {
    if (_currentScope == null) {
      _errorReporter.reportGeneric(
        message:
            'Cannot lookup symbol "$name": no active scope. '
            'This is an internal error.',
        startOffset: referencingNode.startOffset,
        endOffset: referencingNode.endOffset,
      );
      return null;
    }

    final symbol = _currentScope!.lookup(name);

    if (symbol != null) {
      return symbol;
    }

    // Lookup in imported tables' global scopes
    for (final importedTable in importedTables) {
      final importedSymbol = importedTable.globalScope.lookup(name);
      if (importedSymbol != null) {
        return importedSymbol;
      }
    }

    _errorReporter.reportUndefinedSymbol(
      name: name,
      startOffset: referencingNode.startOffset,
      endOffset: referencingNode.endOffset,
    );
    return null;
  }

  Scope? get currentScope => _currentScope;
  Scope get globalScope => _globalScope;
}
