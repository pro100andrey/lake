import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Comment Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.comment().end());

    // Positive cases

    test('should parse a single-line comment', () {
      final result = parser.parse('// this is a comment\n');
      expect(result, isA<Success>());
    });

    test('should parse a single-line comment without newline', () {
      final result = parser.parse('// end of file');
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

    test('should parse a multi-line comment with nested markers', () {
      final result = parser.parse('/* outer /* inner */ outer */');
      expect(result, isA<Success>());
    });

    // Negative cases
    
    test('should fail to parse if not a comment', () {
      final result = parser.parse('not a comment');
      expect(result, isA<Failure>());
      expect(result.message, '"/*" expected');
    });

    test('should fail to parse unterminated multi-line comment', () {
      final result = parser.parse('/* unterminated');
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
