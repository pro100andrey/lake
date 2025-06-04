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
      final [
        Token lb,
        List values,
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(values, isEmpty);
      expect(rb.value, '}');
    });

    test('should parse a map with integer keys and values', () {
      final result = parser.parse('{1: 2, 3: 4}');
      final [
        Token lb,
        [
          [Token k1, _, Token v1, _],
          [Token k2, _, Token v2, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '1');
      expect(v1.value, '2');
      expect(k2.value, '3');
      expect(v2.value, '4');
      expect(rb.value, '}');
    });

    test('should parse a map with string keys and values', () {
      final result = parser.parse('{"a": "b", "c": "d"}');
      final [
        Token lb,
        [
          [Token k1, _, Token v1, _],
          [Token k2, _, Token v2, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '"a"');
      expect(v1.value, '"b"');
      expect(k2.value, '"c"');
      expect(v2.value, '"d"');
      expect(rb.value, '}');
    });

    test('should parse a map with mixed value types', () {
      final result = parser.parse('{"x": 1, "y": 2.2, "z": SOME_CONST}');
      final [
        Token lb,
        [
          [Token k1, _, Token v1, _],
          [Token k2, _, Token v2, _],
          [Token k3, _, Token v3, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '"x"');
      expect(v1.value, '1');
      expect(k2.value, '"y"');
      expect(v2.value, '2.2');
      expect(k3.value, '"z"');
      expect(v3.value, 'SOME_CONST');
      expect(rb.value, '}');
    });

    test('should parse a map with trailing comma', () {
      final result = parser.parse('{1: 2, 3: 4, }');

      final [
        Token lb,
        [
          [Token k1, _, Token v1, _],
          [Token k2, _, Token v2, Token? separator],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '1');
      expect(v1.value, '2');
      expect(k2.value, '3');
      expect(v2.value, '4');
      expect(separator, isNotNull);
      expect(rb.value, '}');
    });

    test('should parse a map with mixed separators', () {
      final result = parser.parse('{1: 2, 3: 4; 5: 6,}');
      final [
        Token lb,
        [
          [Token k1, _, Token v1, _],
          [Token k2, _, Token v2, _],
          [Token k3, _, Token v3, Token? separator],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '1');
      expect(v1.value, '2');
      expect(k2.value, '3');
      expect(v2.value, '4');
      expect(k3.value, '5');
      expect(v3.value, '6');
      expect(separator, isNotNull);
      expect(rb.value, '}');
    });

    test('should parse a map with nested lists and maps', () {
      final result = parser.parse('{"a": [1,2], "b": {"c": 3}}');

      final [
        Token lb,
        [
          [
            Token k1,
            _,
            [Token lb1, [[Token v1, _], [Token v2, _]], Token rb1],
            _,
          ],
          [
            Token k2,
            _,
            [Token lb2, [[Token k3, _, Token v3, _]], Token rb2],
            _,
          ],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '"a"');
      expect(lb1.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(rb1.value, ']');
      expect(k2.value, '"b"');
      expect(lb2.value, '{');
      expect(k3.value, '"c"');
      expect(v3.value, '3');
      expect(rb2.value, '}');
      expect(rb.value, '}');
    });

    test('should parse a map with whitespace', () {
      final result = parser.parse('{ "a" : 1 , "b" : 2 }');
      final [
        Token lb,
        [
          [Token k1, _, Token v1, _],
          [Token k2, _, Token v2, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(k1.value, '"a"');
      expect(v1.value, '1');
      expect(k2.value, '"b"');
      expect(v2.value, '2');
      expect(rb.value, '}');
    });

    // Negative cases

    test('should fail to parse missing closing brace', () {
      final result = parser.parse('{"a": 1');

      expect(result, isA<Failure>());
      expect(result.message, '"}" expected');
    });

    test('should fail to parse missing opening brace', () {
      final result = parser.parse('"a": 1}');

      expect(result, isA<Failure>());
      expect(result.message, '"{" expected');
    });

    test('should fail to parse not a map', () {
      final result = parser.parse('notamap');

      expect(result, isA<Failure>());
      expect(result.message, '"{" expected');
    });

    test('should fail to parse map with missing colon', () {
      final result = parser.parse('{"a" 1}');

      expect(result, isA<Failure>());
      expect(result.message, '"}" expected');
    });

    test('should fail to parse map with invalid separator', () {
      final result = parser.parse('{1:2 | 3:4}');

      expect(result, isA<Failure>());
      expect(result.message, '"}" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"{" expected');
    });
  });
}
