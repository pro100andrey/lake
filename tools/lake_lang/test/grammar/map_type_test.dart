import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('MapType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [23] MapType ::= 'map' '<' FieldType ',' FieldType '>'
    final parser = resolve(grammar.mapType().end());

    // Positive cases

    test('should parse "map<string, bool>"', () {
      final result = parser.parse('map<string,bool>');
      final [
        Token t1,
        Token ld,
        Token keyT,
        Token comma,
        Token valueT,
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t1.value, 'map');
      expect(ld.value, '<');
      expect(keyT.value, 'string');
      expect(comma.value, ',');
      expect(valueT.value, 'bool');
      expect(rd.value, '>');
    });

    test('should parse "map<i32, i64>"', () {
      final result = parser.parse('map<i32,i64>');
      final [
        Token t1,
        Token ld,
        Token kt,
        _,
        Token vt,
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t1.value, 'map');
      expect(ld.value, '<');
      expect(kt.value, 'i32');
      expect(vt.value, 'i64');
      expect(rd.value, '>');
    });

    test('should parse "map<string, list<double>>"', () {
      final result = parser.parse('map<string,list<double>>');
      final [
        Token t1,
        Token ld,
        Token kt,
        _,
        [Token vt, Token ld1, Token t2, Token rd1],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t1.value, 'map');
      expect(ld.value, '<');
      expect(kt.value, 'string');
      expect(vt.value, 'list');
      expect(ld1.value, '<');
      expect(t2.value, 'double');
      expect(rd1.value, '>');
      expect(rd.value, '>');
    });

    // Negative cases

    test('should fail to parse map with missing key type', () {
      final result = parser.parse('map<,bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse map with missing value type', () {
      final result = parser.parse('map<string,>');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('map<string bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"," expected');
    });

    test('should fail to parse map with extra characters', () {
      final result = parser.parse('map<string,bool>1');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse map with wrong case', () {
      final result = parser.parse('Map<string,bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"map" expected');
    });

    test('should fail to parse map with inner space in key type', () {
      final result = parser.parse('map<str ing,bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"," expected');
    });

    test('should fail to parse map with non-ascii character', () {
      final result = parser.parse('map<stríng,bool>');

      expect(result, isA<Failure>());
      expect(result.message, '"," expected');
    });

    test('should fail to parse map with separator', () {
      final result = parser.parse('map<string,bool>;');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"map" expected');
    });
  });
}
