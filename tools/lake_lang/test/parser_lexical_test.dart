import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Lake Grammar - Lexical Rules:', () {
    final grammar = LakeGrammarDefinition();

    group('Identifier', () {
      final parser = resolve(grammar.identifier()).end();

      group('Valid Cases:', () {
        test('simple, only letters - succeeds', () {
          const input = 'myVariable';
          final result = parser.parse(input);
          expect(result, isA<Success>());

          final identifierToken = result.value as Token;
          expect(identifierToken.value, equals('myVariable'));
        });

        test('with underscore and dot - succeeds', () {
          const input = '_my.var_123';
          final result = parser.parse(input);
          expect(result, isA<Success>());

          final identifierToken = result.value as Token;
          expect(identifierToken.value, equals('_my.var_123'));
        });

        test('starts with uppercase letter - succeeds', () {
          const input = 'MyIdentifier';
          final result = parser.parse(input);
          expect(result, isA<Success>());

          final identifierToken = result.value as Token;
          expect(identifierToken.value, equals('MyIdentifier'));
        });

        test('only underscore - succeeds', () {
          const input = '_';
          final result = parser.parse(input);

          expect(result, isA<Success>());

          final identifierToken = result.value as Token;
          expect(identifierToken.value, equals('_'));
        });

        test('with digits inside - succeeds', () {
          const input = 'id123Name';
          final result = parser.parse(input);
          expect(result, isA<Success>());

          final identifierToken = result.value as Token;
          expect(identifierToken.value, equals('id123Name'));
        });
      });

      group('Invalid Cases:', () {
        test('starts with digit - initial character error', () {
          const input = '1myVariable';
          final result = parser.parse(input);
          
          expect(result, isA<Failure>());
          expect(result.message, equals('"_" expected'));
        });

        test('contains hyphen - invalid character error', () {
          const input = 'my-Variable';
          final result = parser.parse(input);
          expect(result, isA<Failure>());
          expect(result.message, equals('end of input expected'));
        });

        test('contains space - invalid character error', () {
          const input = 'my Variable';
          final result = parser.parse(input);
          expect(result, isA<Failure>());
          expect(result.message, equals('end of input expected'));
        });

        test('contains ampersand - invalid character error', () {
          const input = 'my&Variable';
          final result = parser.parse(input);
          expect(result, isA<Failure>());
          expect(result.message, equals('end of input expected'));
        });

        test('ends with invalid character - invalid character error', () {
          const input = 'myVar!';
          final result = parser.parse(input);
          expect(result, isA<Failure>());
          expect(result.message, equals('end of input expected'));
        });

        test('empty string - initial character error', () {
          const input = '';
          final result = parser.parse(input);
          expect(result, isA<Failure>());
          expect(result.message, equals('"_" expected'));
        });

        test('only dot - initial character error', () {
          const input = '.';
          final result = parser.parse(input);
          expect(result, isA<Failure>());
          expect(result.message, equals('"_" expected'));
        });
      });
    });
  });
}
