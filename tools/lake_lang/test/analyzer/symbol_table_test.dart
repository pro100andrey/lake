import 'dart:io';

import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_entry.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_table.dart';
import 'package:lake_lang/src/analyzer/visitors/symbol_table_visitor.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SymbolTableVisitor', () {
    late ErrorReporter reporter;
    late SymbolTable symbolTable;
    late SymbolTableVisitor visitor;

    setUp(() {
      reporter = ErrorReporter();
      symbolTable = SymbolTable(reporter);
      visitor = SymbolTableVisitor(symbolTable, reporter);
    });

    test('adds top-level symbols correctly', () {
      final source = File(
        'test/test_data/lake_sources/symbol_table_test_3.lake',
      ).readAsStringSync();

      final parser = LakeParser(source, reporter);
      parser.parseDocument().accept(visitor);

      expect(reporter.hasErrors, isFalse);

      expect(
        symbolTable.globalScope.lookup('MAX_USERS')?.kind,
        equals(SymbolKind.constant),
      );
      expect(
        symbolTable.globalScope.lookup('UserId')?.kind,
        equals(SymbolKind.type),
      );
      expect(
        symbolTable.globalScope.lookup('User')?.kind,
        equals(SymbolKind.type),
      );
      expect(
        symbolTable.globalScope.lookup('UserService')?.kind,
        equals(SymbolKind.service),
      );
      expect(
        symbolTable.globalScope.lookup('Role')?.kind,
        equals(SymbolKind.type),
      );
      expect(
        symbolTable.globalScope.lookup('Result')?.kind,
        equals(SymbolKind.type),
      );
      expect(
        symbolTable.globalScope.lookup('NotFoundException')?.kind,
        equals(SymbolKind.type),
      );
    });

    test('reports duplicate symbols in the same scope', () {
      final source = File(
        'test/test_data/lake_sources/symbol_table_test_2.lake',
      ).readAsStringSync();

      final parser = LakeParser(source, reporter);
      parser.parseDocument().accept(visitor);

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.message,
        contains('A symbol named "User" is already declared'),
      );
    });

    test('reports duplicate fields in struct', () {
      final source = File(
        'test/test_data/lake_sources/symbol_table_test_1.lake',
      ).readAsStringSync();

      final parser = LakeParser(source, reporter);
      parser.parseDocument().accept(visitor);

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.message,
        contains('A symbol named "x" is already declared'),
      );
    });
  });
}
