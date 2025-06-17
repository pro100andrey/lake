import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('IntLiteral AST', () {
    test('should parse a positive integer', () {
      const source = '123';
      final doc = parseAstFromString('struct S { i32 num = $source; }');
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final intConst = field.defaultValue!.cast<IntLiteralNode>();
      expect(intConst.rawValue, '123');
      expect(intConst.value, 123);
      expect(intConst.span, hasSpan(21, 24));
    });

    test('should parse a negative integer', () {
      const source = '-456';
      final doc = parseAstFromString('struct S { i32 negNum = $source; }');
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final intConst = field.defaultValue!.cast<IntLiteralNode>();
      expect(intConst.rawValue, '-456');
      expect(intConst.value, -456);
      expect(intConst.span, hasSpan(24, 28));
    });

    test('should parse zero', () {
      const source = '0';
      final doc = parseAstFromString('struct S { i32 zero = $source; }');
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final intConst = field.defaultValue!.cast<IntLiteralNode>();
      expect(intConst.rawValue, '0');
      expect(intConst.value, 0);
      expect(intConst.span, hasSpan(22, 23));
    });

    test('should parse a large integer', () {
      const source = '9876543210';
      final doc = parseAstFromString('struct S { i64 bigNum = $source; }');
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final intConst = field.defaultValue!.cast<IntLiteralNode>();
      expect(intConst.rawValue, '9876543210');
      expect(intConst.value, 9876543210);
      expect(intConst.span, hasSpan(24, 34));
    });
  });

  group('IntLiteral AST (equality)', () {
    test('should be equal for same value', () {
      const source = '123';
      const source2 = '123';
      final doc1 = parseAstFromString('struct S { i32 num = $source; }');
      final doc2 = parseAstFromString('struct S { i32 num = $source2; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(struct1, equals(struct2));

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1, equals(field2));
      expect(field1.defaultValue, equals(field2.defaultValue));
    });

    test('should not be equal for different values', () {
      const source1 = '123';
      const source2 = '456';
      final doc1 = parseAstFromString('struct S { i32 num = $source1; }');
      final doc2 = parseAstFromString('struct S { i32 num = $source2; }');

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(struct1, isNot(equals(struct2)));

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1, isNot(equals(field2)));
      expect(field1.defaultValue, isNot(equals(field2.defaultValue)));
    });
  });
}
