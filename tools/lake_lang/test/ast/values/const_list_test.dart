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

      expect(e1.value, '1');
      expect(e1.span.text, '1');
      expect(e1.span.start.offset, 32);
      expect(e1.span.end.offset, 33);

      final e2 = constList.elements[1] as IntConstantNode;
      expect(e2.value, '2');
      expect(e2.span.text, '2');
      expect(e2.span.start.offset, 35);
      expect(e2.span.end.offset, 36);

      final e3 = constList.elements[2] as IntConstantNode;
      expect(e3.value, '3');
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
      expect(e1, isA<LiteralNode>());
      expect(e1.value, '"a"');
      expect(e1.span.text, '"a"');
      expect(e1.span.start.offset, 35);
      expect(e1.span.end.offset, 38);

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2, isA<LiteralNode>());
      expect(e2.value, '"b"');
      expect(e2.span.text, '"b"');
      expect(e2.span.start.offset, 40);
      expect(e2.span.end.offset, 43);

      final e3 = constList.elements[2] as LiteralNode;
      expect(e3, isA<LiteralNode>());
      expect(e3.value, '"c"');
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
      expect(e1.value, '1');
      expect(e1.span.text, '1');
      expect(e1.span.start.offset, 30);
      expect(e1.span.end.offset, 31);

      final e2 = constList.elements[1] as LiteralNode;
      expect(e2.value, '"two"');
      expect(e2.span.text, '"two"');
      expect(e2.span.start.offset, 33);
      expect(e2.span.end.offset, 38);

      final e3 = constList.elements[2] as BoolConstantNode;
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
      expect(e11.value, '1');
      expect(e11.span.text, '1');
      expect(e11.span.start.offset, 38);
      expect(e11.span.end.offset, 39);
      final e12 = e1.elements[1] as IntConstantNode;
      expect(e12.value, '2');
      expect(e12.span.text, '2');
      expect(e12.span.start.offset, 41);
      expect(e12.span.end.offset, 42);

      final e2 = constList.elements[1] as ConstListNode;
      expect(e2.elements, hasLength(2));
      expect(e2.span.text, '[3, 4]');
      expect(e2.span.start.offset, 45);
      expect(e2.span.end.offset, 51);
      final e21 = e2.elements[0] as IntConstantNode;
      expect(e21.value, '3');
      expect(e21.span.text, '3');
      expect(e21.span.start.offset, 46);
      expect(e21.span.end.offset, 47);
      final e22 = e2.elements[1] as IntConstantNode;
      expect(e22.value, '4');
      expect(e22.span.text, '4');
      expect(e22.span.start.offset, 49);
      expect(e22.span.end.offset, 50);
    });

    test('should parse constant list with nested constant map', () {
      const source = '[{"key": 1}, {"key": 2}]';
      final doc = parseAst(
        'struct S { list<map<string, i32>> maps = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ConstListNode;
      expect(constList.span.text, source);
      expect(constList.span.start.offset, 41);
      expect(constList.span.end.offset, 65);

      expect(constList.elements, hasLength(2));

      final map1 = constList.elements[0] as ConstMapNode;
      expect(map1.entries, hasLength(1));

      expect(constList.elements[0], isA<ConstMapNode>());
      expect(constList.elements[1], isA<ConstMapNode>());

      final nestedMap1 = constList.elements[0] as ConstMapNode;
      expect(nestedMap1.entries, hasLength(1));
      expect(nestedMap1.entries.first.key, isA<LiteralNode>());
      expect((nestedMap1.entries.first.value as IntConstantNode).value, '1');
    });
  });
}
