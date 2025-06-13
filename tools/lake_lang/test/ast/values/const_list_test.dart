import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ConstList AST', () {
    test('should parse empty constant list', () {
      const source = '[]';
      final doc = parseAst('struct S { list<i32> numbers = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.text, source);
      expect(constList.span.start.offset, 31);
      expect(constList.span.end.offset, 33);
      expect(constList.elements, isEmpty);
    });

    test('should parse constant list with integer elements', () {
      const source = '[1, 2, 3]';
      final doc = parseAst('struct S { list<i32> numbers = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.text, source);
      expect(constList.span.start.offset, 31);
      expect(constList.span.end.offset, 40);
      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;

      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span.text, '1');
      expect(e1.span.start.offset, 32);
      expect(e1.span.end.offset, 33);

      final e2 = constList.elements[1] as IntConstantNode;
      expect(e2.rawValue, '2');
      expect(e2.value, 2);
      expect(e2.span.text, '2');
      expect(e2.span.start.offset, 35);
      expect(e2.span.end.offset, 36);

      final e3 = constList.elements[2] as IntConstantNode;
      expect(e3.rawValue, '3');
      expect(e3.value, 3);
      expect(e3.span.text, '3');
      expect(e3.span.start.offset, 38);
      expect(e3.span.end.offset, 39);
    });

    test('should parse constant list with string elements', () {
      const source = '["a", "b", "c"]';
      final doc = parseAst('struct S { list<string> letters = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.text, source);
      expect(constList.span.start.offset, 34);
      expect(constList.span.end.offset, 49);

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as LiteralNode;
      expect(e1.rawValue, '"a"');
      expect(e1.value, 'a');
      expect(e1.span.text, '"a"');
      expect(e1.span.start.offset, 35);
      expect(e1.span.end.offset, 38);

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.rawValue, '"b"');
      expect(e2.value, 'b');
      expect(e2.span.text, '"b"');
      expect(e2.span.start.offset, 40);
      expect(e2.span.end.offset, 43);

      final e3 = constList.elements[2] as LiteralNode;
      expect(e3.rawValue, '"c"');
      expect(e3.value, 'c');
      expect(e3.span.text, '"c"');
      expect(e3.span.start.offset, 45);
      expect(e3.span.end.offset, 48);
    });

    test('should parse constant list with mixed primitive elements', () {
      const source = '[1, "two", true]';
      final doc = parseAst(
        'struct S { list<any> mixed = $source; }',
      ); // Assuming 'any' or similar for mixed types
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.text, source);
      expect(constList.span.start.offset, 29);
      expect(constList.span.end.offset, 45);

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;
      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span.text, '1');
      expect(e1.span.start.offset, 30);
      expect(e1.span.end.offset, 31);

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.rawValue, '"two"');
      expect(e2.value, 'two');
      expect(e2.span.text, '"two"');
      expect(e2.span.start.offset, 33);
      expect(e2.span.end.offset, 38);

      final e3 = constList.elements[2] as BoolConstantNode;
      expect(e3.rawValue, 'true');
      expect(e3.value, true);
      expect(e3.span.text, 'true');
      expect(e3.span.start.offset, 40);
      expect(e3.span.end.offset, 44);
    });

    test('should parse constant list with nested constant list', () {
      const source = '[[1, 2], [3, 4]]';
      final doc = parseAst('struct S { list<list<i32>> nested = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constList = field.defaultValue! as ConstListNode;

      expect(constList.span.text, source);
      expect(constList.span.start.offset, 36);
      expect(constList.span.end.offset, 52);

      expect(constList.elements, hasLength(2));

      final e1 = constList.elements[0] as ConstListNode;
      expect(e1.elements, hasLength(2));
      expect(e1.span.text, '[1, 2]');
      expect(e1.span.start.offset, 37);
      expect(e1.span.end.offset, 43);

      final e11 = e1.elements[0] as IntConstantNode;
      expect(e11.rawValue, '1');
      expect(e11.value, 1);
      expect(e11.span.text, '1');
      expect(e11.span.start.offset, 38);
      expect(e11.span.end.offset, 39);

      final e12 = e1.elements[1] as IntConstantNode;
      expect(e12.rawValue, '2');
      expect(e12.value, 2);
      expect(e12.span.text, '2');
      expect(e12.span.start.offset, 41);
      expect(e12.span.end.offset, 42);

      final e2 = constList.elements[1] as ConstListNode;
      expect(e2.elements, hasLength(2));
      expect(e2.span.text, '[3, 4]');
      expect(e2.span.start.offset, 45);
      expect(e2.span.end.offset, 51);

      final e21 = e2.elements[0] as IntConstantNode;
      expect(e21.rawValue, '3');
      expect(e21.span.text, '3');
      expect(e21.span.start.offset, 46);
      expect(e21.span.end.offset, 47);

      final e22 = e2.elements[1] as IntConstantNode;
      expect(e22.rawValue, '4');
      expect(e22.span.text, '4');
      expect(e22.span.start.offset, 49);
      expect(e22.span.end.offset, 50);
    });

    test('should parse constant list with nested constant map', () {
      const source = '[{"key": 1}, {"key": 2}]';
      final doc = parseAst(
        'struct S { '
        'list<map<string, i32>> maps = $source; '
        '}',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ConstListNode;
      expect(constList.span.text, source);
      expect(constList.span.start.offset, 41);
      expect(constList.span.end.offset, 65);

      expect(constList.elements, hasLength(2));
      final e1 = constList.elements[0] as ConstMapNode;
      expect(e1.span.text, '{"key": 1}');
      expect(e1.span.start.offset, 42);
      expect(e1.span.end.offset, 52);

      expect(e1.entries, hasLength(1));
      final entry1 = e1.entries[0];
      expect((entry1.key as LiteralNode).rawValue, '"key"');
      expect((entry1.key as LiteralNode).value, 'key');
      expect(entry1.key.span.text, '"key"');
      expect(entry1.key.span.start.offset, 43);
      expect(entry1.key.span.end.offset, 48);

      expect((entry1.value as IntConstantNode).rawValue, '1');
      expect((entry1.value as IntConstantNode).value, 1);
      expect(entry1.value.span.text, '1');
      expect(entry1.value.span.start.offset, 50);
      expect(entry1.value.span.end.offset, 51);

      final e2 = constList.elements[1] as ConstMapNode;
      expect(e2.span.text, '{"key": 2}');
      expect(e2.span.start.offset, 54);
      expect(e2.span.end.offset, 64);

      expect(e2.entries, hasLength(1));
      final entry2 = e2.entries[0];
      expect((entry2.key as LiteralNode).rawValue, '"key"');
      expect((entry2.key as LiteralNode).value, 'key');
      expect(entry2.key.span.text, '"key"');
      expect(entry2.key.span.start.offset, 55);
      expect(entry2.key.span.end.offset, 60);
    });
  });
}
