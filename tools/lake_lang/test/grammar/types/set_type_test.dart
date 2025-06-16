import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.setType().end());

  group('SetType grammar (positive):', () {
    test('should parse "set<bool>"', () {
      final result = parser.parse('set<bool>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse "set<i32>"', () {
      final result = parser.parse('set<i32>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse "set<string>"', () {
      final result = parser.parse('set<string>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "set<binary>"', () {
      final result = parser.parse('set<binary>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(t.value, 'set');
      expect(result, isA<Success>());
      expect(ld.value, '<');
      expect(t1.value, 'binary');
      expect(rd.value, '>');
    });

    test('should parse "set<set<i64>>"', () {
      final result = parser.parse('set<set<i64>>');
      final [
        Token t,
        Token ld,
        [Token t1, Token ld1, Token t2, Token rd1],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'set');
      expect(ld.value, '<');
      expect(t1.value, 'set');
      expect(ld1.value, '<');
      expect(t2.value, 'i64');
      expect(rd1.value, '>');
      expect(rd.value, '>');
    });
  });

  group('SetType grammar (negative):', () {
    test('should fail to parse set with missing type', () {
      final result = parser.parse('set<>');

      expect(result, isA<Failure>());
      expect(result.message, '"letter" or "_" for start identifier expected');
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
