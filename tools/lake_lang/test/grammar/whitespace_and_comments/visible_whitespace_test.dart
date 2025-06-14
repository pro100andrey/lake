import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.visibleWhitespace().plus().end());

  group('VisibleWhitespace grammar (positive):', () {
    test('should parse a single space', () {
      final result = parser.parse(' ');
      final [String value] = result.value;

      expect(result, isA<Success>());
      expect(value, ' ');
    });

    test('should parse a single tab', () {
      final result = parser.parse('\t');
      final [String value] = result.value;

      expect(result, isA<Success>());
      expect(value, '\t');
    });

    test('should parse a single newline', () {
      final result = parser.parse('\n');
      final [String value] = result.value;

      expect(result, isA<Success>());
      expect(value, '\n');
    });

    test('should parse a single carriage return', () {
      final result = parser.parse('\r');
      final [String value] = result.value;

      expect(result, isA<Success>());
      expect(value, '\r');
    });

    test('should parse multiple spaces and tabs', () {
      final result = parser.parse(' \t\t  ');
      final [String v1, String v2, String v3, String v4, String v5] =
          result.value;

      expect(result, isA<Success>());
      expect(v1, ' ');
      expect(v2, '\t');
      expect(v3, '\t');
      expect(v4, ' ');
      expect(v5, ' ');
    });

    test('should parse mixed whitespace', () {
      final result = parser.parse(' \t\n\r');
      final [String v1, String v2, String v3, String v4] = result.value;

      expect(result, isA<Success>());
      expect(v1, ' ');
      expect(v2, '\t');
      expect(v3, '\n');
      expect(v4, '\r');
    });

    test('should parse long sequence of whitespace', () {
      final result = parser.parse(' \t\n\r  \t\t\n\n\r\r');
      final [
        String v1,
        String v2,
        String v3,
        String v4,
        String v5,
        String v6,
        String v7,
        String v8,
        String v9,
        String v10,
        String v11,
        String v12,
      ] = result.value;

      expect(result, isA<Success>());
      expect(v1, ' ');
      expect(v2, '\t');
      expect(v3, '\n');
      expect(v4, '\r');
      expect(v5, ' ');
      expect(v6, ' ');
      expect(v7, '\t');
      expect(v8, '\t');
      expect(v9, '\n');
      expect(v10, '\n');
      expect(v11, '\r');
      expect(v12, '\r');
    });
  });

  group('VisibleWhitespace grammar (negative):', () {
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
