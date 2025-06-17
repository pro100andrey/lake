import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.methodType().end());

  group('MethodType grammar (positive):', () {
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
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'stream');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse list type as field type', () {
      final result = parser.parse('list<double>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'double');
      expect(rd.value, '>');
    });

    test('should parse set type as field type', () {
      final result = parser.parse('set<i32>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse map type as field type', () {
      final result = parser.parse('map<string, int>');
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
      expect(vt.value, 'int');
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
  });

  group('MethodType grammar (negative):', () {
    test('should fail to parse invalid type', () {
      final result = parser.parse('invalidType<');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, 'return type expected');
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
