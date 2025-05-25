// ignore_for_file: avoid_print

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.constDefinition());

  group('Lake Grammar - ConstDefinition:', () {
    group('Valid Cases:', () {
      test('string const with double quotes - succeeds', () {
        const input = 'const string NAME = "John Doe"';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('string'));
        expect(id.value, equals('NAME'));
        expect(op.value, equals('='));
        expect(value.value, equals('"John Doe"'));
        expect(separator, isNull);
      });

      test('string const with single quotes - succeeds', () {
        const input = "const string GREETING = 'Hello World'";
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('string'));
        expect(id.value, equals('GREETING'));
        expect(op.value, equals('='));
        expect(value.value, equals("'Hello World'"));
        expect(separator, isNull);
      });

      test('positive integer const - succeeds', () {
        const input = 'const i32 MAX_USERS = 100';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(id.value, equals('MAX_USERS'));
        expect(op.value, equals('='));
        expect(int.parse(value.value), equals(100));
        expect(value.value, equals('100'));
        expect(separator, isNull);
      });

      test('negative integer const - succeeds', () {
        const input = 'const i32 MIN_USERS = -50';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(id.value, equals('MIN_USERS'));
        expect(op.value, equals('='));
        expect(int.parse(value.value), equals(-50));
        expect(value.value, equals('-50'));
        expect(separator, isNull);
      });

      test('positive double const with decimal - succeeds', () {
        const input = 'const double PI = +3.14';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(id.value, equals('PI'));
        expect(op.value, equals('='));
        expect(value.value, equals('+3.14'));
        expect(double.parse(value.value), equals(3.14));
        expect(separator, isNull);
      });

      test('negative double const with exponent - succeeds', () {
        const input = 'const double NEG_EXP = -1.23e-5';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(id.value, equals('NEG_EXP'));
        expect(op.value, equals('='));
        expect(value.value, equals('-1.23e-5'));
        expect(double.parse(value.value), equals(-1.23e-5));
        expect(separator, isNull);
      });

      test('const with identifier value - succeeds', () {
        const input = 'const i32 MY_REF = OTHER_ID';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(id.value, equals('MY_REF'));
        expect(op.value, equals('='));
        expect(value.value, equals('OTHER_ID'));
        expect(separator, isNull);
      });

      test('int const list - succeeds', () {
        const input = 'const list<i32> TEST = [1, 2, 3];';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, Token l, Token listType, Token r],
          Token id,
          Token op,
          [
            Token leftBracket,
            [[Token v1, _], [Token v2, _], [Token v3, _]],
            Token rightBracket,
          ],
          Token separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('list'));
        expect(listType.value, equals('i32'));
        expect(id.value, equals('TEST'));
        expect(op.value, equals('='));
        expect(leftBracket.value, equals('['));
        expect(v1.value, equals('1'));
        expect(v2.value, equals('2'));
        expect(v3.value, equals('3'));
        expect(rightBracket.value, equals(']'));
        expect(separator, isNotNull);
        expect(separator.value, equals(';'));
      });

      test('const map<string, int> - succeeds', () {
        const input = 'const map<string, string> TAGS = {"id": 123};';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, _, Token keyType, _, Token valueType, _],
          Token id,
          Token op,
          [_, [[Token key, _, Token value, _]], _],
          Token separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('map'));
        expect(keyType.value, equals('string'));
        expect(valueType.value, equals('string'));
        expect(id.value, equals('TAGS'));
        expect(op.value, equals('='));
        expect(key.value, equals('"id"'));
        expect(value.value, equals('123'));
        expect(separator.value, equals(';'));
      });

      test('boolean const - succeeds', () {
        const input = 'const bool IS_ACTIVE = true';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('bool'));
        expect(id.value, equals('IS_ACTIVE'));
        expect(op.value, equals('='));
        expect(value.value, equals('true'));
        expect(separator, isNull);
      });

      test('binary const with identifier value - succeeds', () {
        const input = 'const binary DATA = SOME_BINARY_ID';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('binary'));
        expect(id.value, equals('DATA'));
        expect(op.value, equals('='));
        expect(value.value, equals('SOME_BINARY_ID'));
        expect(separator, isNull);
      });

      // const list<list<i32>> MATRIX = [[1, 2], [3, 4]]
    });

    group('Invalid Cases:', () {});
  });
}
