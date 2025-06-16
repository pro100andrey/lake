import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.listSeparator().end());

  group('ListSeparator grammar (positive):', () {
    test('should parse a comma as a list separator', () {
      final result = parser.parse(',');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, ',');
    });

    test('should parse a semicolon as a list separator', () {
      final result = parser.parse(';');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, ';');
    });

    test('should parse a comma with leading and trailing whitespace', () {
      final result = parser.parse('   ,   ');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, ',');
    });

    test('should parse a semicolon with leading and trailing whitespace', () {
      final result = parser.parse('   ;   ');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, ';');
    });
  });

  group('ListSeparator grammar (negative):', () {
    test('should fail to parse a colon', () {
      final result = parser.parse(':');

      expect(result, isA<Failure>());
      expect(result.message, '"," or ";" expected');
    });

    test('should fail to parse a dot', () {
      final result = parser.parse('.');

      expect(result, isA<Failure>());
      expect(result.message, '"," or ";" expected');
    });

    test('should fail to parse an empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"," or ";" expected');
    });

    test('should fail to parse a comma with extra characters', () {
      final result = parser.parse(',abc');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse a semicolon with extra characters', () {
      final result = parser.parse(';123');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
