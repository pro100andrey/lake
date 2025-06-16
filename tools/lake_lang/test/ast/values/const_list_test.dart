import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

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

      expect(constList.span.start, 31);
      expect(constList.span.end, 33);
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

      expect(constList.span.start, 31);
      expect(constList.span.end, 40);
      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;

      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span.start, 32);
      expect(e1.span.end, 33);

      final e2 = constList.elements[1] as IntConstantNode;
      expect(e2.rawValue, '2');
      expect(e2.value, 2);
      expect(e2.span.start, 35);
      expect(e2.span.end, 36);

      final e3 = constList.elements[2] as IntConstantNode;
      expect(e3.rawValue, '3');
      expect(e3.value, 3);
      expect(e3.span.start, 38);
      expect(e3.span.end, 39);
    });

    test('should parse constant list with string elements', () {
      const source = '["a", "b", "c"]';
      final doc = parseAstFromString(
        'struct S { list<string> letters = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.start, 34);
      expect(constList.span.end, 49);

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as LiteralNode;
      expect(e1.rawValue, '"a"');
      expect(e1.value, 'a');
      expect(e1.span.start, 35);
      expect(e1.span.end, 38);

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.rawValue, '"b"');
      expect(e2.value, 'b');
      expect(e2.span.start, 40);
      expect(e2.span.end, 43);

      final e3 = constList.elements[2] as LiteralNode;
      expect(e3.rawValue, '"c"');
      expect(e3.value, 'c');
      expect(e3.span.start, 45);
      expect(e3.span.end, 48);
    });

    test('should parse constant list with mixed primitive elements', () {
      const source = '[1, "two", true]';
      final doc = parseAstFromString(
        'struct S { list<any> mixed = $source; }',
      ); // Assuming 'any' or similar for mixed types
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.start, 29);
      expect(constList.span.end, 45);

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;
      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span.start, 30);
      expect(e1.span.end, 31);

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.rawValue, '"two"');
      expect(e2.value, 'two');
      expect(e2.span.start, 33);
      expect(e2.span.end, 38);

      final e3 = constList.elements[2] as BoolConstantNode;
      expect(e3.rawValue, 'true');
      expect(e3.value, true);
      expect(e3.span.start, 40);
      expect(e3.span.end, 44);
    });

    test('should parse constant list with nested constant list', () {
      const source = '[[1, 2], [3, 4]]';
      final doc = parseAstFromString(
        'struct S { list<list<i32>> nested = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.start, 36);
      expect(constList.span.end, 52);

      expect(constList.elements, hasLength(2));

      final e1 = constList.elements[0] as ConstListNode;
      expect(e1.elements, hasLength(2));
      expect(e1.span.start, 37);
      expect(e1.span.end, 43);

      final e11 = e1.elements[0] as IntConstantNode;
      expect(e11.rawValue, '1');
      expect(e11.value, 1);
      expect(e11.span.start, 38);
      expect(e11.span.end, 39);

      final e12 = e1.elements[1] as IntConstantNode;
      expect(e12.rawValue, '2');
      expect(e12.value, 2);
      expect(e12.span.start, 41);
      expect(e12.span.end, 42);

      final e2 = constList.elements[1] as ConstListNode;
      expect(e2.elements, hasLength(2));
      expect(e2.span.start, 45);
      expect(e2.span.end, 51);

      final e21 = e2.elements[0] as IntConstantNode;
      expect(e21.rawValue, '3');
      expect(e21.span.start, 46);
      expect(e21.span.end, 47);

      final e22 = e2.elements[1] as IntConstantNode;
      expect(e22.rawValue, '4');
      expect(e22.span.start, 49);
      expect(e22.span.end, 50);
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
      expect(constList.span.start, 41);
      expect(constList.span.end, 65);

      expect(constList.elements, hasLength(2));
      final e1 = constList.elements[0] as ConstMapNode;
      expect(e1.span.start, 42);
      expect(e1.span.end, 52);

      expect(e1.entries, hasLength(1));
      final entry1 = e1.entries[0];
      expect((entry1.key as LiteralNode).rawValue, '"key"');
      expect((entry1.key as LiteralNode).value, 'key');
      expect(entry1.key.span.start, 43);
      expect(entry1.key.span.end, 48);

      expect((entry1.value as IntConstantNode).rawValue, '1');
      expect((entry1.value as IntConstantNode).value, 1);
      expect(entry1.value.span.start, 50);
      expect(entry1.value.span.end, 51);

      final e2 = constList.elements[1] as ConstMapNode;
      expect(e2.span.start, 54);
      expect(e2.span.end, 64);

      expect(e2.entries, hasLength(1));
      final entry2 = e2.entries[0];
      expect((entry2.key as LiteralNode).rawValue, '"key"');
      expect((entry2.key as LiteralNode).value, 'key');
      expect(entry2.key.span.start, 55);
      expect(entry2.key.span.end, 60);
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
