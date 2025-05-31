import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('BaseType Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.baseType().end());

    // Positive cases

    test('should parse "bool"', () {
      final result = parser.parse('bool');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'bool');
    });

    test('should parse "byte"', () {
      final result = parser.parse('byte');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'byte');
    });

    test('should parse "i16"', () {
      final result = parser.parse('i16');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'i16');
    });

    test('should parse "i32"', () {
      final result = parser.parse('i32');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'i32');
    });

    test('should parse "i64"', () {
      final result = parser.parse('i64');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'i64');
    });

    test('should parse "double"', () {
      final result = parser.parse('double');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'double');
    });

    test('should parse "string"', () {
      final result = parser.parse('string');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'string');
    });

    test('should parse "binary"', () {
      final result = parser.parse('binary');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'binary');
    });

    // Negative cases
    
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
