import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.literal()).end();

  group('Lake Grammar - Literal:', () {
    group('Valid Cases:', () {
      test('double quotes - succeeds', () {
        const input = '"hello world"';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final literalToken = result.value as Token;
        expect(literalToken.value, equals('"hello world"'));
      });

      test('single quotes - succeeds', () {
        const input = "'hello world'";
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final literalToken = result.value as Token;
        expect(literalToken.value, equals("'hello world'"));
      });

      test('empty double quotes - succeeds', () {
        const input = '""';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final literalToken = result.value as Token;
        expect(literalToken.value, equals('""'));
      });

      test('empty single quotes - succeeds', () {
        const input = "''";
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final literalToken = result.value as Token;
        expect(literalToken.value, equals("''"));
      });

      test('string with numbers and special chars - succeeds', () {
        const input = r"'123 abc!@#$%'";
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final literalToken = result.value as Token;
        expect(literalToken.value, equals(r"'123 abc!@#$%'"));
      });

      test('string with escaped quotes', () {
        const input = "'string with \" quote'";
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final literalToken = result.value as Token;
        expect(literalToken.value, equals("'string with \" quote'"));
      });
    });

    group('Invalid Cases:', () {
      test('unclosed double quotes - fails', () {
        const input = '"hello';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, equals('"\\\'" expected'));
      });

      test('unclosed single quotes - fails', () {
        const input = "'hello";
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, equals('"\\\'" expected'));
      });

      test('mismatched quotes - fails', () {
        const input = "'hello\"";
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, equals('"\\\'" expected'));
      });

      test('starts with unexpected char - fails', () {
        const input = 'hello"';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, contains('"\\\'" expected'));
      });

      test('only quote - fails', () {
        const input = '"';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, equals('"\\\'" expected'));
      });
    });
  });
}
