import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.intConstant().end());

  group('IntConstant grammar (positive):', () {
    test('should parse a simple positive integer', () {
      final result = parser.parse('123');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '123');
      expect(int.parse(value), 123);
    });

    test('should parse a simple negative integer', () {
      final result = parser.parse('-456');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '-456');
      expect(int.parse(value), -456);
    });

    test('should parse a positive integer with explicit plus sign', () {
      final result = parser.parse('+789');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '+789');
      expect(int.parse(value), 789);
    });

    test('should parse a long integer', () {
      final result = parser.parse('9223372036854775807');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '9223372036854775807');
      expect(int.parse(value), 9223372036854775807);
    });

    test('should parse an integer with leading/trailing whitespace', () {
      final result = parser.parse('   12345   ');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '12345');
      expect(int.parse(value), 12345);
    });

    test('should parse zero', () {
      final result = parser.parse('0');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '0');
      expect(int.parse(value), 0);
    });

    test('should parse positive zero', () {
      final result = parser.parse('+0');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '+0');
      expect(int.parse(value), 0);
    });

    test('should parse negative zero', () {
      final result = parser.parse('-0');
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, '-0');
      expect(int.parse(value), 0);
    });

    test('should parse a very large integer', () {
      final veryLargeValue = '1${'0' * 100}';
      final bigInt = BigInt.parse(veryLargeValue);
      final result = parser.parse(veryLargeValue);
      final Token(:String value) = result.value;

      expect(result, isA<Success>());
      expect(value, veryLargeValue);
      expect(BigInt.parse(value), bigInt);
    });
  });

  group('IntConstant grammar (negative):', () {
    test('should fail to parse a non-numeric string', () {
      final result = parser.parse('abc');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse a number with a decimal point', () {
      final result = parser.parse('123.45');
      expect(result, isA<Failure>());
      expect(result.message, 'invalid integer format');
    });

    test('should fail to parse a number with an exponent', () {
      final result = parser.parse('1e10');
      expect(result, isA<Failure>());
      expect(result.message, 'invalid integer format');
    });

    test('should fail to parse an empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse only a plus sign', () {
      final result = parser.parse('+');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse only a minus sign', () {
      final result = parser.parse('-');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse a number starting with a non-digit character '
        '(after sign)', () {
      final result = parser.parse('-a123');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse a number with space after sign', () {
      final result = parser.parse('+ 123');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');
    });

    test('should fail to parse a number with multiple signs', () {
      final result = parser.parse('++123');
      expect(result, isA<Failure>());
      expect(result.message, 'digit expected');

      final result2 = parser.parse('--456');
      expect(result2, isA<Failure>());
      expect(result2.message, 'digit expected');

      final result3 = parser.parse('+-789');
      expect(result3, isA<Failure>());
      expect(result3.message, 'digit expected');

      final result4 = parser.parse('-+789');
      expect(result4, isA<Failure>());
      expect(result4.message, 'digit expected');
    });

    test('should fail to parse a number with letters or underscores', () {
      final result = parser.parse('12a3');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');

      final result2 = parser.parse('45_67');
      expect(result2, isA<Failure>());
      expect(result2.message, 'end of input expected');
    });
  });
}
