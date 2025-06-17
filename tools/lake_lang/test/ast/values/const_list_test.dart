import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('ConstList AST', () {
    test('should parse empty constant list', () {
      const source = '[]';
      final doc = parseAstFromString(
        'struct S { list<i32> numbers = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constList = field.defaultValue!.cast<ConstListNode>();

      expect(constList.span, hasSpan(31, 33));
      expect(constList.elements, isEmpty);
    });

    test('should parse constant list with integer elements', () {
      const source = '[1, 2, 3]';
      final doc = parseAstFromString(
        'struct S { list<i32> numbers = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constList = field.defaultValue!.cast<ConstListNode>();

      expect(constList.span, hasSpan(31, 40));

      final [
        IntConstantNode e0,
        IntConstantNode e1,
        IntConstantNode e2,
      ] = constList.elements
          .cast<IntConstantNode>();

      expect(e0.rawValue, '1');
      expect(e0.value, 1);
      expect(e0.span, hasSpan(32, 33));

      expect(e1.rawValue, '2');
      expect(e1.value, 2);
      expect(e1.span, hasSpan(35, 36));

      expect(e2.rawValue, '3');
      expect(e2.value, 3);
      expect(e2.span, hasSpan(38, 39));
    });

    test('should parse constant list with string elements', () {
      const source = '["a", "b", "c"]';
      final doc = parseAstFromString(
        'struct S { list<string> letters = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constList = field.defaultValue!.cast<ConstListNode>();

      expect(constList.span, hasSpan(34, 49));

      final [
        LiteralNode e0,
        LiteralNode e1,
        LiteralNode e2,
      ] = constList.elements
          .cast<LiteralNode>();

      expect(e0.rawValue, '"a"');
      expect(e0.value, 'a');
      expect(e0.span, hasSpan(35, 38));

      expect(e1.rawValue, '"b"');
      expect(e1.value, 'b');
      expect(e1.span, hasSpan(40, 43));

      expect(e2.rawValue, '"c"');
      expect(e2.value, 'c');
      expect(e2.span, hasSpan(45, 48));
    });

    test('should parse constant list with mixed primitive elements', () {
      const source = '[1, "two", true]';
      final doc = parseAstFromString(
        'struct S { list<any> mixed = $source; }',
      ); // Assuming 'any' or similar for mixed types
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ConstListNode;
      expect(constList.span, hasSpan(29, 45));

      final [
        IntConstantNode e0,
        LiteralNode e1,
        BoolConstantNode e2,
      ] = constList.elements
          .cast<dynamic>();

      expect(e0.rawValue, '1');
      expect(e0.value, 1);
      expect(e0.span, hasSpan(30, 31));

      expect(e1.rawValue, '"two"');
      expect(e1.value, 'two');
      expect(e1.span, hasSpan(33, 38));

      expect(e2.rawValue, 'true');
      expect(e2.value, true);
      expect(e2.span, hasSpan(40, 44));
    });

    test('should parse constant list with nested constant list', () {
      const source = '[[1, 2], [3, 4]]';
      final doc = parseAstFromString(
        'struct S { list<list<i32>> nested = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ConstListNode;
      expect(constList.span, hasSpan(36, 52));

      final [
        ConstListNode e0,
        ConstListNode e1,
      ] = constList.elements
          .cast<ConstListNode>();

      expect(e0.elements, hasLength(2));
      expect(e0.span, hasSpan(37, 43));

      final [
        IntConstantNode e01,
        IntConstantNode e02,
      ] = e0.elements
          .cast<IntConstantNode>();

      expect(e01.rawValue, '1');
      expect(e01.value, 1);
      expect(e01.span, hasSpan(38, 39));

      expect(e02.rawValue, '2');
      expect(e02.value, 2);
      expect(e02.span, hasSpan(41, 42));

      final [
        IntConstantNode e21,
        IntConstantNode e22,
      ] = e1.elements
          .cast<IntConstantNode>();

      expect(e21.rawValue, '3');
      expect(e21.value, 3);
      expect(e21.span, hasSpan(46, 47));

      expect(e22.rawValue, '4');
      expect(e22.value, 4);
      expect(e22.span, hasSpan(49, 50));
    });

    test('should parse constant list with nested constant map', () {
      const source = '[{"key": 1}, {"key": 2}]';
      final doc = parseAstFromString(
        'struct S { '
        'list<map<string, i32>> maps = $source; '
        '}',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ConstListNode;
      expect(constList.span, hasSpan(41, 65));

      final [
        ConstMapNode e1,
        ConstMapNode e2,
      ] = constList.elements
          .cast<ConstMapNode>();

      expect(e1.span, hasSpan(42, 52));

      final [entry1] = e1.entries
          .cast<({LiteralNode key, IntConstantNode value})>();

      expect(entry1.key.rawValue, '"key"');
      expect(entry1.key.value, 'key');
      expect(entry1.key.span, hasSpan(43, 48));

      expect(entry1.value.rawValue, '1');
      expect(entry1.value.value, 1);
      expect(entry1.value.span, hasSpan(50, 51));

      expect(e2.span, hasSpan(54, 64));

      final [entry2] = e2.entries
          .cast<({LiteralNode key, IntConstantNode value})>();

      expect(e2.entries, hasLength(1));

      expect(entry2.key.rawValue, '"key"');
      expect(entry2.key.value, 'key');
      expect(entry2.key.span, hasSpan(55, 60));
    });
  });

  group('ConstList AST (equality)', () {
    test('should be equal for same constant list', () {
      const source = '[1, 2, 3]';
      const source1 = '[1, 2, 3]';
      final doc1 = parseAstFromString(
        'struct S { list<i32> numbers = $source; }',
      );
      final doc2 = parseAstFromString(
        'struct S { list<i32> numbers = $source1; }',
      );

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1.defaultValue, equals(field2.defaultValue));
    });

    test('should not be equal for different constant lists', () {
      const source1 = '[1, 2, 3]';
      const source2 = '[4, 5, 6]';
      final doc1 = parseAstFromString(
        'struct S { list<i32> numbers = $source1; }',
      );
      final doc2 = parseAstFromString(
        'struct S { list<i32> numbers = $source2; }',
      );

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1.defaultValue, isNot(equals(field2.defaultValue)));
    });
  });
}
