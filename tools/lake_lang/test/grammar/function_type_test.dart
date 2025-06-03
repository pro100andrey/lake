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
      expect(result, isA<Success>());
    });

    test('should parse stream type with whitespace', () {
      final result = parser.parse(' stream < string > ');
      expect(result, isA<Success>());
    });

    test('should parse list type as field type', () {
      final result = parser.parse('list<double>');
      expect(result, isA<Success>());
    });

    test('should parse set type as field type', () {
      final result = parser.parse('set<i32>');
      expect(result, isA<Success>());
    });

    test('should parse map type as field type', () {
      final result = parser.parse('map<string, int>');
      expect(result, isA<Success>());
    });

    test('should parse base type as field type', () {
      final result = parser.parse('bool');
      expect(result, isA<Success>());
    });

    test('should parse identifier as field type', () {
      final result = parser.parse('CustomType');
      expect(result, isA<Success>());
    });

    test('should parse void', () {
      final result = parser.parse('void');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse invalid type', () {
      final result = parser.parse('invalidType<');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });

    test('should fail to parse partial stream type', () {
      final result = parser.parse('stream<');
      expect(result, isA<Failure>());
    });

    test('should fail to parse random text', () {
      final result = parser.parse('random text');
      expect(result, isA<Failure>());
    });
  });
}
