import '../../ast/nodes/ast_nodes.dart';
import '../../common/span.dart';
import '../diagnostics/diagnostic_system.dart';
import '../diagnostics/diagnostics.dart';
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
    required Span span,
    required DiagnosticSystem diagnosticSystem,
    SemanticType? resolvedType,
  }) {
    if (_symbols.containsKey(name)) {
      final existingEntry = _symbols[name]!;
      diagnosticSystem.report(
        DuplicateDeclarationDiagnostic(
          name: name,
          span: span,
          previousDeclarationSpan: existingEntry.span,
          filePath: '<file_path>',
        ),
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
  SymbolTable(this._diagnosticSystem) {
    _currentScope = Scope();
  }

  Scope? _currentScope;
  final DiagnosticSystem _diagnosticSystem;

  void pushScope() {
    final newScope = Scope(parent: _currentScope);
    _currentScope = newScope;
  }

  void popScope() {
    if (_currentScope?.parent == null) {
      _diagnosticSystem.report(
        const GenericDiagnostic(
          filePath: '<file_path>',
          message: 'Cannot pop the global scope.',
          span: (start: 0, end: 0),
        ),
      );
      return;
    }

    _currentScope = _currentScope!.parent;
  }

  void addSymbol({
    required String name,
    required SymbolKind kind,
    required AstNode declaration,
    required Span span,
    required SemanticType? resolvedType,
  }) {
    if (_currentScope == null) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message:
              'Cannot add symbol "$name": no active scope. '
              'This is an internal error.',
          filePath: '<file_path>',
          span: span,
        ),
      );
      return;
    }

    _currentScope!.addSymbol(
      name: name,
      kind: kind,
      declaration: declaration,
      span: span,
      diagnosticSystem: _diagnosticSystem,
      resolvedType: resolvedType,
    );
  }

  SymbolEntry? lookup(String name, Span span) {
    if (_currentScope == null) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message:
              'Cannot lookup symbol "$name": no active scope. '
              'This is an internal error.',
          span: span,
          filePath: '<file_path>',
        ),
      );
      return null;
    }

    final symbol = _currentScope!.lookup(name);

    if (symbol == null) {
      _diagnosticSystem.report(
        GenericDiagnostic(
          message: 'Undefined symbol "$name".',
          span: span,
          filePath: '<file_path>',
        ),
      );
      return null;
    }

    return symbol;
  }

  Scope? get currentScope => _currentScope;
}
