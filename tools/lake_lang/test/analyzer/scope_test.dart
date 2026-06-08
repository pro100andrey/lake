import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/semantic_types.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_entry.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_table.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

/// Helper to parse a Lake snippet and return the first definition node,
/// which can be used as a declaration for SymbolEntry.
AstNode _parseDummyNode(String source) {
  final reporter = ErrorReporter();
  final parser = LakeParser(source, reporter);
  final doc = parser.parseDocument();
  return doc.definitions.first;
}

void main() {
  group('Scope', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    group('lookup()', () {
      test('finds symbol in current scope', () {
        final scope = Scope();
        final node = _parseDummyNode('const i32 x = 1;');

        scope.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: node,
          reporter: reporter,
          resolvedType: BaseType.i32T,
        );

        final result = scope.lookup('x');
        expect(result, isNotNull);
        expect(result!.name, equals('x'));
        expect(result.kind, equals(SymbolKind.constant));
        expect(result.resolvedType, equals(BaseType.i32T));
      });

      test('finds symbol in parent scope (chain lookup)', () {
        final parent = Scope();
        final child = Scope(parent: parent);
        final node = _parseDummyNode('const i32 y = 2;');

        parent.addSymbol(
          name: 'y',
          kind: SymbolKind.constant,
          declaration: node,
          reporter: reporter,
          resolvedType: BaseType.i32T,
        );

        final result = child.lookup('y');
        expect(result, isNotNull);
        expect(result!.name, equals('y'));
      });

      test('returns null when not found', () {
        final scope = Scope();
        expect(scope.lookup('nonexistent'), isNull);
      });

      test('child scope symbol shadows parent scope', () {
        final parent = Scope();
        final child = Scope(parent: parent);
        final parentNode = _parseDummyNode('const i32 x = 1;');
        final childNode = _parseDummyNode('const string x = "hello";');

        parent.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: parentNode,
          reporter: reporter,
          resolvedType: BaseType.i32T,
        );

        child.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: childNode,
          reporter: reporter,
          resolvedType: BaseType.stringT,
        );

        final result = child.lookup('x');
        expect(result, isNotNull);
        expect(result!.resolvedType, equals(BaseType.stringT));
      });
    });

    group('contains()', () {
      test('returns true for symbol in current scope', () {
        final scope = Scope();
        final node = _parseDummyNode('const i32 x = 1;');

        scope.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: node,
          reporter: reporter,
        );

        expect(scope.contains('x'), isTrue);
      });

      test('returns false for symbol NOT in current scope', () {
        final scope = Scope();
        expect(scope.contains('missing'), isFalse);
      });

      test('returns false for symbol only in parent (contains is local)', () {
        final parent = Scope();
        final child = Scope(parent: parent);
        final node = _parseDummyNode('const i32 x = 1;');

        parent.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: node,
          reporter: reporter,
        );

        // contains only checks the current scope, not parents
        expect(child.contains('x'), isFalse);
      });
    });

    group('symbolsInScope', () {
      test('returns unmodifiable map', () {
        final scope = Scope();
        final node = _parseDummyNode('const i32 x = 1;');

        scope.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: node,
          reporter: reporter,
        );

        final symbols = scope.symbolsInScope;
        expect(symbols.length, equals(1));
        expect(symbols.containsKey('x'), isTrue);

        // Attempting to modify should throw
        expect(
          () => symbols['y'] = SymbolEntry(
            name: 'y',
            kind: SymbolKind.constant,
            declaration: node,
          ),
          throwsUnsupportedError,
        );
      });

      test('returns empty map for empty scope', () {
        final scope = Scope();
        expect(scope.symbolsInScope, isEmpty);
      });
    });

    group('addSymbol duplicate detection', () {
      test('reports duplicate declaration', () {
        final scope = Scope();
        final node1 = _parseDummyNode('const i32 x = 1;');
        final node2 = _parseDummyNode('const i32 x = 2;');

        scope
          ..addSymbol(
            name: 'x',
            kind: SymbolKind.constant,
            declaration: node1,
            reporter: reporter,
          )
          ..addSymbol(
            name: 'x',
            kind: SymbolKind.constant,
            declaration: node2,
            reporter: reporter,
          );

        expect(reporter.hasErrors, isTrue);
        expect(
          reporter.diagnostics.first.message,
          contains('already declared'),
        );
      });
    });
  });

  group('SymbolTable', () {
    late ErrorReporter reporter;
    late SymbolTable symbolTable;

    setUp(() {
      reporter = ErrorReporter();
      symbolTable = SymbolTable(reporter);
    });

    group('pushScope / popScope', () {
      test('pushScope creates nested scope', () {
        final initialScope = symbolTable.currentScope;
        symbolTable.pushScope();
        expect(symbolTable.currentScope, isNot(same(initialScope)));
      });

      test('popScope returns to parent', () {
        final parentScope = symbolTable.currentScope;
        symbolTable
          ..pushScope()
          ..popScope();
        expect(symbolTable.currentScope, same(parentScope));
      });

      test('popScope on global scope reports error', () {
        // We're at global scope, popping should report an error
        symbolTable.popScope();
        expect(reporter.hasErrors, isTrue);
        expect(
          reporter.diagnostics.first.message,
          contains('Cannot pop the global scope'),
        );
      });

      test('multiple push/pop pairs work correctly', () {
        final global = symbolTable.currentScope;
        symbolTable
          ..pushScope()
          ..pushScope()
          ..popScope()
          ..popScope();
        expect(symbolTable.currentScope, same(global));
      });
    });

    group('addSymbol', () {
      test('adds symbol to current scope', () {
        final node = _parseDummyNode('const i32 x = 1;');
        symbolTable.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: node,
          resolvedType: BaseType.i32T,
        );

        final result = symbolTable.globalScope.lookup('x');
        expect(result, isNotNull);
        expect(result!.name, equals('x'));
      });
    });

    group('lookup', () {
      test('finds symbol in current scope', () {
        final node = _parseDummyNode('const i32 x = 1;');
        symbolTable.addSymbol(
          name: 'x',
          kind: SymbolKind.constant,
          declaration: node,
          resolvedType: BaseType.i32T,
        );

        final result = symbolTable.lookup('x', node);
        expect(result, isNotNull);
        expect(result!.name, equals('x'));
        expect(reporter.hasErrors, isFalse);
      });

      test('reports undefined symbol when not found', () {
        final node = _parseDummyNode('const i32 x = 1;');
        final result = symbolTable.lookup('nonexistent', node);

        expect(result, isNull);
        expect(reporter.hasErrors, isTrue);
        expect(
          reporter.diagnostics.first.message,
          contains('nonexistent'),
        );
      });

      test('lookup across imported tables', () {
        // Create an imported table with a symbol
        final importedReporter = ErrorReporter();
        final importedTable = SymbolTable(importedReporter);
        final node = _parseDummyNode('struct User { i32 id; }');

        importedTable.addSymbol(
          name: 'User',
          kind: SymbolKind.type,
          declaration: node,
          resolvedType: null,
        );

        // Import the table
        symbolTable.importedTables.add(importedTable);

        // Lookup should find it in the imported table's global scope
        final refNode = _parseDummyNode('const i32 x = 1;');
        final result = symbolTable.lookup('User', refNode);

        expect(result, isNotNull);
        expect(result!.name, equals('User'));
        expect(result.kind, equals(SymbolKind.type));
        expect(reporter.hasErrors, isFalse);
      });

      test('local scope takes precedence over imported tables', () {
        // Add symbol to local scope
        final localNode = _parseDummyNode('struct User { string name; }');
        symbolTable.addSymbol(
          name: 'User',
          kind: SymbolKind.type,
          declaration: localNode,
          resolvedType: BaseType.stringT,
        );

        // Add a different symbol with same name in imported table
        final importedReporter = ErrorReporter();
        final importedTable = SymbolTable(importedReporter);
        final importedNode = _parseDummyNode('struct User { i32 id; }');
        importedTable.addSymbol(
          name: 'User',
          kind: SymbolKind.type,
          declaration: importedNode,
          resolvedType: BaseType.i32T,
        );
        symbolTable.importedTables.add(importedTable);

        // Should find local one
        final refNode = _parseDummyNode('const i32 x = 1;');
        final result = symbolTable.lookup('User', refNode);
        expect(result, isNotNull);
        expect(result!.resolvedType, equals(BaseType.stringT));
      });
    });

    group('nested scope lookup traverses parent chain', () {
      test('child scope sees parent symbols', () {
        final node = _parseDummyNode('const i32 globalVal = 42;');
        symbolTable
          ..addSymbol(
            name: 'globalVal',
            kind: SymbolKind.constant,
            declaration: node,
            resolvedType: BaseType.i32T,
          )
          ..pushScope();

        final refNode = _parseDummyNode('const i32 x = 1;');
        final result = symbolTable.lookup('globalVal', refNode);
        expect(result, isNotNull);
        expect(result!.name, equals('globalVal'));
        expect(reporter.hasErrors, isFalse);
      });

      test('grandchild scope sees grandparent symbols', () {
        final node = _parseDummyNode('const i32 root = 0;');
        symbolTable
          ..addSymbol(
            name: 'root',
            kind: SymbolKind.constant,
            declaration: node,
            resolvedType: BaseType.i32T,
          )
          ..pushScope()
          ..pushScope();

        final refNode = _parseDummyNode('const i32 x = 1;');
        final result = symbolTable.lookup('root', refNode);
        expect(result, isNotNull);
        expect(result!.name, equals('root'));
      });
    });

    group('globalScope', () {
      test('globalScope is accessible', () {
        expect(symbolTable.globalScope, isNotNull);
      });

      test('globalScope is the initial current scope', () {
        expect(symbolTable.currentScope, same(symbolTable.globalScope));
      });
    });
  });
}
