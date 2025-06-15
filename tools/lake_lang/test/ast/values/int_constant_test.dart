import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('IntConstant AST', () {
    test('should parse a positive integer', () {
      const source = '123';
      final doc = parseAndGetAst('struct S { i32 num = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final intConst = field.defaultValue! as IntConstantNode;

      expect(intConst, isA<IntConstantNode>());
      expect(intConst.rawValue, '123');
      expect(intConst.value, 123);
      expect(intConst.span.text, source);
      expect(intConst.span.start.offset, 21);
      expect(intConst.span.end.offset, 24);
    });

    test('should parse a negative integer', () {
      const source = '-456';
      final doc = parseAndGetAst('struct S { i32 negNum = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final intConst = field.defaultValue! as IntConstantNode;

      expect(intConst.rawValue, '-456');
      expect(intConst.value, -456);
      expect(intConst.span.text, source);
      expect(intConst.span.start.offset, 24);
      expect(intConst.span.end.offset, 28);
    });

    test('should parse zero', () {
      const source = '0';
      final doc = parseAndGetAst('struct S { i32 zero = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final intConst = field.defaultValue! as IntConstantNode;

      expect(intConst.rawValue, '0');
      expect(intConst.value, 0);
      expect(intConst.span.text, source);
      expect(intConst.span.start.offset, 22);
      expect(intConst.span.end.offset, 23);
    });

    test('should parse a large integer', () {
      const source = '9876543210';
      final doc = parseAndGetAst('struct S { i64 bigNum = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final intConst = field.defaultValue! as IntConstantNode;

      expect(intConst.rawValue, '9876543210');
      expect(intConst.value, 9876543210);
      expect(intConst.span.text, source);
      expect(intConst.span.start.offset, 24);
      expect(intConst.span.end.offset, 34);
    });
  });

  group('IntConstant AST (equality)', () {
    test('should be equal for same value', () {
      const source = '123';
      const source2 = '123';
      final doc1 = parseAndGetAst('struct S { i32 num = $source; }');
      final doc2 = parseAndGetAst('struct S { i32 num = $source2; }');

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
      const source1 = '123';
      const source2 = '456';
      final doc1 = parseAndGetAst('struct S { i32 num = $source1; }');
      final doc2 = parseAndGetAst('struct S { i32 num = $source2; }');

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
