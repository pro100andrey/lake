import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Identifier Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [33] Identifier ::= ( Letter | '_' ) ( ( Letter | Digit | '_' )*
    // ( '.' ( Letter | Digit | '_' )+ )* )
    final parser = resolve(grammar.identifier().end());

    // Positive Test Cases

    test('should parse a simple identifier', () {
      final result = parser.parse('foo');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'foo');
    });

    test('should parse an identifier starting with underscore', () {
      final result = parser.parse('_bar');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '_bar');
    });

    test('should parse an identifier with digits', () {
      final result = parser.parse('foo123');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'foo123');
    });

    test('should parse an identifier with dots', () {
      final result = parser.parse('foo.bar.baz');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'foo.bar.baz');
    });

    test('should parse an identifier with underscores and digits', () {
      final result = parser.parse('_foo_123_bar');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '_foo_123_bar');
    });

    test('should parse a single letter identifier', () {
      final result = parser.parse('a');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'a');
    });

    test('should parse a single underscore identifier', () {
      final result = parser.parse('_');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '_');
    });

    test('should parse identifier with trailing dot and underscore', () {
      final result = parser.parse('foo_bar._baz');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'foo_bar._baz');
    });

    test('should parse identifier with leading/trailing whitespace', () {
      final result = parser.parse('   foo_bar   ');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'foo_bar');
    });

    test('should parse identifier with uppercase letters', () {
      final result = parser.parse('FOO_BAR');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, 'FOO_BAR');
    });

    // Negative Test Cases

    test('should fail to parse identifier starting with digit', () {
      final result = parser.parse('1foo');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse identifier starting with dot', () {
      final result = parser.parse('.foo');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse identifier with invalid character', () {
      final result = parser.parse('foo-bar');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse identifier with space inside', () {
      final result = parser.parse('foo bar');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse identifier with special character', () {
      final result = parser.parse(r'foo$bar');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse identifier with consecutive dots', () {
      final result = parser.parse('foo..bar');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse identifier ending with dot', () {
      final result = parser.parse('foo.');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse identifier with non-ascii letter', () {
      final result = parser.parse('имя');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse identifier with tab inside', () {
      final result = parser.parse('foo\tbar');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
