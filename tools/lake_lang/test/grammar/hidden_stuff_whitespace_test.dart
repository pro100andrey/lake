import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('HiddenStuffWhitespace Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [35] HiddenStuffWhitespace ::= VisibleWhitespace | Comment
    final parser = resolve(grammar.hiddenStuffWhitespace().plus().end());

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

    test('should parse a single-line comment', () {
      final result = parser.parse('// comment\n');
      expect(result, isA<Success>());
    });

    test('should parse a single-line comment without newline', () {
      final result = parser.parse('// comment');
      expect(result, isA<Success>());
    });

    test('should parse a multi-line comment', () {
      final result = parser.parse('/* multi\nline\ncomment */');
      expect(result, isA<Success>());
    });

    test('should parse an empty multi-line comment', () {
      final result = parser.parse('/**/');
      expect(result, isA<Success>());
    });

    test('should parse whitespace and comment mixed', () {
      final result = parser.parse(' \t// comment\n');
      expect(result, isA<Success>());
    });

    test('should parse multi-line comment with leading whitespace', () {
      final result = parser.parse('   /* comment */');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse non-whitespace character', () {
      final result = parser.parse('a');
      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });

    test(
      'should fail to parse only non-visible whitespace (zero-width space)',
      () {
        final result = parser.parse('\u200B');
        expect(result, isA<Failure>());
        expect(result.message, '"/*" expected');
      },
    );

    test('should fail to parse unterminated multi-line comment', () {
      final result = parser.parse('/* unterminated');
      expect(result, isA<Failure>());
      expect(result.message, '"*/" expected');
    });

    test('should fail to parse malformed single-line comment', () {
      final result = parser.parse('/ not a comment');
      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });
  });
}
