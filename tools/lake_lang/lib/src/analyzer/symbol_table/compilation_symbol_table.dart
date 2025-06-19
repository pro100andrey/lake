// lib/analyzer/symbol_table/compilation_symbol_table.dart

import '../../ast/base/types.dart';
import '../errors/error_reporter.dart';
import 'scope.dart';
import 'symbol_entry.dart';

/// Manages symbol tables across multiple compilation units (files).
///
/// This class holds the root [Scope] for each processed file and facilitates
/// symbol resolution across file boundaries, especially for imports.
class CompilationSymbolTable {
  CompilationSymbolTable(ErrorReporter errorReporter)
    : _errorReporter = errorReporter;

  /// Stores the root (global) scope for each compilation unit.
  /// The key is the file path (String), and the value is the global [Scope] for
  /// that file.
  final Map<String, Scope> _fileGlobalScopes = {};

  /// Tracks the import dependencies between files.
  /// Key: The absolute path of the file that imports.
  /// Value: A list of absolute paths of files that are imported by the key
  /// file.
  final Map<String, List<String>> _importDependencies = {};

  /// The error reporter instance used for logging semantic errors.
  final ErrorReporter _errorReporter;

  /// Registers the global scope for a given file.
  ///
  /// This method should be called once for each file at the beginning of its
  /// symbol collection phase. It makes the file's top-level symbols
  /// discoverable by other files if they import it.
  ///
  /// - Parameter [filePath]: The absolute path of the file.
  /// - Parameter [globalScope]: The root [Scope] of that file.
  void registerFileScope(String filePath, Scope globalScope) {
    if (_fileGlobalScopes.containsKey(filePath)) {
      _errorReporter.reportGeneric(
        message:
            'Internal error: Global scope for file "$filePath" '
            'already registered.',
        span: (start: 0, end: 0), // No specific span for this internal error
        filePath: filePath,
      );

      return;
    }

    _fileGlobalScopes[filePath] = globalScope;
  }

  /// Registers an import relationship between two files.
  ///
  /// This helps in later phases to correctly resolve symbols that are
  /// defined in one file but used in another via an import statement.
  ///
  /// - Parameter [importerPath]: The absolute path of the file that contains
  /// the import statement.
  /// - Parameter [importedPath]: The absolute path of the file being imported.
  void registerImport(String importerPath, String importedPath) {
    _importDependencies.putIfAbsent(importerPath, () => []).add(importedPath);
  }

  /// Retrieves the global scope for a specific file.
  ///
  /// This is useful for visitors or rules that need direct access to a file's
  /// top-level symbol table.
  ///
  /// - Parameter [filePath]: The absolute path of the file.
  /// - Returns: The global [Scope] for the file, or `null` if not registered.
  Scope? getFileGlobalScope(String filePath) => _fileGlobalScopes[filePath];

  /// Looks up a symbol by its potentially qualified name within the context
  /// of a given file.
  ///
  /// This is the primary lookup method for the second pass. It handles:
  /// 1. Direct lookup in the current file's global scope.
  /// 2. Lookup in imported files' global scopes.
  /// 3. Future: If `symbolName` is qualified (e.g., `pkg.MyType`), it should
  /// also handle resolving `pkg` as an import alias (not yet implemented here).
  ///
  /// - Parameter [currentFilePath]: The path of the file where the lookup
  /// is initiated.
  /// - Parameter [symbolName]: The name of the symbol to look up. Can be a
  /// simple name (e.g., "MyStruct") or a fully qualified name
  /// (e.g., "com.example.MyService").
  ///   For simplicity, currently assumes simple names from imports are global.
  /// - Returns: The [SymbolEntry] if found, otherwise `null`.
  SymbolEntry? lookupSymbolInFileAndImports(
    String currentFilePath,
    String symbolName,
  ) {
    // 1. Try to find the symbol in the current file's global scope.
    final currentFileScope = _fileGlobalScopes[currentFilePath];

    if (currentFileScope == null) {
      // This is an internal error: a file should always have its global scope
      // registered before lookups are performed for it.
      _errorReporter.reportGeneric(
        message:
            'Internal error: No global scope found for file "$currentFilePath" '
            'during symbol lookup.',
        span: (start: 0, end: 0), // No specific span for this internal error
        filePath: currentFilePath,
      );

      return null;
    }

    final localSymbol = currentFileScope.lookup(symbolName);
    
    if (localSymbol != null) {
      return localSymbol;
    }

    // 2. If not found locally, try to find in directly imported files.
    // This assumes imported symbols are accessible by their simple name
    // or by their fully qualified name across files.
    final importedFiles = _importDependencies[currentFilePath] ?? [];

    for (final importedPath in importedFiles) {
      final importedFileScope = _fileGlobalScopes[importedPath];

      if (importedFileScope != null) {
        // Look up the symbol in the imported file's global scope.
        final importedSymbol = importedFileScope.lookup(symbolName);
        if (importedSymbol != null) {
          return importedSymbol;
        }
      } else {
        // This scenario indicates a missing imported file or a dependency cycle
        // where an imported file hasn't been processed yet.
        // This might be better reported as a specific error during initial
        // import resolution.
        _errorReporter.reportGeneric(
          message:
              'Internal error: Imported file "$importedPath" '
              'not found or not yet processed during lookup from '
              '"$currentFilePath".',
          span: (start: 0, end: 0),
          filePath: currentFilePath,
        );
      }
    }

    // Symbol not found.
    return null;
  }

  /// Updates an existing [SymbolEntry] in the compilation symbol table.
  ///
  /// This is crucial for the second pass where symbol entries are populated
  /// with resolved types and members. It finds the symbol in its originating
  /// scope and replaces it with the updated version.
  ///
  /// - Parameter [updatedEntry]: The [SymbolEntry] with updated information.
  /// - Returns: `true` if the symbol was found and updated, `false` otherwise.
  bool updateSymbol(SymbolEntry updatedEntry, String declarationFilePath) {
    final globalScopeForFile = _fileGlobalScopes[declarationFilePath];
    if (globalScopeForFile == null) {
      _errorReporter.reportGeneric(
        message:
            "Internal error: Cannot update symbol '${updatedEntry.name}': "
            "Global scope for file '$declarationFilePath' not found.",
        span: updatedEntry.span,
        filePath: declarationFilePath,
      );
      return false;
    }

    // The logic to update within a potentially nested scope.
    // For simplicity, if it's a top-level symbol, we update directly.
    // For nested symbols, the SymbolTableBuilder's `addSymbol` or
    // `replaceSymbol` would be more appropriate within its current scope.
    // This `updateSymbol` on `CompilationSymbolTable` is primarily for
    // top-level entries that might get their `resolvedType` or `members`
    // updated.
    final updated = globalScopeForFile.replaceSymbol(updatedEntry);

    if (!updated) {
      // It's possible the symbol is not a direct child of the global scope
      // but a child of a composite symbol (e.g., a field of a struct).
      // In such cases, the composite symbol (e.g., StructSymbolEntry) itself
      // needs to be updated with its new list of fields, and THEN that
      // StructSymbolEntry is updated in its scope.
      // The `updateSymbol` in `CompilationSymbolTable` is mostly for updating
      // the top-level entries that have been enhanced in the second pass.
      _errorReporter.reportGeneric(
        message:
            "Internal error: Symbol '${updatedEntry.name}' not directly "
            "replaceable in global scope of '$declarationFilePath'. "
            'It might be a nested symbol whose parent needs updating.',
        span: updatedEntry.span,
        filePath: declarationFilePath,
      );
    }

    return updated;
  }

  /// Resolves a top-level symbol across all relevant files.
  ///
  /// It first attempts to find the symbol in the [currentFilePath]'s global
  /// scope. If not found, it then searches through the global scopes of all
  /// files directly imported by [currentFilePath].
  ///
  /// - Parameter [currentFilePath]: The path of the file where the symbol is
  /// being resolved.
  /// - Parameter [symbolName]: The name of the symbol to look up.
  /// - Parameter [usageSpan]: The source span where the symbol is used (for
  /// error reporting).
  /// - Returns: The [SymbolEntry] if found, otherwise `null`.
  ///   Does *not* report `UndefinedSymbol` error; that's left to the caller.
  SymbolEntry? resolveTopLevelSymbol(
    String currentFilePath,
    String symbolName,
    Span usageSpan,
  ) {
    // 1. Try to resolve in the current file's global scope
    final currentFileScope = _fileGlobalScopes[currentFilePath];
    if (currentFileScope == null) {
      _errorReporter.reportGeneric(
        message:
            'Internal error: No global scope found for current file '
            '"$currentFilePath".',
        span: usageSpan,
        filePath: currentFilePath,
      );
      return null;
    }

    final localSymbol = currentFileScope.lookup(symbolName);

    if (localSymbol != null) {
      return localSymbol;
    }

    // 2. If not found locally, try to resolve in directly imported files.
    // This assumes top-level symbols from imported files are directly
    // accessible by name once imported. Adjust this logic if Lake requires
    // qualified names (e.g., `module.symbolName`) for imported symbols.
    final importedFiles = _importDependencies[currentFilePath] ?? [];
    for (final importedPath in importedFiles) {
      final importedFileScope = _fileGlobalScopes[importedPath];
      if (importedFileScope != null) {
        final importedSymbol = importedFileScope.lookup(symbolName);
        if (importedSymbol != null) {
          // You might add logic here to check if the symbol is "exported"
          // if your language has explicit export/public rules beyond just being top-level.
          return importedSymbol;
        }
      } else {
        // This scenario indicates a missing imported file or a dependency cycle
        // where an imported file hasn't been processed yet.
        _errorReporter.reportGeneric(
          message:
              'Error: Imported file "$importedPath" '
              'not found or not yet processed.',
          // Or a more specific span related to the import statement itself
          span: usageSpan,
          filePath: currentFilePath,
        );
      }
    }

    // Symbol not found in current file or direct imports.
    return null;
  }
}
