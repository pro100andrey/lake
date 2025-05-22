// ignore_for_file: lines_longer_than_80_chars

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Lake grammar', () {
    final grammar = LakeGrammarDefinition();

    test('Import - single quote success', () {
      const input = "import 'base.lake'";
      final result = resolve(grammar.import()).parse(input);

      expect(result, isA<Success>());
    });

    test('Import - double quote success', () {
      const input = 'import "base.lake"';
      final result = resolve(grammar.import()).parse(input);

      expect(result, isA<Success>());
    });

    test('Import - invalid keyword', () {
      const input = 'impor "base.lake"';
      final result = resolve(grammar.import()).parse(input);

      expect(result, isA<Failure>());
      expect(result.message, equals('"import" expected'));
    });

    test('Import - missing literal', () {
      const input = 'import';
      final result = resolve(grammar.import()).parse(input);

      expect(result, isA<Failure>());
      expect(result.message, equals('" or \' expected'));
    });
  });
}
