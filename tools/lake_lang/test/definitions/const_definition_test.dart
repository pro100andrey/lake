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
          [String? sign, String intValue],
          dynamic separator,
        ] = result.value as List;

        expect(keyword.value, equals('const'));
        expect(type.value, equals('i32'));
        expect(id.value, equals('MAX_USERS'));
        expect(op.value, equals('='));
        expect(sign, isNull);
        expect(intValue, equals('100'));
        expect(separator, isNull);
      });
    });

    group('Invalid Cases:', () {});
  });
}
