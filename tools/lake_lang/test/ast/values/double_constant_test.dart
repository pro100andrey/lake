import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('DoubleConstant AST', () {
    test('should parse positive double with decimal part', () {
      const source = '3.14';
      final doc = parseAstFromString('struct S { double pi = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final doubleConst = field.defaultValue! as DoubleConstantNode;
      expect(doubleConst, isA<DoubleConstantNode>());
      expect(doubleConst.rawValue, '3.14');
      expect(doubleConst.value, 3.14);
      expect(doubleConst.span, hasSpan(23, 27));
    });

    test('should parse negative double with decimal part', () {
      const source = '-1.234';
      final doc = parseAstFromString('struct S { double val = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final doubleConst = field.defaultValue! as DoubleConstantNode;
      expect(doubleConst.rawValue, '-1.234');
      expect(doubleConst.value, -1.234);
      expect(doubleConst.span, hasSpan(24, 30));
    });

    test('should parse double with exponential notation (lowercase e)', () {
      const source = '6.022e23';
      final doc = parseAstFromString('struct S { double avogadro = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final doubleConst = field.defaultValue! as DoubleConstantNode;
      expect(doubleConst.rawValue, '6.022e23');
      expect(doubleConst.value, 6.022e23);
      expect(doubleConst.span, hasSpan(29, 37));
    });

    test(
      'should parse double with exponential notation (uppercase E)',
      () {
        const source = '1.0E+5';
        final doc = parseAstFromString(
          'struct S { double largeNum = $source; }',
        );
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;

        final doubleConst = field.defaultValue! as DoubleConstantNode;
        expect(doubleConst.rawValue, '1.0E+5');
        expect(doubleConst.value, 100000.0);
        expect(doubleConst.span, hasSpan(29, 35));
      },
    );

    test(
      'should parse double with exponential notation (negative exponent)',
      () {
        const source = '1.23e-4';
        final doc = parseAstFromString(
          'struct S { double smallNum = $source; }',
        );
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;

        final doubleConst = field.defaultValue! as DoubleConstantNode;
        expect(doubleConst.rawValue, '1.23e-4');
        expect(doubleConst.span, hasSpan(29, 36));
      },
    );

    test(
      'should parse double representing an integer (with decimal point)',
      () {
        const source = '5.0';
        final doc = parseAstFromString(
          'struct S { double intAsDouble = $source; }',
        );
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;

        final doubleConst = field.defaultValue! as DoubleConstantNode;
        expect(doubleConst.rawValue, '5.0');
        expect(doubleConst.span, hasSpan(32, 35));
      },
    );

    test(
      'should parse double starting with a decimal point (implicit zero)',
      () {
        const source = '.25';
        final doc = parseAstFromString(
          'struct S { double quarter = $source; }',
        );
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;

        final doubleConst = field.defaultValue! as DoubleConstantNode;
        expect(doubleConst.rawValue, '.25');
        expect(doubleConst.span, hasSpan(28, 31));
      },
    );
  });

  group('DoubleConstant AST (equality)', () {
    test('should be equal for same value', () {
      const source = '3.14';
      final doc1 = parseAstFromString('struct S { double pi = $source; }');
      final doc2 = parseAstFromString('struct S { double pi = $source; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1, equals(field2));
      expect(field1.defaultValue, equals(field2.defaultValue));
    });

    test('should not be equal for different values', () {
      const source1 = '3.14';
      const source2 = '2.71';
      final doc1 = parseAstFromString('struct S { double pi = $source1; }');
      final doc2 = parseAstFromString('struct S { double pi = $source2; }');

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, isNot(equals(struct2)));

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1, isNot(equals(field2)));
      expect(field1.defaultValue, isNot(equals(field2.defaultValue)));
    });
  });
}
