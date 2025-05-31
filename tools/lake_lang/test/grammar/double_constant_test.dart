import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleConstant Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [29] DoubleConstant ::= ('+' | '-')?
    // ( Digit* '.' Digit+ ( ('E' | 'e') ('+' | '-')? Digit+ )? |
    // Digit+ ( ('E' | 'e') ('+' | '-')? Digit+ )? )
    final parser = resolve(grammar.doubleConstant().end());

    // Positive Test Cases

    test('should parse a simple decimal number', () {
      final result = parser.parse('123.45');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '123.45');
      expect(double.parse(value), 123.45);
    });

    test('should parse a decimal number with explicit plus sign', () {
      final result = parser.parse('+6.78');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '+6.78');
      expect(double.parse(value), 6.78);
    });

    test('should parse a decimal number with explicit minus sign', () {
      final result = parser.parse('-9.01');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '-9.01');
      expect(double.parse(value), -9.01);
    });

    test('should parse a decimal number starting with a dot', () {
      final result = parser.parse('.123');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '.123');
      expect(double.parse(value), 0.123);
    });

    test('should parse zero decimal', () {
      final result = parser.parse('0.0');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '0.0');
      expect(double.parse(value), 0.0);
    });

    test('should parse a decimal with exponent', () {
      final result = parser.parse('1.23e4');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '1.23e4');
      expect(double.parse(value), 1.23e4);
    });

    test('should parse a decimal with uppercase exponent', () {
      final result = parser.parse('5.67E8');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '5.67E8');
      expect(double.parse(value), 5.67e8);
    });

    test('should parse a decimal with positive exponent sign', () {
      final result = parser.parse('0.1e+3');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '0.1e+3');
      expect(double.parse(value), 0.1e3);
    });

    test('should parse a decimal with negative exponent sign', () {
      final result = parser.parse('0.1e-3');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '0.1e-3');
      expect(double.parse(value), 0.1e-3);
    });

    test('should parse a decimal with leading zeros', () {
      final result = parser.parse('000.1');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '000.1');
      expect(double.parse(value), 0.1);
    });

    test('should parse a decimal with sign and exponent', () {
      final result = parser.parse('-1.2e3');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '-1.2e3');
      expect(double.parse(value), -1.2e3);
    });

    test('should parse a decimal with only dot and exponent', () {
      final result = parser.parse('.1e2');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '.1e2');
      expect(double.parse(value), 0.1e2);
    });

    test('should parse a number with only exponent (no dot)', () {
      final result = parser.parse('123e4');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '123e4');
      expect(double.parse(value), 123e4);
    });

    test('should parse a number with sign and exponent (no dot)', () {
      final result = parser.parse('+5e6');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '+5e6');
      expect(double.parse(value), 5e6);
    });

    test('should parse a number with leading zeros and exponent', () {
      final result = parser.parse('000e2');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '000e2');
      expect(double.parse(value), 0.0);
    });

    test('should parse a very long double', () {
      final result = parser.parse('1234567890123456789.0123456789E+100');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '1234567890123456789.0123456789E+100');
      expect(double.parse(value), 1234567890123456789.0123456789e+100);
    });

    test('should parse a double with leading/trailing whitespace', () {
      final result = parser.parse('    -1.23e-4    ');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '-1.23e-4');
      expect(double.parse(value), -1.23e-4);
    });

    // Negative Test Cases

    test('should fail to parse a non-numeric string', () {
      final result = parser.parse('abc');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse only a dot', () {
      final result = parser.parse('.');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse only an exponent', () {
      final result = parser.parse('e10');

      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse double dot', () {
      final result = parser.parse('1..2');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse only sign', () {
      final result = parser.parse('+');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
      final result2 = parser.parse('-');
      expect(result2, isA<Failure>());
      expect(result2.message, 'digit expected');
    });

    test('should fail to parse sign and dot only', () {
      final result = parser.parse('-.');
      expect(result, isA<Failure>());
      final result2 = parser.parse('+.');
      expect(result2, isA<Failure>());
    });

    test(
      'should fail to parse a number ending with a dot (no digits after)',
      () {
        final result = parser.parse('123.');
        expect(result, isA<Failure>());
        expect(result.message, 'end of input expected');
      },
    );
    test('should fail to parse zero ending with a dot (no digits after)', () {
      final result = parser.parse('0.');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse sign and exponent only', () {
      final result = parser.parse('+e10');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');

      final result2 = parser.parse('-e10');
      expect(result2, isA<Failure>());
      expect(result2.message, 'digit expected');
    });

    test('should fail to parse number with letters after exponent', () {
      final result = parser.parse('1.2e3abc');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse number with underscore', () {
      final result = parser.parse('1_2.3');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
