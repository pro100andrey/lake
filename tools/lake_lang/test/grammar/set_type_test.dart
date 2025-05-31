import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('SetType Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.setType().end());

    // Positive cases

    test('should parse "set<bool>"', () {
      final result = parser.parse('set<bool>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'set');
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

    test('should parse "set<string>"', () {
      final result = parser.parse('set<string>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'set');
      expect(ld.value, '<');
      expect(innerType.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "set<binary>"', () {
      final result = parser.parse('set<binary>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'set');
      expect(ld.value, '<');
      expect(innerType.value, 'binary');
      expect(rd.value, '>');
    });

    test('should parse "set<set<i64>>"', () {
      final result = parser.parse('set<set<i64>>');
      expect(result, isA<Success>());

      final [
        Token type,
        Token ld,
        [Token innerType, Token innerLd, Token innerInnerType, Token innerRd],
        Token rd,
      ] = result.value as List;

      expect(type.value, 'set');
      expect(ld.value, '<');
      expect(innerType.value, 'set');
      expect(innerLd.value, '<');
      expect(innerInnerType.value, 'i64');
      expect(innerRd.value, '>');
      expect(rd.value, '>');
    });

    // Negative cases

    test('should fail to parse set with missing type', () {
      final result = parser.parse('set<>');
      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse set with extra characters', () {
      final result = parser.parse('set<bool>1');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse set with wrong case', () {
      final result = parser.parse('Set<bool>');
      expect(result, isA<Failure>());
      expect(result.message, '"set" expected');
    });

    test('should fail to parse set with inner space in type', () {
      final result = parser.parse('set<b ool>');
      expect(result, isA<Failure>());
      expect(result.message, '">" expected');
    });

    test('should fail to parse set with non-ascii character', () {
      final result = parser.parse('set<bóol>');
      expect(result, isA<Failure>());
      expect(result.message, '">" expected');
    });

    test('should fail to parse set with separator', () {
      final result = parser.parse('set<bool>;');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, '"set" expected');
    });
  });
}
