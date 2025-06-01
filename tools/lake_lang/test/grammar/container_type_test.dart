import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ContainerType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [22] ContainerType ::= MapType | SetType | ListType
    final parser = resolve(grammar.containerType().end());

    // Positive cases

    test('should parse "list<bool>"', () {
      final result = parser.parse('list<bool>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerType.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse "set<i32>"', () {
      final result = parser.parse('set<i32>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'set');
      expect(ld.value, '<');
      expect(innerType.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse "map<string,bool>"', () {
      final result = parser.parse('map<string,bool>');
      expect(result, isA<Success>());

      final [
        Token type,
        Token ld,
        Token innerKeyType,
        Token comma,
        Token innerValueType,
        Token rd,
      ] = result.value as List;

      expect(type.value, 'map');
      expect(ld.value, '<');
      expect(innerKeyType.value, 'string');
      expect(innerValueType.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse nested container "list<list<i64>>"', () {
      final result = parser.parse('list<list<i64>>');
      expect(result, isA<Success>());

      final [
        Token type,
        Token ld,
        [Token innerList, Token innerLd, Token innerType, Token innerRd],
        Token rd,
      ] = result.value as List;

      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerList.value, 'list');
      expect(innerLd.value, '<');
      expect(innerType.value, 'i64');
      expect(innerRd.value, '>');
      expect(rd.value, '>');
    });

    test('should parse nested container "map<string,list<i32>>"', () {
      final result = parser.parse('map<string,list<i32>>');
      expect(result, isA<Success>());

      final [
        Token type,
        Token ld,
        Token innerKeyType,
        Token comma,
        [Token innerList, Token innerLd, Token innerType, Token innerRd],
        Token rd,
      ] = result.value as List;

      expect(type.value, 'map');
      expect(ld.value, '<');
      expect(innerKeyType.value, 'string');
      expect(innerList.value, 'list');
      expect(innerLd.value, '<');
      expect(innerType.value, 'i32');
      expect(innerRd.value, '>');
      expect(rd.value, '>');
    });

    test('should parse deeply nested containers', () {
      final result = parser.parse('list<map<string,list<i32>>>');
      expect(result, isA<Success>());
    });

    test('should parse map with spaces after comma', () {
      final result = parser.parse('map<string, bool>');
      expect(result, isA<Success>());
      final [
        Token type,
        Token ld,
        Token innerKeyType,
        Token comma,
        Token innerValueType,
        Token rd,
      ] = result.value as List;
      expect(type.value, 'map');
      expect(ld.value, '<');
      expect(innerKeyType.value, 'string');
      expect(comma.value, ',');
      expect(innerValueType.value, 'bool');
      expect(rd.value, '>');
    });

    // Negative cases

    test('should fail to parse container with missing type', () {
      final result = parser.parse('list<>');
      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
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
