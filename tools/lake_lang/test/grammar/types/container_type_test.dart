import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.containerType().end());

  group('ContainerType grammar (positive):', () {
    test('should parse "list<bool>"', () {
      final result = parser.parse('list<bool>');
      expect(result, isA<Success>());

      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse "set<i32>"', () {
      final result = parser.parse('set<i32>');
      expect(result, isA<Success>());

      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse "map<string,bool>"', () {
      final result = parser.parse('map<string,bool>');
      expect(result, isA<Success>());

      final [
        Token t,
        Token ld,
        Token kt,
        _,
        Token vt,
        Token rd,
      ] = result.value as List;

      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(kt.value, 'string');
      expect(vt.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse nested container "list<list<i64>>"', () {
      final result = parser.parse('list<list<i64>>');
      expect(result, isA<Success>());

      final [
        Token t,
        Token ld,
        [Token t1, Token ld1, Token t2, Token rd1],
        Token rd,
      ] = result.value as List;

      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'list');
      expect(ld1.value, '<');
      expect(t2.value, 'i64');
      expect(rd1.value, '>');
      expect(rd.value, '>');
    });

    test('should parse nested container "map<string,list<i32>>"', () {
      final result = parser.parse('map<string,list<i32>>');
      expect(result, isA<Success>());

      final [
        Token t,
        Token ld,
        Token kt,
        Token _,
        [Token vt, Token ld1, Token t2, Token rd1],
        Token rd,
      ] = result.value as List;

      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(kt.value, 'string');
      expect(vt.value, 'list');
      expect(ld1.value, '<');
      expect(t2.value, 'i32');
      expect(rd1.value, '>');
      expect(rd.value, '>');
    });

    test('should parse deeply nested containers', () {
      final result = parser.parse('list<map<string,list<i32>>>');
      final [
        Token t,
        Token ld,
        [
          Token t1,
          Token ld1,
          Token kt,
          Token _,
          [Token vt, Token ld2, Token t2, Token rd2],
          Token rd1,
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'map');
      expect(ld1.value, '<');
      expect(kt.value, 'string');
      expect(vt.value, 'list');
      expect(ld2.value, '<');
      expect(t2.value, 'i32');
      expect(rd2.value, '>');
      expect(rd1.value, '>');
      expect(rd.value, '>');
    });

    test('should parse map with spaces after comma', () {
      final result = parser.parse('map<string, bool>');
      final [Token t, Token ld, Token kt, Token _, Token vt, Token rd] =
          result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'map');
      expect(ld.value, '<');
      expect(kt.value, 'string');
      expect(vt.value, 'bool');
      expect(rd.value, '>');
    });
  });

  group('ContainerType grammar (negative):', () {
    test('should fail to parse container with missing type', () {
      final result = parser.parse('list<>');

      expect(result, isA<Failure>());
      expect(result.message, '"letter" or "_" for start identifier expected');
    });

    test('should fail to parse container with extra characters', () {
      final result = parser.parse('set<bool>1');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse container with wrong case', () {
      final result = parser.parse('List<bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse container with non-ascii character', () {
      final result = parser.parse('set<bóol>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse container with separator', () {
      final result = parser.parse('list<bool>;');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('map<string bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse map with extra comma', () {
      final result = parser.parse('map<string,,bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse unknown container', () {
      final result = parser.parse('bag<i32>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse container with space in name', () {
      final result = parser.parse('li st<i32>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse map with one type', () {
      final result = parser.parse('map<string>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse map with empty types', () {
      final result = parser.parse('map<>');

      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });
  });
}
