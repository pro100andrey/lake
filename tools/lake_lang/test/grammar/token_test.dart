import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Token Rule:', () {
    final grammar = LakeGrammarDefinition();

    final parser = resolve(ref1(grammar.token, 'const').end());
    // Positive Test Cases

    test('should parse a simple keyword without surrounding whitespace or '
        'comments', () {
      final result = parser.parse('const');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with leading spaces', () {
      final result = parser.parse('   const');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with trailing tabs', () {
      final result = parser.parse('const\t\t');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with leading and trailing newlines', () {
      final result = parser.parse('\nconst\n');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with a single-line comment before', () {
      final result = parser.parse('// My comment\nconst');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with a single-line comment after', () {
      final result = parser.parse('const// My comment');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with a multi-line comment before', () {
      final result = parser.parse('/* Multi\nline\ncomment */const');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with a multi-line comment after', () {
      final result = parser.parse('const/* Multi\nline\ncomment */');
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    test('should parse a keyword with mixed whitespace and comments', () {
      final result = parser.parse(
        '   /* C1 */ \n // C2 \n \t const \t /* C3 */ // C4 \n',
      );
      expect(result, isA<Success>());
      final Token(:String value) = result.value;
      expect(value, 'const');
    });

    // Negative Test Cases

    test(
      'should fail to parse a keyword with extra characters immediately after',
      () {
        final result = parser.parse('constabc');
        expect(result, isA<Failure>());
        expect(result.message, 'end of input expected');
      },
    );

    test('should fail to parse an empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, '"const" expected');
    });

    test('should fail to parse only whitespace', () {
      final result = parser.parse('   \n\t   ');
      expect(result, isA<Failure>());
      expect(result.message, '"const" expected');
    });

    test('should fail to parse only comments', () {
      final result = parser.parse('/* comment */ // another');
      expect(result, isA<Failure>());
      expect(result.message, '"const" expected');
    });

    test('should fail to parse if the actual keyword is missing', () {
      final result = parser.parse('   /* comment */   ');
      expect(result, isA<Failure>());
      expect(result.message, '"const" expected');
    });
  });
}
