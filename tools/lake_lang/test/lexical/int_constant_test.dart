import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.intConstant()).end();

  group('Lake Grammar - IntConstant:', () {
    group('Valid Cases:', () {
      test('positive integer without plus - succeeds', () {
        const input = '456';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final intConstantToken = result.value as Token;
        expect(intConstantToken.value, equals('456'));
      });

      test('negative integer - succeeds', () {
        const input = '-456';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final intConstantToken = result.value as Token;
        expect(intConstantToken.value, equals('-456'));
      });

      test('positive integer with plus - succeeds', () {
        const input = '+123';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final intConstantToken = result.value as Token;
        expect(intConstantToken.value, equals('+123'));
      });

      test('zero - succeeds', () {
        const input = '0';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final intConstantToken = result.value as Token;
        expect(intConstantToken.value, equals('0'));
      });

      test('large integer - succeeds', () {
        const input = '9876543210987654321';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final intConstantToken = result.value as Token;
        expect(intConstantToken.value, equals('9876543210987654321'));
      });
    });

    group('Invalid Cases:', () {
      test('empty string - fails', () {
        const input = '';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, contains('digit expected'));
      });

      test('only sign - fails', () {
        const input = '+';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, contains('digit expected'));
      });

      test('contains non-digit characters - fails', () {
        const input = '123a';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, contains('end of input expected'));
      });

      test('contains decimal point - fails', () {
        const input = '12.3';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, contains('end of input expected'));
      });

      test('starts with decimal point - fails', () {
        const input = '.123';
        final result = parser.parse(input);
        expect(result, isA<Failure>());
        expect(result.message, contains('digit expected'));
      });
    });
  });
}
