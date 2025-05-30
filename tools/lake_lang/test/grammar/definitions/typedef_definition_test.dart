import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.typedefDefinition());

  group('Lake Grammar - TypedefDefinition:', () {
    group('Valid Cases:', () {
      test('simple typedef with base type - succeeds', () {
        const input = 'typedef string MyString;';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [Token keyword, Token type, Token identifier, Token? separator] =
            result.value as List;

        expect(keyword.value, 'typedef');
        expect(type.value, 'string');
        expect(identifier.value, 'MyString');
        expect(separator?.value, equals(';'));
      });

      test('typedef with list type - succeeds', () {
        const input = 'typedef list<string> StringList';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token typeOuter, _, Token typeInner, _],
          Token identifier,
          Token? separator,
        ] = result.value as List;

        expect(keyword.value, equals('typedef'));
        expect(typeOuter.value, equals('list'));
        expect(typeInner.value, equals('string'));
        expect(identifier.value, equals('StringList'));
        expect(separator?.value, isNull);
      });

      test('typedef with map type - succeeds', () {
        const input = 'typedef map<string, i32> MyMap;';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token typeOuter, _, Token keyType, _, Token valueType, _],
          Token identifier,
          Token? separator,
        ] = result.value as List;

        expect(keyword.value, equals('typedef'));
        expect(typeOuter.value, equals('map'));
        expect(keyType.value, equals('string'));
        expect(valueType.value, equals('i32'));
        expect(identifier.value, equals('MyMap'));
        expect(separator?.value, equals(';'));
      });

      test('typedef with set type - succeeds', () {
        const input = 'typedef set<uuid> UuidSet;';
        final result = parser.parse(input);

        expect(result, isA<Success>());

        final [
          Token keyword,
          [Token typeOuter, _, Token typeInner, _],
          Token identifier,
          Token? separator,
        ] = result.value as List;

        expect(keyword.value, equals('typedef'));
        expect(typeOuter.value, equals('set'));
        expect(typeInner.value, equals('uuid'));
        expect(identifier.value, equals('UuidSet'));
        expect(separator?.value, equals(';'));
      });

      test('typedef with nested list type - succeeds', () {
        const input = 'typedef list<list<bool>> BoolMatrix;';
        final result = parser.parse(input);

        expect(result, isA<Success>());
        final [
          Token keyword,
          [
            Token typeOuter,
            _,
            [Token typeInner, Token _, Token typeLeaf, Token _],
            _,
          ],
          Token identifier,
          Token? separator,
        ] = result.value as List;

        expect(keyword.value, equals('typedef'));
        expect(typeOuter.value, equals('list'));
        expect(typeInner.value, equals('list'));
        expect(typeLeaf.value, equals('bool'));
        expect(identifier.value, equals('BoolMatrix'));
        expect(separator?.value, equals(';'));
      });

      test('typedef with nested map type - succeeds', () {
        const input = 'typedef map<string, map<i32, string>> NestedMap;';
        final result = parser.parse(input);

        expect(result, isA<Success>());
        final [
          Token keyword,
          [
            Token typeOuter,
            _,
            Token keyTypeOuter,
            _,
            [
              Token typeInner,
              _,
              Token keyTypeInner,
              _,
              Token valueTypeInner,
              _,
            ],
            _,
          ],
          Token identifier,
          Token? separator,
        ] = result.value as List;

        expect(keyword.value, equals('typedef'));
        expect(typeOuter.value, equals('map'));
        expect(keyTypeOuter.value, equals('string'));
        expect(typeInner.value, equals('map'));
        expect(keyTypeInner.value, equals('i32'));
        expect(valueTypeInner.value, equals('string'));
        expect(identifier.value, equals('NestedMap'));
        expect(separator?.value, equals(';'));
      });
    });
    group('Invalid Cases:', () {});
  });
}
