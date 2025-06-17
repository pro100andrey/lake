import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.literalValue().end());

  group('LiteralValue grammar (positive):', () {
    test('should parse a double literal', () {
      final result = parser.parse('1.23');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '1.23');
    });

    test('should parse an int literal', () {
      final result = parser.parse('-42');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '-42');
    });

    test('should parse a string literal (double quotes)', () {
      final result = parser.parse('"hello"');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '"hello"');
    });

    test('should parse a string literal (single quotes)', () {
      final result = parser.parse("'world'");
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, "'world'");
    });

    test('should parse an identifier', () {
      final result = parser.parse('SOME_CONST');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'SOME_CONST');
    });

    test('should parse a list literal', () {
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

    test('should parse a list literal with mixed values', () {
      final result = parser.parse('[1, "two", SOME_CONST]');
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
      expect(v2.value, '"two"');
      expect(v3.value, 'SOME_CONST');
      expect(rb.value, ']');
    });

    test('should parse an empty list literal', () {
      final result = parser.parse('[]');
      final [Token lb, List values, Token rb] = result.value as List;

      expect(lb.value, '[');
      expect(result, isA<Success>());
      expect(values, isEmpty);
      expect(rb.value, ']');
    });

    test('should parse a map literal', () {
      final result = parser.parse('{"a": 1, "b": 2}');
      final [
        Token lb,
        [
          [Token key1, _, Token val1, _],
          [Token key2, _, Token val2, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(key1.value, '"a"');
      expect(val1.value, '1');
      expect(key2.value, '"b"');
      expect(val2.value, '2');
      expect(rb.value, '}');
    });

    test('should parse a map literal with mixed values', () {
      final result = parser.parse('{"x": SOME_CONST, "y": [1,2]}');
      final [
        Token lb,
        [
          [Token key1, Token _, Token val1, Token _],
          [
            Token key2,
            _,
            [Token lb1, [[Token v1, _], [Token v2, _]], Token rb1],
            _,
          ],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(key1.value, '"x"');
      expect(val1.value, 'SOME_CONST');
      expect(key2.value, '"y"');
      expect(lb1.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(rb1.value, ']');
      expect(rb.value, '}');
    });

    test('should parse an empty map literal', () {
      final result = parser.parse('{}');
      final [Token lb, List values, Token rb] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '{');
      expect(values, isEmpty);
      expect(rb.value, '}');
    });

    test('should parse a nested list and map literal', () {
      final result = parser.parse('[{"a": [1,2]}, 3]');
      final [
        Token lb,
        [
          [
            [
              Token lb1,
              [
                [
                  Token key,
                  _,
                  [Token lb2, [[Token lv1, _], [Token lv2, _]], Token rb2],
                  _,
                ],
              ],
              Token rb1,
            ],
            _,
          ],
          [Token intValue, _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(lb.value, '[');
      expect(lb1.value, '{');
      expect(key.value, '"a"');
      expect(lb2.value, '[');
      expect(lv1.value, '1');
      expect(lv2.value, '2');
      expect(rb2.value, ']');
      expect(rb1.value, '}');
      expect(intValue.value, '3');
      expect(rb.value, ']');
    });
  });

  group('LiteralValue grammar (negative):', () {
    test('should fail to parse invalid literal', () {
      final result = parser.parse('"unterminated');

      expect(result, isA<Failure>());
      expect(result.message, 'literal expected');
    });

    test('should fail to parse invalid int literal', () {
      final result = parser.parse('--1');

      expect(result, isA<Failure>());
      expect(result.message, 'literal expected');
    });

    test('should fail to parse invalid list literal', () {
      final result = parser.parse('[1, 2');

      expect(result, isA<Failure>());
      expect(result.message, 'literal expected');
    });

    test('should fail to parse invalid map literal', () {
      final result = parser.parse('{"a": 1, "b" 2}');

      expect(result, isA<Failure>());
      expect(result.message, 'literal expected');
    });

    test('should fail to parse empty string literal', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, 'literal expected');
    });
  });
}
