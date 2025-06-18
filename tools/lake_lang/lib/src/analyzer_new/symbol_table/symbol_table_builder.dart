// lib/analyzer/symbol_table/symbol_table_builder.dart

import '../../analyzer/errors/error_reporter.dart';
import 'compilation_symbol_table.dart';
import 'scope.dart';
import 'symbol_entry.dart';

/// Builds the symbol table for a single compilation unit (file).
///
/// This class manages the scope stack during AST traversal and registers
/// symbols and imports. It interacts with the [CompilationSymbolTable]
/// for cross-file symbol resolution and import management.
///
/// This is used during the first two passes (InitialSymbolCollectorVisitor
/// and SymbolTablePopulatorVisitor).
class SymbolTableBuilder {
  /// Creates a [SymbolTableBuilder] for a new file.
  /// This constructor initializes a new global scope for the file and
  /// registers it with the [CompilationSymbolTable].
  SymbolTableBuilder({
    required String filePath,
    required ErrorReporter errorReporter,
    required CompilationSymbolTable compilationSymbolTable,
  }) : _filePath = filePath,
       _errorReporter = errorReporter,
       _compilationSymbolTable = compilationSymbolTable {
    // Initialize the global scope for the current file.
    _currentScope = Scope(errorReporter: _errorReporter);

    // Store the global scope
    _fileGlobalScope = _currentScope;

    _compilationSymbolTable
      ..registerFileScope(_filePath, _fileGlobalScope!)
      ..setCurrentProcessingFile(_filePath);
  }

  /// The global symbol table manager for the entire compilation.
  final CompilationSymbolTable _compilationSymbolTable;

  /// The absolute path of the file currently being processed by this builder.
  final String _filePath;

  String get filePath => _filePath;

  final ErrorReporter _errorReporter;

  /// The current active scope in the AST traversal.
  /// This represents the stack of nested scopes for the current file.
  Scope? _currentScope;
  Scope? _fileGlobalScope;

  Scope get fileGlobalScope {
    if (_fileGlobalScope == null) {
      // ... error reporting ...
      throw StateError('Global scope not initialized.');
    }
    return _fileGlobalScope!;
  }

  /// Pushes a new scope onto the scope stack.
  /// Call this when entering a new lexical block (e.g., inside a service,
  /// struct).
  void pushScope() {
    _currentScope = Scope(parent: _currentScope);
  }

  /// Pops the current scope from the scope stack, returning to the parent
  /// scope.
  /// Call this when exiting a lexical block.
  void popScope() {
    if (_currentScope?.parent == null || _currentScope == _fileGlobalScope) {
      _errorReporter.reportGeneric(
        message:
            'Internal error: Attempted to pop scope below file global scope.',
        span: (start: 0, end: 0),
        filePath: _filePath,
      );
      return;
    }
    _currentScope = _currentScope!.parent;
  }

  /// Adds a symbol to the current active scope.
  ///
  /// This method is an entry point for the AST visitors to define symbols
  /// within their respective scopes.
  bool addSymbol(SymbolEntry entry) {
    if (_currentScope == null) {
      _errorReporter.reportGeneric(
        message:
            'Internal error: Attempted to add symbol "${entry.name}" '
            'to null scope.',
        span: entry.span,
        filePath: _filePath,
      );
      return false;
    }

    final added = _currentScope!.addSymbol(entry);

    if (!added) {
      _errorReporter.reportGeneric(
        message:
            "Duplicate declaration of symbol '${entry.name}' in this scope.",
        span: entry.span,
        filePath: _filePath,
      );
    }
    return added;
  }

  /// Registers an import path with the compilation symbol table.
  void registerImport(String importedPath) {
    _compilationSymbolTable.registerImport(_filePath, importedPath);
  }

  /// Looks up a symbol by name in the current scope chain.
  /// This is for resolving references within the same file and scope.
  ///
  /// - Parameter [name]: The name of the symbol to look up.
  /// - Returns: The [SymbolEntry] if found, otherwise `null`.
  SymbolEntry? lookupLocal(String name) => _currentScope?.lookup(name);

  /// Looks up a symbol by name, considering the current file's context,
  /// including its own top-level scope and imported files.
  /// This delegates to [CompilationSymbolTable.lookup].
  ///
  /// - Parameter [name]: The name of the symbol to look up. Can be qualified.
  /// - Returns: The [SymbolEntry] if found, otherwise `null`.
  SymbolEntry? lookupGlobal(String name) =>
      _compilationSymbolTable.lookup(name);

  /// Updates an existing symbol entry.
  ///
  /// For top-level symbols, it delegates to [CompilationSymbolTable].
  /// For symbols within the current active scope, it attempts to update them
  /// directly. This method is crucial for the second pass to enrich symbol
  /// information.
  bool updateSymbol(SymbolEntry updatedEntry) {
    // Try to update in the current scope first
    // (for nested symbols like fields/methods).
    if (_currentScope != null && _currentScope!.replaceSymbol(updatedEntry)) {
      return true;
    }

    // If not found in current scope, try to update in the global file scope
    // (for top-level symbols that were processed and are being re-updated).
    if (_fileGlobalScope != null &&
        _fileGlobalScope!.replaceSymbol(updatedEntry)) {
      return true;
    }

    // If still not found, it's an internal error or the symbol is in a scope
    // that's no longer active (e.g., a symbol from another file).
    // For symbols outside the current file, use
    // `_compilationSymbolTable.updateSymbol`. However,
    // the `SymbolTablePopulatorVisitor` is designed to update symbols
    // when it *revisits* their declaration, so they should generally be
    // in the current scope or the file's global scope.
    _errorReporter.reportGeneric(
      message:
          "Internal error: Failed to update symbol '${updatedEntry.name}'."
          ' Symbol not found in current or global scope for file $_filePath.',
      span: updatedEntry.span,
      filePath: _filePath,
    );
    return false;
  }
}
