import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ConstList Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [30] ConstList ::= '[' (ConstValue ListSeparator?)* ']'
    final parser = resolve(grammar.constList().end());

    // Positive cases

    test('should parse an empty list', () {
      final result = parser.parse('[]');
      expect(result, isA<Success>());
      
    });

    test('should parse a list of integers', () {
      final result = parser.parse('[1, 2, 3]');
      expect(result, isA<Success>());
    });

    test('should parse a list of doubles', () {
      final result = parser.parse('[1.1, 2.2, 3.3]');
      expect(result, isA<Success>());
    });

    test('should parse a list of strings', () {
      final result = parser.parse('["a", "b", "c"]');
      expect(result, isA<Success>());
    });

    test('should parse a list with mixed values', () {
      final result = parser.parse('[1, "two", 3.0, SOME_CONST]');
      expect(result, isA<Success>());
    });

    test('should parse a list with trailing comma', () {
      final result = parser.parse('[1, 2, 3, ]');
      expect(result, isA<Success>());
    });

    test('should parse a list with semicolon separator', () {
      final result = parser.parse('[1; 2; 3]');
      expect(result, isA<Success>());
    });

    test('should parse a list with mixed separators', () {
      final result = parser.parse('[1, 2; 3, 4;]');
      expect(result, isA<Success>());
    });

    test('should parse a nested list', () {
      final result = parser.parse('[[1,2], [3,4]]');
      expect(result, isA<Success>());
    });

    test('should parse a list with whitespace', () {
      final result = parser.parse('[ 1 , 2 , 3 ]');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing closing bracket', () {
      final result = parser.parse('[1, 2, 3');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing opening bracket', () {
      final result = parser.parse('1, 2, 3]');
      expect(result, isA<Failure>());
    });

    test('should fail to parse not a list', () {
      final result = parser.parse('notalist');
      expect(result, isA<Failure>());
    });

    test('should fail to parse list with invalid separator', () {
      final result = parser.parse('[1 | 2]');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
