import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.constDefinition());

  group('Lake Grammar - ConstDefinition:', () {
    group('Valid Cases:', () {
      test('const string with double quotes - succeeds', () {
        const input = 'const string NAME = "John Doe"';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('string'));
        expect(identifier.value, equals('NAME'));
        expect(op.value, equals('='));
        expect(value.value, equals('"John Doe"'));
        expect(separator, isNull);
      });

      test('const string with single quotes - succeeds', () {
        const input = "const string GREETING = 'Hello World'";
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('string'));
        expect(identifier.value, equals('GREETING'));
        expect(op.value, equals('='));
        expect(value.value, equals("'Hello World'"));
        expect(separator, isNull);
      });

      test('const with positive i32 value - succeeds', () {
        const input = 'const i32 MAX_USERS = 100';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(identifier.value, equals('MAX_USERS'));
        expect(op.value, equals('='));
        expect(int.parse(value.value), equals(100));
        expect(value.value, equals('100'));
        expect(separator, isNull);
      });

      test('const with negative i32 value - succeeds', () {
        const input = 'const i32 MIN_USERS = -50';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(identifier.value, equals('MIN_USERS'));
        expect(op.value, equals('='));
        expect(int.parse(value.value), equals(-50));
        expect(value.value, equals('-50'));
        expect(separator, isNull);
      });

      test('const with i64 value - succeeds', () {
        const input = 'const i64 LARGE_NUM = 9223372036854775807';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i64'));
        expect(identifier.value, equals('LARGE_NUM'));
        expect(op.value, equals('='));
        expect(int.parse(value.value), equals(9223372036854775807));
        expect(value.value, equals('9223372036854775807'));
        expect(separator, isNull);
      });

      test('const with double value without sign - succeeds', () {
        const input = 'const double TEMP = 25.5';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(identifier.value, equals('TEMP'));
        expect(op.value, equals('='));
        expect(value.value, equals('25.5'));
        expect(double.parse(value.value), equals(25.5));
        expect(separator, isNull);
      });

      test('const with positive double value - succeeds', () {
        const input = 'const double PI = +3.14';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(identifier.value, equals('PI'));
        expect(op.value, equals('='));
        expect(value.value, equals('+3.14'));
        expect(double.parse(value.value), equals(3.14));
        expect(separator, isNull);
      });

      test(
        'const with double value starting with decimal point - succeeds',
        () {
          const input = 'const double SMALL_VAL = .125';
          final result = parser.parse(input);
          expect(result, isA<Success>());

          final [
            Token keyword,
            Token type,
            Token identifier,
            Token op,
            Token value,
            dynamic separator,
          ] = result.value as List;

          expect(keyword.value, equals('const'));
          expect(type.value, equals('double'));
          expect(identifier.value, equals('SMALL_VAL'));
          expect(op.value, equals('='));
          expect(value.value, equals('.125'));
          expect(double.parse(value.value), equals(0.125));
          expect(separator, isNull);
        },
      );

      test('const with negative double exponent value - succeeds', () {
        const input = 'const double NEG_EXP = -1.23e-5';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(identifier.value, equals('NEG_EXP'));
        expect(op.value, equals('='));
        expect(value.value, equals('-1.23e-5'));
        expect(double.parse(value.value), equals(-1.23e-5));
        expect(separator, isNull);
      });

      test(
        'const with double value with exponent but no decimal - succeeds',
        () {
          const input = 'const double BIG_VAL = 1e3'; // 1000.0
          final result = parser.parse(input);
          expect(result, isA<Success>());

          final [
            Token keyword,
            Token type,
            Token identifier,
            Token op,
            Token value,
            dynamic separator,
          ] = result.value as List;

          expect(keyword.value, equals('const'));
          expect(type.value, equals('double'));
          expect(identifier.value, equals('BIG_VAL'));
          expect(op.value, equals('='));
          expect(value.value, equals('1e3'));
          expect(double.parse(value.value), equals(1000.0));
          expect(separator, isNull);
        },
      );

      test('const with identifier value - succeeds', () {
        const input = 'const i32 MY_REF = OTHER_ID';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(identifier.value, equals('MY_REF'));
        expect(op.value, equals('='));
        expect(value.value, equals('OTHER_ID'));
        expect(separator, isNull);
      });

      test('const with uuid value - succeeds', () {
        const input =
            'const uuid USER_UUID = "a1b2c3d4-e5f6-7890-1234-567890abcdef"';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('uuid'));
        expect(identifier.value, equals('USER_UUID'));
        expect(op.value, equals('='));
        expect(value.value, equals('"a1b2c3d4-e5f6-7890-1234-567890abcdef"'));
        expect(separator, isNull);
      });

      test('const with list<i32> value - succeeds', () {
        const input = 'const list<i32> TEST = [1, 2, 3];';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, Token l, Token listType, Token r],
          Token identifier,
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
        expect(identifier.value, equals('TEST'));
        expect(op.value, equals('='));
        expect(leftBracket.value, equals('['));
        expect(v1.value, equals('1'));
        expect(v2.value, equals('2'));
        expect(v3.value, equals('3'));
        expect(rightBracket.value, equals(']'));
        expect(separator, isNotNull);
        expect(separator.value, equals(';'));
      });

      test('const with empty list value - succeeds', () {
        const input = 'const list<i32> EMPTY_LIST = [];';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, _, Token listType, _],
          Token identifier,
          Token op,
          [_, List value, _],
          Token separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('list'));
        expect(listType.value, equals('i32'));
        expect(identifier.value, equals('EMPTY_LIST'));
        expect(op.value, equals('='));
        expect(value.isEmpty, isTrue);
      });

      test('const with list<list<i32>> value - succeeds', () {
        const input = 'const list<list<i32>> MATRIX = [[1, 2], [3, 4]];';
        final result = parser.parse(input);
        expect(result, isA<Success>());
      });

      test('const with map<string, list<string>> value - succeeds', () {
        const input = '''
        const map<string, list<string>> DATA_MAP = {"key": ["val1", "val2"]};
            ''';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, _, Token keyT, _, List mapValueT, _],
          Token identifier,
          Token op,
          List value,
          Token separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('map'));
        expect(keyT.value, equals('string'));
        expect(mapValueT, isA<List>());
        expect(identifier.value, equals('DATA_MAP'));
        expect(op.value, equals('='));
      });

      test('const with map<string, list<string>> value - succeeds', () {
        const input = '''
        const map<string, list<string>> DATA_MAP = {"key": ["val1", "val2"]};
            ''';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, _, Token keyT, _, List mapValueT, _],
          Token identifier,
          Token op,
          List value,
          Token separator,
        ] = result.value as List;
        expect(keyword.value, equals('const'));
        expect(type.value, equals('map'));
        expect(keyT.value, equals('string'));
        expect(mapValueT, isA<List>());
        expect(identifier.value, equals('DATA_MAP'));
        expect(op.value, equals('='));
      });

      test('const with map<string, i32> value - succeeds', () {
        const input = 'const map<string, i32> TAGS = {"id": 123};';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, _, Token keyType, _, Token valueType, _],
          Token identifier,
          Token op,
          [_, [[Token key, _, Token value, _]], _],
          Token separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('map'));
        expect(keyType.value, equals('string'));
        expect(valueType.value, equals('i32'));
        expect(identifier.value, equals('TAGS'));
        expect(op.value, equals('='));
        expect(key.value, equals('"id"'));
        expect(value.value, equals('123'));
        expect(separator.value, equals(';'));
      });

      test('const with empty map value - succeeds', () {
        const input = 'const map<string, string> EMPTY_MAP = {};';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token type, _, Token keyType, _, Token valueType, _],
          Token identifier,
          Token op,
          [_, List value, _],
          Token separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('map'));
        expect(keyType.value, equals('string'));
        expect(valueType.value, equals('string'));
        expect(identifier.value, equals('EMPTY_MAP'));
        expect(op.value, equals('='));
        expect(value.isEmpty, isTrue);
        expect(separator.value, equals(';'));
      });

      test('const with boolean value - succeeds', () {
        const input = 'const bool IS_ACTIVE = true';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('bool'));
        expect(identifier.value, equals('IS_ACTIVE'));
        expect(op.value, equals('='));
        expect(value.value, equals('true'));
        expect(separator, isNull);
      });

      test('const with binary value - succeeds', () {
        const input = 'const binary DATA = SOME_BINARY_ID';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('binary'));
        expect(identifier.value, equals('DATA'));
        expect(op.value, equals('='));
        expect(value.value, equals('SOME_BINARY_ID'));
        expect(separator, isNull);
      });

      test('const with byte value - succeeds', () {
        const input = 'const byte STATUS = 123';
        final result = parser.parse(input);
        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token identifier,
          Token op,
          Token value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('byte'));
        expect(identifier.value, equals('STATUS'));
        expect(op.value, equals('='));
        expect(value.value, equals('123'));
        expect(separator, isNull);
      });
    });

    group('Invalid Cases:', () {});
  });
}
