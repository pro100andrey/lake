import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Function Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [16] Function ::= FunctionType Identifier
    // '(' StreamType identifier | Field* ')' Throws? ListSeparator?
    final parser = resolve(grammar.function().end());

    // Positive cases

    test('should parse function with no arguments', () {
      final result = parser.parse('void foo()');
      expect(result, isA<Success>());
    });

    test('should parse function with one field argument', () {
      final result = parser.parse('i32 bar(i32 x)');
      expect(result, isA<Success>());
    });

    test('should parse function with multiple field arguments', () {
      final result = parser.parse('string baz(i32 x, string y)');
      expect(result, isA<Success>());
    });

    test('should parse function with stream argument', () {
      final result = parser.parse('void streamFunc(stream<i32> s)');
      expect(result, isA<Success>());
    });

    test('should parse function with throws clause', () {
      final result = parser.parse(
        'void errFunc() throws (i32 code, string msg)',
      );
      expect(result, isA<Success>());
    });

    test('should parse function with trailing comma', () {
      final result = parser.parse('void foo(),');
      expect(result, isA<Success>());
    });

    test('should parse function with trailing semicolon', () {
      final result = parser.parse('void foo();');
      expect(result, isA<Success>());
    });

    test('should parse function with whitespace', () {
      final result = parser.parse('  i32   spaced  (  i32   x  ,  i32 y )  ');
      expect(result, isA<Success>());
    });

    test('should parse function with no return type (identifier)', () {
      final result = parser.parse('CustomType customFunc()');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing parentheses', () {
      final result = parser.parse('void foo');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing function name', () {
      final result = parser.parse('void ()');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid argument', () {
      final result = parser.parse('void foo(,)');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });

    test('should fail to parse only type', () {
      final result = parser.parse('i32');
      expect(result, isA<Failure>());
    });
  });
}
