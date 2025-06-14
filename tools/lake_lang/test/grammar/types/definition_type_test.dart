import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.definitionType().end());

  group('DefinitionType grammar (positive):', () {
    test('should parse "bool"', () {
      final result = parser.parse('bool');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'bool');
    });

    test('should parse "i32"', () {
      final result = parser.parse('i32');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'i32');
    });

    test('should parse "list<string>"', () {
      final result = parser.parse('list<string>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "set<i64>"', () {
      final result = parser.parse('set<i64>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'i64');
      expect(rd.value, '>');
    });

    test('should parse "map<string,bool>"', () {
      final result = parser.parse('map<string,bool>');
      final [
        Token t,
        Token ld,
        Token kt,
        _,
        Token vt,
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(kt.value, 'string');
      expect(vt.value, 'bool');
      expect(rd.value, '>');
    });
  });

  group('DefinitionType grammar (negative):', () {
    test('should fail to parse identifier', () {
      final result = parser.parse('MyType');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse stream type', () {
      final result = parser.parse('stream<i32>');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse unknown type', () {
      final result = parser.parse('unknown');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse container with missing type', () {
      final result = parser.parse('list<>');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse container with extra characters', () {
      final result = parser.parse('set<bool>1');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('map<string bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse map with one type', () {
      final result = parser.parse('map<string>');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });
  });
}
