import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ListType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [25] ListType ::= 'list' '<' FieldType '>'
    final parser = resolve(grammar.listType().end());

    // Positive cases

    test('should parse "list<bool>"', () {
      final result = parser.parse('list<bool>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse "list<i32>"', () {
      final result = parser.parse('list<i32>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'i32');
      expect(rd.value, '>');
    });

    test('should parse "list<string>"', () {
      final result = parser.parse('list<string>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'string');
      expect(rd.value, '>');
    });

    test('should parse "list<binary>"', () {
      final result = parser.parse('list<binary>');
      final [Token t, Token ld, Token t1, Token rd] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'binary');
      expect(rd.value, '>');
    });

    test('should parse "list<list<i64>>"', () {
      final result = parser.parse('list<list<i64>>');
      final [
        Token t,
        Token ld,
        [Token t1, Token ld1, Token t2, Token rd1],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'list');
      expect(ld1.value, '<');
      expect(t2.value, 'i64');
      expect(rd1.value, '>');
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
