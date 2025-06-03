import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ConstDefinition Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [7] Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
    final parser = resolve(grammar.constDefinition().end());

    // Positive cases

    test('should parse const int', () {
      final result = parser.parse('const i32 MAX_COUNT = 10');
      expect(result, isA<Success>());
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(keyword.value, 'const');
      expect(type.value, 'i32');
      expect(identifier.value, 'MAX_COUNT');
      expect(equal.value, '=');
      expect(value.value, '10');
      expect(separator, isNull);
    });

    test('should parse const double', () {
      final result = parser.parse('const double PI = 3.14');
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'double');
      expect(identifier.value, 'PI');
      expect(equal.value, '=');
      expect(value.value, '3.14');
      expect(separator, isNull);
    });

    test('should parse const string', () {
      final result = parser.parse('const string GREETING = "hello"');
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'string');
      expect(identifier.value, 'GREETING');
      expect(equal.value, '=');
      expect(value.value, '"hello"');
      expect(separator, isNull);
    });

    test('should parse const identifier', () {
      final result = parser.parse('const i32 ANSWER = SOME_CONST');
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'i32');
      expect(identifier.value, 'ANSWER');
      expect(equal.value, '=');
      expect(value.value, 'SOME_CONST');
      expect(separator, isNull);
    });

    test('should parse const list', () {
      final result = parser.parse('const list<i32> NUMS = [1,2,3]');
      final [
        Token keyword,
        [Token type, Token lb, Token t1, Token rb],
        Token identifier,
        Token equal,
        [Token lb1, [[Token v1, _], [Token v2, _], [Token v3, _]], Token rb1],
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'list');
      expect(lb.value, '<');
      expect(t1.value, 'i32');
      expect(rb.value, '>');
      expect(identifier.value, 'NUMS');
      expect(equal.value, '=');
      expect(lb1.value, '[');
      expect(v1.value, '1');
      expect(v2.value, '2');
      expect(v3.value, '3');
      expect(rb1.value, ']');
    });

    test('should parse const map', () {
      final result = parser.parse(
        'const map<string, i32> DICT = {"a":1,"b":2}',
      );
      final [
        Token keyword,
        [Token type, Token lb, Token t1, Token _, Token t2, Token rb],
        Token identifier,
        Token equal,
        [Token lb1, List mapValues, Token rb1],
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'map');
      expect(lb.value, '<');
      expect(t1.value, 'string');
      expect(t2.value, 'i32');
      expect(rb.value, '>');
      expect(identifier.value, 'DICT');
      expect(equal.value, '=');
      expect(lb1.value, '{');
      expect(rb1.value, '}');
    });

    test('should parse const with trailing comma', () {
      final result = parser.parse('const i32 MAX = 100,');
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'i32');
      expect(identifier.value, 'MAX');
      expect(equal.value, '=');
      expect(value.value, '100');
      expect(separator, isNotNull);
    });

    test('should parse const with trailing semicolon', () {
      final result = parser.parse('const i32 MAX = 100;');
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'i32');
      expect(identifier.value, 'MAX');
      expect(equal.value, '=');
      expect(value.value, '100');
      expect(separator, isNotNull);
    });

    test('should parse const with whitespace', () {
      final result = parser.parse('  const   i32   X   =   1  ');
      final [
        Token keyword,
        Token type,
        Token identifier,
        Token equal,
        Token value,
        Token? separator,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'const');
      expect(type.value, 'i32');
      expect(identifier.value, 'X');
      expect(equal.value, '=');
      expect(value.value, '1');
      expect(separator, isNull);
    });

    // Negative cases

    test('should fail to parse missing const keyword', () {
      final result = parser.parse('i32 X = 1');
      expect(result, isA<Failure>());
      expect(result.message, '"const" expected');
    });

    test('should fail to parse missing type', () {
      final result = parser.parse('const X = 1');
      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('const i32 = 1');
      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse missing equal sign', () {
      final result = parser.parse('const i32 X 1');
      expect(result, isA<Failure>());
      expect(result.message, '"=" expected');
    });

    test('should fail to parse missing value', () {
      final result = parser.parse('const i32 X =');
      expect(result, isA<Failure>());
      expect(result.message, '"\\\'" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, '"const" expected');
    });
  });
}
