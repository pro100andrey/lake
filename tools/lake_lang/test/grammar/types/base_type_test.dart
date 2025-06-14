import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.baseType().end());

  group('BaseType grammar (positive):', () {
    test('should parse "bool"', () {
      final result = parser.parse('bool');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'bool');
    });

    test('should parse "byte"', () {
      final result = parser.parse('byte');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'byte');
    });

    test('should parse "i16"', () {
      final result = parser.parse('i16');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'i16');
    });

    test('should parse "i32"', () {
      final result = parser.parse('i32');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'i32');
    });

    test('should parse "i64"', () {
      final result = parser.parse('i64');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'i64');
    });

    test('should parse "double"', () {
      final result = parser.parse('double');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'double');
    });

    test('should parse "string"', () {
      final result = parser.parse('string');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'string');
    });

    test('should parse "binary"', () {
      final result = parser.parse('binary');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'binary');
    });
  });

  group('BaseType grammar (negative):', () {
    test('should fail to parse unknown type', () {
      final result = parser.parse('unknown');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse type with extra characters', () {
      final result = parser.parse('bool1');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse type with wrong case', () {
      final result = parser.parse('Bool');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse type with inner space', () {
      final result = parser.parse('b ool');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse type with non-ascii character', () {
      final result = parser.parse('bóol');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse type with separator', () {
      final result = parser.parse('bool;');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
