import 'package:source_span/source_span.dart';
import '../parser/ast/ast_base.dart';

import '../parser/lake_parser.dart';
import 'errors/error_reporter.dart';
import 'symbols/symbol_table.dart';
import 'visitors/symbol_table_visitor.dart';
import 'visitors/type_checking_visitor.dart';

typedef FileSystemReader = String Function(String path);

class FileContext {
  FileContext({
    required this.path,
    required this.content,
    required this.document,
    required this.reporter,
    required this.symbolTable,
  }) : sourceFile = SourceFile.fromString(content, url: path);

  final String path;
  final String content;
  final DocumentNode document;
  final ErrorReporter reporter;
  final SymbolTable symbolTable;
  final SourceFile sourceFile;
}

class AnalysisSession {
  AnalysisSession(this.fileReader);

  final FileSystemReader fileReader;
  final Map<String, FileContext> _files = {};

  FileContext? getFile(String path) => _files[path];

  /// The entry point for analyzing a project starting from [entryPath].
  void analyzeProject(String entryPath) {
    _parseAndResolveImports(entryPath, []);

    // Pass 2: Symbol Table (isolated for each file)
    for (final context in _files.values) {
      final visitor = SymbolTableVisitor(context.symbolTable, context.reporter);
      context.document.accept(visitor);
    }

    // Pass 3: Linking (wire up imported symbol tables)
    for (final context in _files.values) {
      for (final header in context.document.headers) {
        if (header is ImportNode) {
          final importedPath = _resolvePath(context.path, header.path.value);
          final importedContext = _files[importedPath];
          if (importedContext != null) {
            context.symbolTable.importedTables.add(importedContext.symbolTable);
          }
        }
      }
    }

    // Pass 4: Type Checking
    for (final context in _files.values) {
      final visitor = TypeCheckingVisitor(
        context.symbolTable,
        context.reporter,
      );
      context.document.accept(visitor);
    }
  }

  void _parseAndResolveImports(
    String path,
    List<String> importStack, {
    ErrorReporter? parentReporter,
    ImportNode? importNode,
  }) {
    if (importStack.contains(path)) {
      if (parentReporter != null && importNode != null) {
        parentReporter.reportGeneric(
          message:
              'Circular import detected: ${importStack.join(' -> ')} -> $path',
          startOffset: importNode.startOffset,
          endOffset: importNode.endOffset,
        );
      }
      return;
    }

    if (_files.containsKey(path)) {
      return; // Already parsed
    }

    importStack.add(path);

    final content = fileReader(path);
    final reporter = ErrorReporter();
    final parser = LakeParser(content, reporter);
    final document = parser.parseDocument();
    
    final symbolTable = SymbolTable(reporter);

    final context = FileContext(
      path: path,
      content: content,
      document: document,
      reporter: reporter,
      symbolTable: symbolTable,
    );

    _files[path] = context;

    // Resolve imports
    for (final header in document.headers) {
      if (header is ImportNode) {
        final importedPath = _resolvePath(path, header.path.value);
        try {
          _parseAndResolveImports(
            importedPath,
            importStack,
            parentReporter: reporter,
            importNode: header,
          );
        } on Object catch (e) {
          reporter.reportGeneric(
            message: 'Could not load imported file "$importedPath": $e',
            startOffset: header.path.startOffset,
            endOffset: header.path.endOffset,
          );
        }
      }
    }

    importStack.removeLast();
  }

  String _resolvePath(String currentPath, String importPath) {
    // For simplicity, we assume imports are relative to the directory of the
    // current file.
    // E.g., if currentPath is "a/b/c.lake" and importPath is "d.lake",
    // it resolves to "a/b/d.lake".
    // This is a naive implementation; a real one would use the `path` package.
    final lastSlash = currentPath.lastIndexOf('/');
    if (lastSlash == -1) {
      return importPath;
    }
    return currentPath.substring(0, lastSlash + 1) + importPath;
  }
}
