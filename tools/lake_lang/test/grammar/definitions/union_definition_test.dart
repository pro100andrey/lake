import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.unionDefinition().end());

  group('UnionDefinition grammar (positive):', () {
    test('should parse empty union', () {
      final result = parser.parse('union Empty {}');
      final [
        Token keyword,
        Token id,
        Token ld,
        List fields,
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'Empty');
      expect(ld.value, '{');
      expect(fields, isEmpty);
      expect(rd.value, '}');
    });

    test('should parse union with one field', () {
      final result = parser.parse('union Point { i32 x }');
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [_, _, Token t, Token id2, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'Point');
      expect(ld.value, '{');
      expect(t.value, 'i32');
      expect(id2.value, 'x');
      expect(rd.value, '}');
    });

    test('should parse union with multiple fields', () {
      final result = parser.parse('union Point { i32 x; i32 y; }');
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [_, _, Token t1, Token id1, _, _],
          [_, _, Token t2, Token id2, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'Point');
      expect(ld.value, '{');
      expect(t1.value, 'i32');
      expect(id1.value, 'x');
      expect(t2.value, 'i32');
      expect(id2.value, 'y');
      expect(rd.value, '}');
    });

    test('should parse union with field ids and required', () {
      final result = parser.parse(
        'union User { 1: required string name; 2: i32 age }',
      );
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [[Token idx, _], Token req, Token t1, Token id1, _, _],
          [[Token idx2, _], Token? req1, Token t2, Token id2, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'User');
      expect(ld.value, '{');
      expect(idx.value, '1');
      expect(req.value, 'required');
      expect(t1.value, 'string');
      expect(id1.value, 'name');
      expect(idx2.value, '2');
      expect(req1?.value, isNull);
      expect(t2.value, 'i32');
      expect(id2.value, 'age');
      expect(rd.value, '}');
    });

    test('should parse union with default values', () {
      final result = parser.parse(
        'union Config { bool enabled = true; i32 count = 10 }',
      );
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [_, _, Token t1, Token id1, [Token eq1, Token v1], Token sep],
          [_, _, Token t2, Token id2, [Token eq2, Token v2], Token? sep2],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'Config');
      expect(ld.value, '{');
      expect(t1.value, 'bool');
      expect(id1.value, 'enabled');
      expect(eq1.value, '=');
      expect(v1.value, 'true');
      expect(sep.value, ';');
      expect(t2.value, 'i32');
      expect(id2.value, 'count');
      expect(eq2.value, '=');
      expect(v2.value, '10');
      expect(sep2, isNull);
      expect(rd.value, '}');
    });

    test('should parse union with trailing comma', () {
      final result = parser.parse('union S { i32 x, }');
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [_, _, Token t, Token id2, _, Token sep],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t.value, 'i32');
      expect(id2.value, 'x');
      expect(sep.value, ',');
      expect(rd.value, '}');
    });

    test('should parse union with trailing semicolon', () {
      final result = parser.parse('union S { i32 x; }');
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [_, _, Token t, Token id2, _, Token sep],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t.value, 'i32');
      expect(id2.value, 'x');
      expect(sep.value, ';');
      expect(rd.value, '}');
    });

    test('should parse union with whitespace', () {
      final result = parser.parse(
        '  union   S   {   i32   x   ;   i32 y   }  ',
      );
      final [
        Token keyword,
        Token id,
        Token ld,
        [
          [_, _, Token t1, Token id1, _, _],
          [_, _, Token t2, Token id2, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'union');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t1.value, 'i32');
      expect(id1.value, 'x');
      expect(t2.value, 'i32');
      expect(id2.value, 'y');
      expect(rd.value, '}');
    });
  });

  group('UnionDefinition grammar (negative):', () {
    test('should fail to parse missing union keyword', () {
      final result = parser.parse('Point { i32 x }');

      expect(result, isA<Failure>());
      expect(result.message, '"union" expected');
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('union { i32 x }');

      expect(result, isA<Failure>());
      expect(result.message, '"letter" or "_" for start identifier expected');
    });

    test('should fail to parse missing braces', () {
      final result = parser.parse('union Point i32 x; i32 y;');

      expect(result, isA<Failure>());
      expect(result.message, '"{" expected');
    });

    test('should fail to parse invalid field', () {
      final result = parser.parse('union S { x }');

      expect(result, isA<Failure>());
      expect(result.message, '"}" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"union" expected');
    });
  });
}
