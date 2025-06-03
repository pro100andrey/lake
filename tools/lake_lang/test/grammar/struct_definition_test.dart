import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('StructDefinition Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [10] Struct ::= 'struct' Identifier '{' Field* '}'
    final parser = resolve(grammar.structDefinition().end());

    // Positive cases

    test('should parse empty struct', () {
      final result = parser.parse('struct Empty {}');
      expect(result, isA<Success>());
    });

    test('should parse struct with one field', () {
      final result = parser.parse('struct Point { i32 x }');
      expect(result, isA<Success>());
    });

    test('should parse struct with multiple fields', () {
      final result = parser.parse('struct Point { i32 x; i32 y; }');
      expect(result, isA<Success>());
    });

    test('should parse struct with field ids and required', () {
      final result = parser.parse(
        'struct User { 1: required string name; 2: i32 age }',
      );
      expect(result, isA<Success>());
    });

    test('should parse struct with default values', () {
      final result = parser.parse(
        'struct Config { bool enabled = true; i32 count = 10 }',
      );
      expect(result, isA<Success>());
    });

    test('should parse struct with trailing comma', () {
      final result = parser.parse('struct S { i32 x, }');
      expect(result, isA<Success>());
    });

    test('should parse struct with trailing semicolon', () {
      final result = parser.parse('struct S { i32 x; }');
      expect(result, isA<Success>());
    });

    test('should parse struct with whitespace', () {
      final result = parser.parse(
        '  struct   S   {   i32   x   ;   i32 y   }  ',
      );
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing struct keyword', () {
      final result = parser.parse('Point { i32 x }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('struct { i32 x }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing braces', () {
      final result = parser.parse('struct Point i32 x; i32 y;');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid field', () {
      final result = parser.parse('struct S { x }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
