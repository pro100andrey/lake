import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('EnumDefinition Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [9] Enum ::= 'enum' Identifier '{' EnumValue* '}'
    final parser = resolve(grammar.enumDefinition().end());

    // Positive cases

    test('should parse empty enum', () {
      final result = parser.parse('enum Color {}');
      expect(result, isA<Success>());
    });

    test('should parse enum with values', () {
      final result = parser.parse('enum Color { RED, GREEN, BLUE }');
      expect(result, isA<Success>());
    });

    test('should parse enum with values and explicit int', () {
      final result = parser.parse('enum Status { OK = 0, ERROR = 1 }');
      expect(result, isA<Success>());
    });

    test('should parse enum with trailing comma', () {
      final result = parser.parse('enum E { A, B, }');
      expect(result, isA<Success>());
    });

    test('should parse enum with trailing semicolon', () {
      final result = parser.parse('enum E { A; B; }');
      expect(result, isA<Success>());
    });

    test('should parse enum with whitespace', () {
      final result = parser.parse('  enum   E   {   A ,  B   }  ');
      expect(result, isA<Success>());
    });

    test('should parse enum with mixed separators', () {
      final result = parser.parse('enum E { A, B; C, }');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing enum keyword', () {
      final result = parser.parse('Color { RED, GREEN }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('enum { RED, GREEN }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing braces', () {
      final result = parser.parse('enum Color RED, GREEN');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid enum value', () {
      final result = parser.parse('enum E { = 1 }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
