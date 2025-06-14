import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.field().end());

  group('Field grammar (positive):', () {
    test('should parse a simple field', () {
      final result = parser.parse('i32 count');
      final [
        _,
        _,
        Token t,
        Token id,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'i32');
      expect(id.value, 'count');
    });

    test('should parse a field with field id', () {
      final result = parser.parse('1: i32 count');
      final [
        [Token idx, Token colon],
        _,
        Token t,
        Token id,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(idx.value, '1');
      expect(colon.value, ':');
      expect(t.value, 'i32');
      expect(id.value, 'count');
    });

    test('should parse a field with field id and required', () {
      final result = parser.parse('2: required string name');
      final [
        [Token idx, Token colon],
        Token req,
        Token type,
        Token id,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(idx.value, '2');
      expect(colon.value, ':');
      expect(req.value, 'required');
      expect(type.value, 'string');
      expect(id.value, 'name');
    });

    test('should parse a field with field id and optional', () {
      final result = parser.parse('3: optional bool flag');

      final [
        [Token idx, Token colon],
        Token opt,
        Token type,
        Token id,
        _,
        _,
      ] = result.value as List;
      expect(result, isA<Success>());
      expect(idx.value, '3');
      expect(colon.value, ':');
      expect(opt.value, 'optional');
      expect(type.value, 'bool');
      expect(id.value, 'flag');
    });

    test('should parse a field with default value', () {
      final result = parser.parse('i32 count = 0');
      final [
        _,
        _,
        Token t,
        Token id,
        [
          Token eq,
          Token v,
        ],
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'i32');
      expect(id.value, 'count');
      expect(eq.value, '=');
      expect(v.value, '0');
    });

    test('should parse a field with field id, required, and default value', () {
      final result = parser.parse('4: required i32 count = 10');
      final [
        [Token idx, Token colon],
        Token req,
        Token t,
        Token id,
        [
          Token eq,
          Token v,
        ],
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(idx.value, '4');
      expect(colon.value, ':');
      expect(req.value, 'required');
      expect(t.value, 'i32');
      expect(id.value, 'count');
      expect(eq.value, '=');
      expect(v.value, '10');
    });

    test('should parse a field with list type', () {
      final result = parser.parse('list<string> tags');
      final [
        _,
        _,
        [Token t, Token ld, Token t1, Token rd],
        Token id,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(rd.value, '>');
      expect(id.value, 'tags');
    });

    test('should parse a field with map type and default value', () {
      final result = parser.parse('map<string, i32> dict = {}');
      final [
        _,
        _,
        [Token t, Token ld, Token t1, Token sep, Token t2, Token rd],
        Token id,
        [Token eq, [Token rd1, List values, Token rd2]],
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(sep.value, ',');
      expect(t2.value, 'i32');
      expect(rd.value, '>');
      expect(id.value, 'dict');
      expect(eq.value, '=');
      expect(rd1.value, '{');
      expect(values, isEmpty);
      expect(rd2.value, '}');
    });

    test('should parse a field with trailing comma', () {
      final result = parser.parse('i32 count,');
      final [_, _, Token t, Token id, _, Token sep] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'i32');
      expect(id.value, 'count');
      expect(sep.value, ',');
    });

    test('should parse a field with trailing semicolon', () {
      final result = parser.parse('i32 count;');
      final [_, _, Token t, Token id, _, Token sep] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'i32');
      expect(id.value, 'count');
      expect(sep.value, ';');
    });

    test('should parse a field with whitespace', () {
      final result = parser.parse('   i32    count   ');
      final [_, _, Token t, Token id, _, _] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'i32');
      expect(id.value, 'count');
    });
  });

  group('Field grammar (negative):', () {
    test('should fail to parse missing type', () {
      final result = parser.parse('count');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('i32');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse invalid field id', () {
      final result = parser.parse('abc: i32 count');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse invalid default value', () {
      final result = parser.parse('i32 count =');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });
  });
}
