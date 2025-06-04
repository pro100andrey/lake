import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('FieldType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [19] FieldType ::= ContainerType | BaseType | Identifier
    final parser = resolve(grammar.fieldType().end());

    // Positive cases

    test('should parse base type: bool', () {
      final result = parser.parse('bool');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'bool');
    });

    test('should parse base type: i32', () {
      final result = parser.parse('i32');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'i32');
    });

    test('should parse base type: string', () {
      final result = parser.parse('string');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'string');
    });

    test('should parse identifier type', () {
      final result = parser.parse('MyType');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'MyType');
    });

    test('should parse identifier with dot', () {
      final result = parser.parse('pkg.Type');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'pkg.Type');
    });

    test('should parse list type', () {
      final result = parser.parse('list<i32>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse set type', () {
      final result = parser.parse('set<string>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse map type', () {
      final result = parser.parse('map<string, i64>');
      final [Token t, Token ld, Token t1, Token comma, Token t2, Token rd] =
          result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(comma.value, ',');
      expect(t2.value, 'i64');
      expect(rd.value, '>');
    });

    test('should parse nested container type', () {
      final result = parser.parse('list<map<string, list<i32>>>');
      final [
        Token t,
        Token ld,
        [
          Token t1,
          Token ld1,
          Token keyT,
          Token comma,
          [Token t2, Token rd2, Token t3, Token rd3],
          Token rd1,
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'map');
      expect(ld1.value, '<');
      expect(keyT.value, 'string');
      expect(comma.value, ',');
      expect(t2.value, 'list');
      expect(rd2.value, '<');
      expect(t3.value, 'i32');
      expect(rd3.value, '>');
      expect(rd1.value, '>');
      expect(rd.value, '>');
    });

    test('should parse identifier with underscores', () {
      final result = parser.parse('_myType_123');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '_myType_123');
    });

    test('should parse type with whitespace', () {
      final result = parser.parse('   i64   ');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'i64');
    });

    // Negative cases

    test('should fail to parse incomplete container type', () {
      final result = parser.parse('list<');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('map<string string>');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('stream<string>');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse invalid identifier', () {
      final result = parser.parse('1abc');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse type with invalid characters', () {
      final result = parser.parse('list<i32!>');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
