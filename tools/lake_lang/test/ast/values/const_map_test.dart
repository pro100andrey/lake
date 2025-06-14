import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ConstMap AST', () {
    test('should parse empty constant map', () {
      const source = '{}';
      final doc = parseAst(
        'struct S { map<string, string> settings = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constMap = field.defaultValue! as ConstMapNode;

      expect(constMap, isA<ConstMapNode>());
      expect(constMap.span.text, source);
      expect(constMap.span.start.offset, 42);
      expect(constMap.span.end.offset, 44);
      expect(constMap.entries, isEmpty);
    });

    test('should parse constant map with string keys and string values', () {
      const source = '{"name": "Alice", "city": "New York"}';
      final doc = parseAst('struct S { map<string, string> info = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constMap = field.defaultValue! as ConstMapNode;

      expect(constMap.span.text, source);
      expect(constMap.span.start.offset, 38);
      expect(constMap.span.end.offset, 75);

      expect(constMap.entries, hasLength(2));

      final entry1 = constMap.entries[0];

      expect((entry1.key as LiteralNode).rawValue, '"name"');
      expect((entry1.key as LiteralNode).value, 'name');
      expect(entry1.key.span.text, '"name"');
      expect(entry1.key.span.start.offset, 39);
      expect(entry1.key.span.end.offset, 45);

      expect((entry1.value as LiteralNode).rawValue, '"Alice"');
      expect((entry1.value as LiteralNode).value, 'Alice');
      expect(entry1.value.span.text, '"Alice"');
      expect(entry1.value.span.start.offset, 47);
      expect(entry1.value.span.end.offset, 54);

      final entry2 = constMap.entries[1];
      expect((entry2.key as LiteralNode).rawValue, '"city"');
      expect((entry2.key as LiteralNode).value, 'city');
      expect(entry2.key.span.text, '"city"');
      expect(entry2.key.span.start.offset, 56);
      expect(entry2.key.span.end.offset, 62);

      expect((entry2.value as LiteralNode).rawValue, '"New York"');
      expect((entry2.value as LiteralNode).value, 'New York');
      expect(entry2.value.span.text, '"New York"');
      expect(entry2.value.span.start.offset, 64);
      expect(entry2.value.span.end.offset, 74);
    });

    test('should parse constant map with integer keys and boolean values', () {
      const source = '{1: true, 2: false}';
      final doc = parseAst('struct S { map<i32, bool> flags = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constMap = field.defaultValue! as ConstMapNode;

      expect(constMap.span.text, source);
      expect(constMap.span.start.offset, 34);
      expect(constMap.span.end.offset, 53);

      expect(constMap.entries, hasLength(2));

      final entry1 = constMap.entries[0];
      expect((entry1.key as IntConstantNode).rawValue, '1');
      expect((entry1.key as IntConstantNode).value, 1);
      expect(entry1.key.span.text, '1');
      expect(entry1.key.span.start.offset, 35);
      expect(entry1.key.span.end.offset, 36);

      expect((entry1.value as BoolConstantNode).rawValue, 'true');
      expect((entry1.value as BoolConstantNode).value, true);
      expect(entry1.value.span.text, 'true');
      expect(entry1.value.span.start.offset, 38);
      expect(entry1.value.span.end.offset, 42);

      final entry2 = constMap.entries[1];
      expect((entry2.key as IntConstantNode).rawValue, '2');
      expect((entry2.key as IntConstantNode).value, 2);
      expect(entry2.key.span.text, '2');
      expect(entry2.key.span.start.offset, 44);
      expect(entry2.key.span.end.offset, 45);

      expect((entry2.value as BoolConstantNode).rawValue, 'false');
      expect((entry2.value as BoolConstantNode).value, false);
      expect(entry2.value.span.text, 'false');
      expect(entry2.value.span.start.offset, 47);
      expect(entry2.value.span.end.offset, 52);
    });

    test('should parse constant map with nested constant list as value', () {
      const source = '{"numbers": [1, 2, 3]}';
      final doc = parseAst(
        'struct S { map<string, list<i32>> data = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constMap = field.defaultValue! as ConstMapNode;

      expect(constMap.span.text, source);
      expect(constMap.span.start.offset, 41);
      expect(constMap.span.end.offset, 63);

      expect(constMap.entries, hasLength(1));

      final entry = constMap.entries[0];
      expect((entry.key as LiteralNode).rawValue, '"numbers"');
      expect((entry.key as LiteralNode).value, 'numbers');
      expect(entry.key.span.text, '"numbers"');
      expect(entry.key.span.start.offset, 42);
      expect(entry.key.span.end.offset, 51);

      final constList = entry.value as ConstListNode;
      expect(constList.span.text, '[1, 2, 3]');
      expect(constList.span.start.offset, 53);
      expect(constList.span.end.offset, 62);

      expect(constList.elements, hasLength(3));

      final e1 = constList.elements[0] as IntConstantNode;
      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span.text, '1');
      expect(e1.span.start.offset, 54);
      expect(e1.span.end.offset, 55);

      final e2 = constList.elements[1] as IntConstantNode;
      expect(e2.rawValue, '2');
      expect(e2.value, 2);
      expect(e2.span.text, '2');
      expect(e2.span.start.offset, 57);
      expect(e2.span.end.offset, 58);

      final e3 = constList.elements[2] as IntConstantNode;
      expect(e3.rawValue, '3');
      expect(e3.value, 3);
      expect(e3.span.text, '3');
      expect(e3.span.start.offset, 60);
      expect(e3.span.end.offset, 61);
    });

    test('should parse constant map with nested constant map as value', () {
      const source = '{"user": {"id": 123, "active": true}}';
      final doc = parseAst(
        'struct S { map<string, map<string, any>> settings = $source; }',
      ); // Assuming 'any'
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constMap = field.defaultValue! as ConstMapNode;

      expect(constMap.span.text, source);
      expect(constMap.span.start.offset, 52);
      expect(constMap.span.end.offset, 89);

      expect(constMap.entries, hasLength(1));

      final entry = constMap.entries[0];
      expect((entry.key as LiteralNode).rawValue, '"user"');
      expect((entry.key as LiteralNode).value, 'user');
      expect(entry.key.span.text, '"user"');
      expect(entry.key.span.start.offset, 53);
      expect(entry.key.span.end.offset, 59);

      final nestedMap = entry.value as ConstMapNode;
      expect(nestedMap.span.text, '{"id": 123, "active": true}');
      expect(nestedMap.span.start.offset, 61);
      expect(nestedMap.span.end.offset, 88);

      expect(nestedMap.entries, hasLength(2));
      final nestedEntry1 = nestedMap.entries[0];
      expect((nestedEntry1.key as LiteralNode).rawValue, '"id"');
      expect((nestedEntry1.key as LiteralNode).value, 'id');
      expect(nestedEntry1.key.span.text, '"id"');
      expect(nestedEntry1.key.span.start.offset, 62);
      expect(nestedEntry1.key.span.end.offset, 66);

      expect((nestedEntry1.value as IntConstantNode).rawValue, '123');
      expect((nestedEntry1.value as IntConstantNode).value, 123);
      expect(nestedEntry1.value.span.text, '123');
      expect(nestedEntry1.value.span.start.offset, 68);
      expect(nestedEntry1.value.span.end.offset, 71);

      final nestedEntry2 = nestedMap.entries[1];
      expect((nestedEntry2.key as LiteralNode).rawValue, '"active"');
      expect((nestedEntry2.key as LiteralNode).value, 'active');
      expect(nestedEntry2.key.span.text, '"active"');
      expect(nestedEntry2.key.span.start.offset, 73);
      expect(nestedEntry2.key.span.end.offset, 81);

      expect((nestedEntry2.value as BoolConstantNode).rawValue, 'true');
      expect((nestedEntry2.value as BoolConstantNode).value, true);
      expect(nestedEntry2.value.span.text, 'true');
      expect(nestedEntry2.value.span.start.offset, 83);
      expect(nestedEntry2.value.span.end.offset, 87);
    });

    test('should parse constant map with mixed keys and values', () {
      const source = '{"count": 5, 100: "score", true: false}';
      final doc = parseAst(
        'struct S { map<any, any> mixedData = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final constMap = field.defaultValue! as ConstMapNode;

      expect(constMap.entries, hasLength(3));

      final entry1 = constMap.entries[0];
      expect((entry1.key as LiteralNode).rawValue, '"count"');
      expect((entry1.key as LiteralNode).value, 'count');
      expect(entry1.key.span.text, '"count"');
      expect(entry1.key.span.start.offset, 38);
      expect(entry1.key.span.end.offset, 45);

      expect((entry1.value as IntConstantNode).rawValue, '5');
      expect((entry1.value as IntConstantNode).value, 5);
      expect(entry1.value.span.text, '5');
      expect(entry1.value.span.start.offset, 47);
      expect(entry1.value.span.end.offset, 48);

      final entry2 = constMap.entries[1];
      expect((entry2.key as IntConstantNode).rawValue, '100');
      expect((entry2.key as IntConstantNode).value, 100);
      expect(entry2.key.span.text, '100');
      expect(entry2.key.span.start.offset, 50);
      expect(entry2.key.span.end.offset, 53);

      expect((entry2.value as LiteralNode).rawValue, '"score"');
      expect((entry2.value as LiteralNode).value, 'score');
      expect(entry2.value.span.text, '"score"');
      expect(entry2.value.span.start.offset, 55);
      expect(entry2.value.span.end.offset, 62);

      final entry3 = constMap.entries[2];
      expect((entry3.key as BoolConstantNode).rawValue, 'true');
      expect((entry3.key as BoolConstantNode).value, true);
      expect(entry3.key.span.text, 'true');
      expect(entry3.key.span.start.offset, 64);
      expect(entry3.key.span.end.offset, 68);

      expect((entry3.value as BoolConstantNode).rawValue, 'false');
      expect((entry3.value as BoolConstantNode).value, false);
      expect(entry3.value.span.text, 'false');
      expect(entry3.value.span.start.offset, 70);
      expect(entry3.value.span.end.offset, 75);
    });
  });

  group('ConstMap AST (equable)', () {
    test('should be equal for identical constant maps', () {
      const source = '{"key": "value"}';
      const source2 = '{"key": "value"}';
      final doc1 = parseAst('struct S { map<string, string> m = $source; }');
      final doc2 = parseAst('struct S { map<string, string> m = $source2; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      final map1 = struct1.fields.first.defaultValue! as ConstMapNode;
      final map2 = struct2.fields.first.defaultValue! as ConstMapNode;

      expect(map1, equals(map2));
    });

    test('should not be equal for different constant maps', () {
      const source1 = '{"key1": "value1"}';
      const source2 = '{"key2": "value2"}';
      final doc1 = parseAst('struct S { map<string, string> m = $source1; }');
      final doc2 = parseAst('struct S { map<string, string> m = $source2; }');

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, isNot(equals(struct2)));

      final map1 = struct1.fields.first.defaultValue! as ConstMapNode;
      final map2 = struct2.fields.first.defaultValue! as ConstMapNode;

      expect(map1, isNot(equals(map2)));
    });
  });
}
