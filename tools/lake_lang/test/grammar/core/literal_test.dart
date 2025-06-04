import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Literal Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [32] Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
    final parser = resolve(grammar.literal().end());

    // Positive Test Cases

    test('should parse a string literal with double quotes', () {
      final result = parser.parse('"Hello, World!"');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '"Hello, World!"');
    });

    test('should parse an empty string with double quotes', () {
      final result = parser.parse('""');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '""');
    });

    test('should parse a string literal with single quotes', () {
      final result = parser.parse("'Lake is cool!'");
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, "'Lake is cool!'");
    });

    test('should parse an empty string with single quotes', () {
      final result = parser.parse("''");
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, "''");
    });

    test('should parse a string with numbers and special characters', () {
      final result = parser.parse(r'"123_abc-!@#$%^&*()[]{}.,;"');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, r'"123_abc-!@#$%^&*()[]{}.,;"');
    });

    test('should parse a string literal with unescaped new line', () {
      final result = parser.parse('"first line\nsecond line"');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '"first line\nsecond line"');
    });

    test('should parse a string literal with unescaped carriage return', () {
      final result = parser.parse('"first line\rsecond line"');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '"first line\rsecond line"');
    });

    test('should parse double quotes inside single-quoted string', () {
      final result = parser.parse('\'He said "hi"!\'');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '\'He said "hi"!\'');
    });

    test('should parse single quotes inside double-quoted string', () {
      final result = parser.parse("\"It's fine\"");
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, "\"It's fine\"");
    });

    test('should parse a single character in double quotes', () {
      final result = parser.parse('"a"');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '"a"');
    });

    test('should parse a single character in single quotes', () {
      final result = parser.parse("'b'");
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, "'b'");
    });

    test('should parse a string with spaces and tabs', () {
      final result = parser.parse('"   \t  "');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '"   \t  "');
    });

    // Negative Test Cases

    test('should fail to parse a string literal without quotes', () {
      final result = parser.parse('unquoted_string');

      expect(result, isA<Failure>());
      expect(result.message, contains('"\\\'" expected'));
    });

    test('should fail to parse a string literal with mismatched quotes', () {
      final result = parser.parse('"missing_end_quote');
      expect(result, isA<Failure>());
      expect(result.message, contains('"\\\'" expected'));

      final result2 = parser.parse('missing_start_quote"');
      expect(result2, isA<Failure>());
      expect(result2.message, contains('"\\\'" expected'));
    });

    test('should fail to parse a string literal with only one quote', () {
      final result = parser.parse('"');
      expect(result, isA<Failure>());
      expect(result.message, contains('"\\\'" expected'));

      final result2 = parser.parse("'");
      expect(result2, isA<Failure>());
      expect(result2.message, contains('"\\\'" expected'));
    });

    test('should fail to parse an unterminated multiline string', () {
      final result = parser.parse('"line1\nline2');

      expect(result, isA<Failure>());
      expect(result.message, contains('"\\\'" expected'));
    });

    test('should fail to parse a string with escaped quote', () {
      final result = parser.parse(r'"escaped \""');

      expect(result, isA<Failure>());
      expect(result.message, contains('end of input expected'));
    });

    test('should fail to parse a string with unescaped inner quote', () {
      final result = parser.parse('"He said "hi""');

      expect(result, isA<Failure>());
      expect(result.message, contains('end of input expected'));
    });
  });
}
