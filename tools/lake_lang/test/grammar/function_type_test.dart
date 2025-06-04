import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [17] FunctionType ::= StreamType | FieldType | 'void'
    final parser = resolve(grammar.functionType().end());

    // Positive cases

    test('should parse stream type', () {
      final result = parser.parse('stream<int>');
      final [Token t, Token ld, Token type, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'stream');
      expect(ld.value, '<');
      expect(type.value, 'int');
      expect(rd.value, '>');
    });

    test('should parse stream type with whitespace', () {
      final result = parser.parse(' stream < string > ');
      final [Token t, Token ld, Token type, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'stream');
      expect(ld.value, '<');
      expect(type.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse list type as field type', () {
      final result = parser.parse('list<double>');
      final [Token t, Token ld, Token type, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(type.value, 'double');
      expect(rd.value, '>');
    });

    test('should parse set type as field type', () {
      final result = parser.parse('set<i32>');
      final [Token t, Token ld, Token type, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(type.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse map type as field type', () {
      final result = parser.parse('map<string, int>');
      final [
        Token t,
        Token ld,
        Token keyT,
        Token comma,
        Token valueT,
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(keyT.value, 'string');
      expect(comma.value, ',');
      expect(valueT.value, 'int');
      expect(rd.value, '>');
    });

    test('should parse base type as field type', () {
      final result = parser.parse('bool');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'bool');
    });

    test('should parse identifier as field type', () {
      final result = parser.parse('CustomType');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'CustomType');
    });

    test('should parse void', () {
      final result = parser.parse('void');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'void');
    });

    // Negative cases

    test('should fail to parse invalid type', () {
      final result = parser.parse('invalidType<');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"void" expected');
    });

    test('should fail to parse partial stream type', () {
      final result = parser.parse('stream<');
      
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse random text', () {
      final result = parser.parse('random text');
      
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
