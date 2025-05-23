// ignore_for_file: avoid_print

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.constDefinition()).end();

  group('Lake Grammar - ConstDefinition:', () {
    group('Valid Cases:', () {
      test('simple string const - succeeds', () {
        const input = 'const string NAME = "John Doe"';
        final result = parser.parse(input);
        printParseResult(result);
        expect(result, isA<Success>());
        expect(result.value, '');
      });

      test('integer const with semicolon - succeeds', () {
        const input = 'const i32 MAX_USERS = 100';
        final result = parser.parse(input);
        printParseResult(result);
        expect(result, isA<Success>());
      });
    });

    group('Invalid Cases:', () {});
  });
}
