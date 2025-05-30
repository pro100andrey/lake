import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleConstant Rule:', () {
    final grammar = LakeGrammarDefinition();
    // DoubleConstant ::=
    // ('+' | '-')? Digit* ('.' Digit+ ( ('E' | 'e') IntConstant )? |
    // ('E' | 'e') IntConstant )
    final parser = resolve(grammar.doubleConstant().end());

    // Positive Test Cases

    test('should parse a simple decimal number', () {
      final result = parser.parse('123.45');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '123.45');
    });

    test('should parse a decimal number with explicit plus sign', () {
      final result = parser.parse('+6.78');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '+6.78');
    });

    test('should parse a decimal number with explicit minus sign', () {
      final result = parser.parse('-9.01');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '-9.01');
    });

    test('should parse a decimal number starting with a dot', () {
      final result = parser.parse('.123');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '.123');
    });

    test('should parse zero decimal', () {
      final result = parser.parse('0.0');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '0.0');
    });
  });
}
