import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('DefinitionType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [20] DefinitionType ::= ContainerType | BaseType
    final parser = resolve(grammar.definitionType().end());

    // Positive cases

    test('should parse "bool"', () {
      final result = parser.parse('bool');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'bool');
    });

    test('should parse "i32"', () {
      final result = parser.parse('i32');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'i32');
    });

    test('should parse "list<string>"', () {
      final result = parser.parse('list<string>');
      expect(result, isA<Success>());
      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;
      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerType.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "set<i64>"', () {
      final result = parser.parse('set<i64>');
      expect(result, isA<Success>());
      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;
      expect(type.value, 'set');
      expect(ld.value, '<');
      expect(innerType.value, 'i64');
      expect(rd.value, '>');
    });

    test('should parse "map<string,bool>"', () {
      final result = parser.parse('map<string,bool>');
      expect(result, isA<Success>());
      final [
        Token type,
        Token ld,
        Token innerKeyType,
        Token comma,
        Token innerValueType,
        Token rd,
      ] = result.value as List;
      expect(type.value, 'map');
      expect(ld.value, '<');
      expect(innerKeyType.value, 'string');
      expect(comma.value, ',');
      expect(innerValueType.value, 'bool');
      expect(rd.value, '>');
    });

    // Negative cases

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
