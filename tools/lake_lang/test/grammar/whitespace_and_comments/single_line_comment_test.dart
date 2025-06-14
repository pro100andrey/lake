import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.singleLineComment().trim().end());

  group('SingleLineComment grammar (positive):', () {
    test('should parse a simple single-line comment', () {
      final result = parser.parse('// this is a comment\n');
      final comment = result.value as String;

      expect(result, isA<Success>());
      expect(comment, '// this is a comment\n');
    });

    test('should parse a single-line comment without trailing newline', () {
      final result = parser.parse('// comment at end of file');
      final comment = result.value as String;

      expect(result, isA<Success>());
      expect(comment, '// comment at end of file');
    });

    test('should parse a single-line comment with symbols', () {
      final result = parser.parse('// !@#\$%^&*()_+-=[]{}|;:\'",.<>/?\n');
      final comment = result.value as String;

      expect(result, isA<Success>());
      expect(comment, '// !@#\$%^&*()_+-=[]{}|;:\'",.<>/?\n');
    });

    test('should parse a single-line comment with leading whitespace', () {
      final result = parser.parse('    // indented comment\n');
      final comment = result.value as String;

      expect(result, isA<Success>());
      expect(comment, '// indented comment\n');
    });

    test('should parse a single-line comment with only slashes', () {
      final result = parser.parse('/////\n');
      final comment = result.value as String;

      expect(result, isA<Success>());
      expect(comment, '/////\n');
    });
  });

  group('SingleLineComment grammar (negative):', () {
    test('should fail to parse if not starting with //', () {
      final result = parser.parse('not a comment');

      expect(result, isA<Failure>());
      expect(result.message, '"//" expected');
    });

    test('should fail to parse multi-line comment as single-line', () {
      final result = parser.parse('/* not a single-line comment */');

      expect(result, isA<Failure>());
      expect(result.message, '"//" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"//" expected');
    });
  });
}
