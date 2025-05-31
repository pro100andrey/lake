import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('SingleLineComment Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.singleLineComment().trim().end());

    // Positive cases

    test('should parse a simple single-line comment', () {
      final result = parser.parse('// this is a comment\n');
      expect(result, isA<Success>());
    });

    test('should parse a single-line comment without trailing newline', () {
      final result = parser.parse('// comment at end of file');
      expect(result, isA<Success>());
    });

    test('should parse a single-line comment with symbols', () {
      final result = parser.parse('// !@#\$%^&*()_+-=[]{}|;:\'",.<>/?\n');
      expect(result, isA<Success>());
    });

    test('should parse a single-line comment with leading whitespace', () {
      final result = parser.parse('    // indented comment\n');
      expect(result, isA<Success>());
    });

    test('should parse a single-line comment with only slashes', () {
      final result = parser.parse('/////\n');
      expect(result, isA<Success>());
    });

    // Negative cases
    
    test('should fail to parse if not starting with //', () {
      final result = parser.parse('not a comment');
      expect(result, isA<Failure>());
    });

    test('should fail to parse multi-line comment as single-line', () {
      final result = parser.parse('/* not a single-line comment */');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
