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
    });

    test('should parse const double', () {
      final result = parser.parse('const double PI = 3.14');
      expect(result, isA<Success>());
    });

    test('should parse const string', () {
      final result = parser.parse('const string GREETING = "hello"');
      expect(result, isA<Success>());
    });

    test('should parse const identifier', () {
      final result = parser.parse('const i32 ANSWER = SOME_CONST');
      expect(result, isA<Success>());
    });

    test('should parse const list', () {
      final result = parser.parse('const list<i32> NUMS = [1,2,3]');
      expect(result, isA<Success>());
    });

    test('should parse const map', () {
      final result = parser.parse(
        'const map<string, i32> DICT = {"a":1,"b":2}',
      );
      expect(result, isA<Success>());
    });

    test('should parse const with trailing comma', () {
      final result = parser.parse('const i32 MAX = 100,');
      expect(result, isA<Success>());
    });

    test('should parse const with trailing semicolon', () {
      final result = parser.parse('const i32 MAX = 100;');
      expect(result, isA<Success>());
    });

    test('should parse const with whitespace', () {
      final result = parser.parse('  const   i32   X   =   1  ');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing const keyword', () {
      final result = parser.parse('i32 X = 1');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing type', () {
      final result = parser.parse('const X = 1');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('const i32 = 1');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing equal sign', () {
      final result = parser.parse('const i32 X 1');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing value', () {
      final result = parser.parse('const i32 X =');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
