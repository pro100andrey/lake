import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('VisibleWhitespace Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.visibleWhitespace().plus().end());

    // Positive cases
    
    test('should parse a single space', () {
      final result = parser.parse(' ');
      expect(result, isA<Success>());
    });

    test('should parse a single tab', () {
      final result = parser.parse('\t');
      expect(result, isA<Success>());
    });

    test('should parse a single newline', () {
      final result = parser.parse('\n');
      expect(result, isA<Success>());
    });

    test('should parse a single carriage return', () {
      final result = parser.parse('\r');
      expect(result, isA<Success>());
    });

    test('should parse multiple spaces and tabs', () {
      final result = parser.parse(' \t\t  ');
      expect(result, isA<Success>());
    });

    test('should parse mixed whitespace', () {
      final result = parser.parse(' \t\n\r');
      expect(result, isA<Success>());
    });

    test('should parse long sequence of whitespace', () {
      final result = parser.parse(' \t\n\r  \t\t\n\n\r\r');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse non-whitespace character', () {
      final result = parser.parse('a');
      expect(result, isA<Failure>());
      expect(result.message, 'whitespace expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, 'whitespace expected');
    });

    test(
      'should fail to parse only non-visible whitespace (zero-width space)',
      () {
        final result = parser.parse('\u200B');
        expect(result, isA<Failure>());
        expect(result.message, 'whitespace expected');
      },
    );

    test('should fail to parse whitespace mixed with non-whitespace', () {
      final result = parser.parse(' \t\nx');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
