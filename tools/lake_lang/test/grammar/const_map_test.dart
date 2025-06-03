import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ConstMap Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [31] ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
    final parser = resolve(grammar.constMap().end());

    // Positive cases

    test('should parse an empty map', () {
      final result = parser.parse('{}');
      expect(result, isA<Success>());
    });

    test('should parse a map with integer keys and values', () {
      final result = parser.parse('{1: 2, 3: 4}');
      expect(result, isA<Success>());
    });

    test('should parse a map with string keys and values', () {
      final result = parser.parse('{"a": "b", "c": "d"}');
      expect(result, isA<Success>());
    });

    test('should parse a map with mixed value types', () {
      final result = parser.parse('{"x": 1, "y": 2.2, "z": SOME_CONST}');
      expect(result, isA<Success>());
    });

    test('should parse a map with trailing comma', () {
      final result = parser.parse('{1: 2, 3: 4, }');
      expect(result, isA<Success>());
    });

    test('should parse a map with semicolon separator', () {
      final result = parser.parse('{1: 2; 3: 4;}');
      expect(result, isA<Success>());
    });

    test('should parse a map with mixed separators', () {
      final result = parser.parse('{1: 2, 3: 4; 5: 6,}');
      expect(result, isA<Success>());
    });

    test('should parse a map with nested lists and maps', () {
      final result = parser.parse('{"a": [1,2], "b": {"c": 3}}');
      expect(result, isA<Success>());
    });

    test('should parse a map with whitespace', () {
      final result = parser.parse('{ "a" : 1 , "b" : 2 }');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing closing brace', () {
      final result = parser.parse('{"a": 1');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing opening brace', () {
      final result = parser.parse('"a": 1}');
      expect(result, isA<Failure>());
    });

    test('should fail to parse not a map', () {
      final result = parser.parse('notamap');
      expect(result, isA<Failure>());
    });

    test('should fail to parse map with missing colon', () {
      final result = parser.parse('{"a" 1}');
      expect(result, isA<Failure>());
    });

    test('should fail to parse map with invalid separator', () {
      final result = parser.parse('{1:2 | 3:4}');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
