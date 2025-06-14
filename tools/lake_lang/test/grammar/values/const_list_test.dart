import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.constList().end());

  group('ConstList grammar (positive):', () {
    test('should parse an empty list', () {
      final result = parser.parse('[]');
      final [Token lb, List values, Token rb] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(values, isEmpty);
      expect(rb.value, ']');
    });

    test('should parse a list of integers', () {
      final result = parser.parse('[1, 2, 3]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(v3.value, '3');
      expect(rb.value, ']');
    });

    test('should parse a list of doubles', () {
      final result = parser.parse('[1.1, 2.2, 3.3]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1.1');
      expect(v2.value, '2.2');
      expect(v3.value, '3.3');
      expect(rb.value, ']');
    });

    test('should parse a list of strings', () {
      final result = parser.parse('["a", "b", "c"]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '"a"');
      expect(v2.value, '"b"');
      expect(v3.value, '"c"');
      expect(rb.value, ']');
    });

    test('should parse a list with mixed values', () {
      final result = parser.parse('[1, "two", 3.0, SOME_CONST]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
          [Token v4, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '"two"');
      expect(v3.value, '3.0');
      expect(v4.value, 'SOME_CONST');
      expect(rb.value, ']');
    });

    test('should parse a list with trailing comma', () {
      final result = parser.parse('[1, 2, 3, ]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(v3.value, '3');
      expect(rb.value, ']');
    });

    test('should parse a list with semicolon separator', () {
      final result = parser.parse('[1; 2; 3]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(v3.value, '3');
      expect(rb.value, ']');
    });

    test('should parse a list with mixed separators', () {
      final result = parser.parse('[1, 2; 3, 4;]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
          [Token v4, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(v3.value, '3');
      expect(v4.value, '4');
      expect(rb.value, ']');
    });

    test('should parse a nested list', () {
      final result = parser.parse('[[1,2], [3,4]]');
      final [
        Token lb,
        [
          [[_, [[Token v11, _], [Token v12, _]], _], _],
          [[_, [[Token v21, _], [Token v22, _]], _], _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v11.value, '1');
      expect(v12.value, '2');
      expect(v21.value, '3');
      expect(v22.value, '4');
      expect(rb.value, ']');
    });

    test('should parse a list with whitespace', () {
      final result = parser.parse('[ 1 , 2 , 3 ]');
      final [
        Token lb,
        [
          [Token v1, _],
          [Token v2, _],
          [Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(v3.value, '3');
      expect(rb.value, ']');
    });
  });

  group('ConstList grammar (negative):', () {
    test('should fail to parse missing closing bracket', () {
      final result = parser.parse('[1, 2, 3');

      expect(result, isA<Failure>());
      expect(result.message, '"]" expected');
    });

    test('should fail to parse missing opening bracket', () {
      final result = parser.parse('1, 2, 3]');

      expect(result, isA<Failure>());
      expect(result.message, '"[" expected');
    });

    test('should fail to parse not a list', () {
      final result = parser.parse('notalist');

      expect(result, isA<Failure>());
      expect(result.message, '"[" expected');
    });

    test('should fail to parse list with invalid separator', () {
      final result = parser.parse('[1 | 2]');

      expect(result, isA<Failure>());
      expect(result.message, '"]" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"[" expected');
    });
  });
}
