import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('StreamType Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.streamType().end());

    // Positive cases

    test('should parse "stream<bool>"', () {
      final result = parser.parse('stream<bool>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'stream');
      expect(ld.value, '<');
      expect(innerType.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse "stream<i32>"', () {
      final result = parser.parse('stream<i32>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'stream');
      expect(ld.value, '<');
      expect(innerType.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse "stream<string>"', () {
      final result = parser.parse('stream<string>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'stream');
      expect(ld.value, '<');
      expect(innerType.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "stream<binary>"', () {
      final result = parser.parse('stream<binary>');
      expect(result, isA<Success>());

      final [Token type, Token ld, Token innerType, Token rd] =
          result.value as List;

      expect(type.value, 'stream');
      expect(ld.value, '<');
      expect(innerType.value, 'binary');
      expect(rd.value, '>');
    });

    // Negative cases

    test('should fail to parse stream with missing type', () {
      final result = parser.parse('stream<>');
      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse stream with extra characters', () {
      final result = parser.parse('stream<bool>1');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse stream with wrong case', () {
      final result = parser.parse('Stream<bool>');
      expect(result, isA<Failure>());
      expect(result.message, '"stream" expected');
    });

    test('should fail to parse stream with inner space in type', () {
      final result = parser.parse('stream<b ool>');
      expect(result, isA<Failure>());
      expect(result.message, '">" expected');
    });

    test('should fail to parse stream with non-ascii character', () {
      final result = parser.parse('stream<bóol>');
      expect(result, isA<Failure>());
      expect(result.message, '">" expected');
    });

    test('should fail to parse stream with separator', () {
      final result = parser.parse('stream<bool>;');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, '"stream" expected');
    });
  });
}
