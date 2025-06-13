import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('DoubleConstant AST', () {
    test('should parse positive double with decimal part', () {
      const source = '3.14';
      final doc = parseAst('struct S { double pi = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final doubleConst = field.defaultValue! as DoubleConstantNode;

      expect(doubleConst, isA<DoubleConstantNode>());
      expect(doubleConst.rawValue, '3.14');
      expect(doubleConst.value, 3.14);
      expect(doubleConst.span.text, source);
      expect(doubleConst.span.start.offset, 23);
      expect(doubleConst.span.end.offset, 27);
    });

    test('should parse negative double with decimal part', () {
      const source = '-1.234';
      final doc = parseAst('struct S { double val = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final doubleConst = field.defaultValue! as DoubleConstantNode;

      expect(doubleConst.rawValue, '-1.234');
      expect(doubleConst.value, -1.234);
      expect(doubleConst.span.text, source);
      expect(doubleConst.span.start.offset, 24);
      expect(doubleConst.span.end.offset, 30);
    });

    test('should parse double with exponential notation (lowercase e)', () {
      const source = '6.022e23';
      final doc = parseAst('struct S { double avogadro = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final doubleConst = field.defaultValue! as DoubleConstantNode;

      expect(doubleConst.rawValue, '6.022e23');
      expect(doubleConst.span.text, source);
      expect(doubleConst.span.start.offset, 29);
      expect(doubleConst.span.end.offset, 37);
    });

    test(
      'should parse double with exponential notation (uppercase E)',
      () {
        const source = '1.0E+5';
        final doc = parseAst('struct S { double largeNum = $source; }');
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;
        final doubleConst = field.defaultValue! as DoubleConstantNode;

        expect(doubleConst.rawValue, '1.0E+5');
        expect(doubleConst.value, 100000.0);
        expect(doubleConst.span.text, source);
        expect(doubleConst.span.start.offset, 29);
        expect(doubleConst.span.end.offset, 35);
      },
    );

    test(
      'should parse double with exponential notation (negative exponent)',
      () {
        const source = '1.23e-4';
        final doc = parseAst('struct S { double smallNum = $source; }');
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;
        final doubleConst = field.defaultValue! as DoubleConstantNode;

        expect(doubleConst.rawValue, '1.23e-4');
        expect(doubleConst.span.text, source);
        expect(doubleConst.span.start.offset, 29);
        expect(doubleConst.span.end.offset, 36);
      },
    );

    test(
      'should parse double representing an integer (with decimal point)',
      () {
        const source = '5.0';
        final doc = parseAst('struct S { double intAsDouble = $source; }');
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;
        final doubleConst = field.defaultValue! as DoubleConstantNode;

        expect(doubleConst.rawValue, '5.0');
        expect(doubleConst.span.text, source);
        expect(doubleConst.span.start.offset, 32);
        expect(doubleConst.span.end.offset, 35);
      },
    );

    test(
      'should parse double starting with a decimal point (implicit zero)',
      () {
        const source = '.25';
        final doc = parseAst('struct S { double quarter = $source; }');
        final struct = doc.definitions.first as StructDefinitionNode;
        final field = struct.fields.first;
        final doubleConst = field.defaultValue! as DoubleConstantNode;

        expect(doubleConst.rawValue, '.25');
        expect(doubleConst.span.text, source);
        expect(doubleConst.span.start.offset, 28);
        expect(doubleConst.span.end.offset, 31);
      },
    );
  });
}
