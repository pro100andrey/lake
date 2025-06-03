import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Field Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [13] Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)? 
    // ListSeparator?
    final parser = resolve(grammar.field().end());

    // Positive cases

    test('should parse a simple field', () {
      final result = parser.parse('i32 count');
      expect(result, isA<Success>());
    });

    test('should parse a field with field id', () {
      final result = parser.parse('1: i32 count');
      expect(result, isA<Success>());
    });

    test('should parse a field with field id and required', () {
      final result = parser.parse('2: required string name');
      expect(result, isA<Success>());
    });

    test('should parse a field with field id and optional', () {
      final result = parser.parse('3: optional bool flag');
      expect(result, isA<Success>());
    });

    test('should parse a field with default value', () {
      final result = parser.parse('i32 count = 0');
      expect(result, isA<Success>());
    });

    test('should parse a field with field id, required, and default value', () {
      final result = parser.parse('4: required i32 count = 10');
      expect(result, isA<Success>());
    });

    test('should parse a field with list type', () {
      final result = parser.parse('list<string> tags');
      expect(result, isA<Success>());
    });

    test('should parse a field with map type and default value', () {
      final result = parser.parse('map<string, i32> dict = {}');
      expect(result, isA<Success>());
    });

    test('should parse a field with trailing comma', () {
      final result = parser.parse('i32 count,');
      expect(result, isA<Success>());
    });

    test('should parse a field with trailing semicolon', () {
      final result = parser.parse('i32 count;');
      expect(result, isA<Success>());
    });

    test('should parse a field with whitespace', () {
      final result = parser.parse('   i32    count   ');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing type', () {
      final result = parser.parse('count');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('i32');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid field id', () {
      final result = parser.parse('abc: i32 count');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid default value', () {
      final result = parser.parse('i32 count =');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
