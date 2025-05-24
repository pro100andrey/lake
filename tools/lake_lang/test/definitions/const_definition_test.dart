// ignore_for_file: avoid_print

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.constDefinition()).end();

  group('Lake Grammar - ConstDefinition:', () {
    group('Valid Cases:', () {
      test('simple string const - succeeds', () {
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

      test('integer const with semicolon - succeeds', () {
        const input = 'const i32 MAX_USERS = 100';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          String intValue,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(id.value, equals('MAX_USERS'));
        expect(op.value, equals('='));
        expect(int.parse(intValue), equals(100));
        expect(intValue, equals('100'));
        expect(separator, isNull);
      });

      test('double const with decimal - succeeds', () {
        const input = 'const double PI = +3.14';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          Token type,
          Token id,
          Token op,
          String value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(id.value, equals('PI'));
        expect(op.value, equals('='));
        expect(value, equals('+3.14'));
        expect(double.parse(value), equals(3.14));
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
          String value,
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('double'));
        expect(id.value, equals('NEG_EXP'));
        expect(op.value, equals('='));
        expect(value, equals('-1.23e-5'));
        expect(double.parse(value), equals(-1.23e-5));
        expect(separator, isNull);
      });
    });

    group('Invalid Cases:', () {});
  });
}
