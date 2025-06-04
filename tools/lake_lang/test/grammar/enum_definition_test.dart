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
      final [
        Token keyword,
        Token id,
        Token lb,
        List values,
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'Color');
      expect(lb.value, '{');
      expect(values, isEmpty);
      expect(rb.value, '}');
    });

    test('should parse enum with values', () {
      final result = parser.parse('enum Color { RED, GREEN, BLUE }');
      final [
        Token keyword,
        Token id,
        Token lb,
        [[Token id1, _, _], [Token id2, _, _], [Token id3, _, _]],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'Color');
      expect(lb.value, '{');
      expect(id1.value, 'RED');
      expect(id2.value, 'GREEN');
      expect(id3.value, 'BLUE');
      expect(rb.value, '}');
    });

    test('should parse enum with values and explicit int', () {
      final result = parser.parse('enum Status { OK = 0, ERROR = 1 }');
      final [
        Token keyword,
        Token id,
        Token lb,
        [
          [Token id1, [Token _, Token v1], _],
          [Token id2, [Token _, Token v2], _],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'Status');
      expect(lb.value, '{');
      expect(id1.value, 'OK');
      expect(v1.value, '0');
      expect(id2.value, 'ERROR');
      expect(v2.value, '1');
      expect(rb.value, '}');
    });

    test('should parse enum with trailing comma', () {
      final result = parser.parse('enum E { A, B, }');
      final [
        Token keyword,
        Token id,
        Token lb,
        [
          [Token id1, _, Token sep1],
          [Token id2, _, Token sep2],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'E');
      expect(lb.value, '{');
      expect(id1.value, 'A');
      expect(sep1.value, ',');
      expect(id2.value, 'B');
      expect(sep2.value, ',');
      expect(rb.value, '}');
    });

    test('should parse enum with trailing semicolon', () {
      final result = parser.parse('enum E { A; B; }');
      final [
        Token keyword,
        Token id,
        Token lb,
        [
          [Token id1, _, Token sep1],
          [Token id2, _, Token sep2],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'E');
      expect(lb.value, '{');
      expect(id1.value, 'A');
      expect(sep1.value, ';');
      expect(id2.value, 'B');
      expect(sep2.value, ';');
      expect(rb.value, '}');
    });

    test('should parse enum with whitespace', () {
      final result = parser.parse('  enum   E   {   A ,  B   }  ');
      final [
        Token keyword,
        Token id,
        Token lb,
        [[Token id1, _, _], [Token id2, _, _]],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'E');
      expect(lb.value, '{');
      expect(id1.value, 'A');
      expect(id2.value, 'B');
      expect(rb.value, '}');
    });

    test('should parse enum with mixed separators', () {
      final result = parser.parse('enum E { A, B; C, }');
      final [
        Token keyword,
        Token id,
        Token lb,
        [
          [Token id1, _, Token sep1],
          [Token id2, _, Token sep2],
          [Token id3, _, Token sep3],
        ],
        Token rb,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'enum');
      expect(id.value, 'E');
      expect(lb.value, '{');
      expect(id1.value, 'A');
      expect(sep1.value, ',');
      expect(id2.value, 'B');
      expect(sep2.value, ';');
      expect(id3.value, 'C');
      expect(sep3.value, ',');
      expect(rb.value, '}');
    });

    // Negative cases

    test('should fail to parse missing enum keyword', () {
      final result = parser.parse('Color { RED, GREEN }');

      expect(result, isA<Failure>());
      expect(result.message, '"enum" expected');
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('enum { RED, GREEN }');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse missing braces', () {
      final result = parser.parse('enum Color RED, GREEN');

      expect(result, isA<Failure>());
      expect(result.message, '"{" expected');
    });

    test('should fail to parse invalid enum value', () {
      final result = parser.parse('enum E { = 1 }');

      expect(result, isA<Failure>());
      expect(result.message, '"}" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      
      expect(result, isA<Failure>());
      expect(result.message, '"enum" expected');
    });
  });
}
