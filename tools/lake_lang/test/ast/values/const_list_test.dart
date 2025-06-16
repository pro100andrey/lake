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
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span, hasSpan(31, 33));
      expect(constList.elements, isEmpty);
    });

    test('should parse constant list with integer elements', () {
      const source = '[1, 2, 3]';
      final doc = parseAstFromString(
        'struct S { list<i32> numbers = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span, hasSpan(31, 40));
      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;

      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span, hasSpan(32, 33));

      final e2 = constList.elements[1] as IntConstantNode;
      expect(e2.rawValue, '2');
      expect(e2.value, 2);
      expect(e2.span, hasSpan(35, 36));

      final e3 = constList.elements[2] as IntConstantNode;
      expect(e3.rawValue, '3');
      expect(e3.value, 3);
      expect(e3.span, hasSpan(38, 39));
    });

    test('should parse constant list with string elements', () {
      const source = '["a", "b", "c"]';
      final doc = parseAstFromString(
        'struct S { list<string> letters = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span, hasSpan(34, 49));

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as LiteralNode;
      expect(e1.rawValue, '"a"');
      expect(e1.value, 'a');
      expect(e1.span, hasSpan(35, 38));

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.rawValue, '"b"');
      expect(e2.value, 'b');
      expect(e2.span, hasSpan(40, 43));

      final e3 = constList.elements[2] as LiteralNode;
      expect(e3.rawValue, '"c"');
      expect(e3.value, 'c');
      expect(e3.span, hasSpan(45, 48));
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

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;
      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span, hasSpan(30, 31));

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.rawValue, '"two"');
      expect(e2.value, 'two');
      expect(e2.span, hasSpan(33, 38));

      final e3 = constList.elements[2] as BoolConstantNode;
      expect(e3.rawValue, 'true');
      expect(e3.value, true);
      expect(e3.span, hasSpan(40, 44));
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

      expect(constList.elements, hasLength(2));

      final e1 = constList.elements[0] as ConstListNode;
      expect(e1.elements, hasLength(2));
      expect(e1.span, hasSpan(37, 43));

      final e11 = e1.elements[0] as IntConstantNode;
      expect(e11.rawValue, '1');
      expect(e11.value, 1);
      expect(e11.span, hasSpan(38, 39));

      final e12 = e1.elements[1] as IntConstantNode;
      expect(e12.rawValue, '2');
      expect(e12.value, 2);
      expect(e12.span, hasSpan(41, 42));

      final e2 = constList.elements[1] as ConstListNode;
      expect(e2.elements, hasLength(2));
      expect(e2.span, hasSpan(45, 51));

      final e21 = e2.elements[0] as IntConstantNode;
      expect(e21.rawValue, '3');
      expect(e21.span, hasSpan(46, 47));

      final e22 = e2.elements[1] as IntConstantNode;
      expect(e22.rawValue, '4');
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

      expect(constList.elements, hasLength(2));
      final e1 = constList.elements[0] as ConstMapNode;
      expect(e1.span, hasSpan(42, 52));

      expect(e1.entries, hasLength(1));
      final entry1 = e1.entries[0];
      expect((entry1.key as LiteralNode).rawValue, '"key"');
      expect((entry1.key as LiteralNode).value, 'key');
      expect(entry1.key.span, hasSpan(43, 48));

      expect((entry1.value as IntConstantNode).rawValue, '1');
      expect((entry1.value as IntConstantNode).value, 1);
      expect(entry1.value.span, hasSpan(50, 51));

      final e2 = constList.elements[1] as ConstMapNode;
      expect(e2.span, hasSpan(54, 64));

      expect(e2.entries, hasLength(1));
      final entry2 = e2.entries[0];
      expect((entry2.key as LiteralNode).rawValue, '"key"');
      expect((entry2.key as LiteralNode).value, 'key');
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

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

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

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1.defaultValue, isNot(equals(field2.defaultValue)));
    });
  });
}
