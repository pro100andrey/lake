import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ListType Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.listType().end());

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

    test('should parse "list<i32>"', () {
      final result = parser.parse('list<i32>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerType.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse "list<string>"', () {
      final result = parser.parse('list<string>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerType.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "list<binary>"', () {
      final result = parser.parse('list<binary>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerType.value, 'binary');
      expect(rd.value, '>');
    });

    test('should parse "list<list<i64>>"', () {
      final result = parser.parse('list<list<i64>>');
      expect(result, isA<Success>());

      final [
        Token type,
        Token ld,
        [Token innerType, Token innerLd, Token innerInnerType, Token innerRd],
        Token rd,
      ] = result.value as List;

      expect(type.value, 'list');
      expect(ld.value, '<');
      expect(innerType.value, 'list');
      expect(innerLd.value, '<');
      expect(innerInnerType.value, 'i64');
      expect(innerRd.value, '>');
      expect(rd.value, '>');
    });

    // Negative cases

    test('should fail to parse list with missing type', () {
      final result = parser.parse('list<>');
      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse list with extra characters', () {
      final result = parser.parse('list<bool>1');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse list with wrong case', () {
      final result = parser.parse('List<bool>');
      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });

    test('should fail to parse list with inner space in type', () {
      final result = parser.parse('list<b ool>');
      expect(result, isA<Failure>());
      expect(result.message, '">" expected');
    });

    test('should fail to parse list with non-ascii character', () {
      final result = parser.parse('list<bóol>');
      expect(result, isA<Failure>());
      expect(result.message, '">" expected');
    });

    test('should fail to parse list with separator', () {
      final result = parser.parse('list<bool>;');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, '"list" expected');
    });
  });
}
