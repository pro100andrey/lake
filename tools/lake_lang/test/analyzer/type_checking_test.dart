import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_table.dart';
import 'package:lake_lang/src/analyzer/visitors/symbol_table_visitor.dart';
import 'package:lake_lang/src/analyzer/visitors/type_checking_visitor.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

void main() {
  group('TypeCheckingVisitor and Rules', () {
    late ErrorReporter reporter;
    late SymbolTable symbolTable;
    late SymbolTableVisitor symbolVisitor;
    late TypeCheckingVisitor typeVisitor;

    setUp(() {
      reporter = ErrorReporter();
      symbolTable = SymbolTable(reporter);
      symbolVisitor = SymbolTableVisitor(symbolTable, reporter);
      typeVisitor = TypeCheckingVisitor(symbolTable, reporter);
    });

    void parseAndCheck(String source) {
      final parser = LakeParser(source, reporter);
      final document = parser.parseDocument();
      // Only proceed to analysis if parsing succeeded
      if (reporter.hasErrors) {
        return;
      }

      document.accept(symbolVisitor);
      if (reporter.hasErrors) {
        return;
      }

      document.accept(typeVisitor);
    }

    test('validates correct constant types', () {
      parseAndCheck('''
        const i32 COUNT = 10;
        const double PI = 3.14;
        const string MSG = "Hello";
        const bool IS_VALID = true;
      ''');

      expect(reporter.hasErrors, isFalse);
    });

    test('reports error on invalid constant types', () {
      parseAndCheck('''
        const i32 COUNT = "Not an integer";
      ''');

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.message,
        contains('Cannot assign a value of type "StringLiteralNode"'),
      );
    });

    test('reports error on empty struct', () {
      parseAndCheck('''
        struct Empty {}
      ''');

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.message,
        contains('Struct definition cannot be empty'),
      );
    });

    test('reports error on empty enum', () {
      parseAndCheck('''
        enum EmptyEnum {}
      ''');

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.message,
        contains('Enum definition cannot be empty'),
      );
    });
  });
}
