import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('MultiLineComment Rule:', () {
    final grammar = LakeGrammarDefinition();
    // MultiLineComment ::= '/*' ( MultiLineComment | [^*] )* '*/'
    final parser = resolve(grammar.multiLineComment().trim().end());

    // Positive cases

    test('should parse a simple multi-line comment', () {
      final result = parser.parse('/* this is a comment */');
      final String value = result.value;

      expect(result, isA<Success>());
      expect(value, '/* this is a comment */');
    });

    test('should parse a multi-line comment with line breaks', () {
      final result = parser.parse('/* line 1\nline 2\nline 3 */');
      final String value = result.value;

      expect(result, isA<Success>());
      expect(value, '/* line 1\nline 2\nline 3 */');
    });

    test('should parse a multi-line comment with symbols', () {
      final result = parser.parse('/* !@#\$%^&*()_+-=[]{}|;:\'",.<>/? */');
      final String value = result.value;

      expect(result, isA<Success>());
      expect(value, '/* !@#\$%^&*()_+-=[]{}|;:\'",.<>/? */');
    });

    test('should parse a multi-line comment with nested comment markers', () {
      final result = parser.parse('/* outer /* inner */ outer */');
      final String value = result.value;

      expect(result, isA<Success>());
      expect(value, '/* outer /* inner */ outer */');
    });

    test('should parse a multi-line comment with leading whitespace', () {
      final result = parser.parse('   /* indented comment */');
      final String value = result.value;

      expect(result, isA<Success>());
      expect(value, '/* indented comment */');
    });

    test('should parse an empty multi-line comment', () {
      final result = parser.parse('/**/');
      final String value = result.value;

      expect(result, isA<Success>());
      expect(value, '/**/');
    });

    // Negative cases

    test('should fail to parse if not starting with /*', () {
      final result = parser.parse('not a comment');

      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });

    test('should fail to parse single-line comment as multi-line', () {
      final result = parser.parse('// not a multi-line comment');

      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });

    test('should fail to parse unterminated multi-line comment', () {
      final result = parser.parse('/* unterminated comment');

      expect(result, isA<Failure>());
      expect(result.message, '"*/" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      
      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });
  });
}
