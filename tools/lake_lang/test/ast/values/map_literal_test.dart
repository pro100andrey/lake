import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('MapLiteral AST', () {
    test('should parse empty map literal', () {
      const source = '{}';
      final doc = parseAstFromString(
        'struct S { map<string, string> settings = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final constMap = field.defaultValue!.cast<MapLiteralNode>();
      expect(constMap.span, hasSpan(42, 44));
      expect(constMap.entries, isEmpty);
    });

    test('should parse map literal with string keys and string values', () {
      const source = '{"name": "Alice", "city": "New York"}';
      final doc = parseAstFromString(
        'struct S { map<string, string> info = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final constMap = field.defaultValue!.cast<MapLiteralNode>();
      expect(constMap.span, hasSpan(38, 75));

      final [entry1, entry2] = constMap.entries
          .cast<({StringLiteralNode key, StringLiteralNode value})>();

      expect(entry1.key.rawValue, '"name"');
      expect(entry1.key.value, 'name');
      expect(entry1.key.span, hasSpan(39, 45));

      expect(entry1.value.rawValue, '"Alice"');
      expect(entry1.value.value, 'Alice');
      expect(entry1.value.span, hasSpan(47, 54));

      expect(entry2.key.rawValue, '"city"');
      expect(entry2.key.value, 'city');
      expect(entry2.key.span, hasSpan(56, 62));

      expect(entry2.value.rawValue, '"New York"');
      expect(entry2.value.value, 'New York');
      expect(entry2.value.span, hasSpan(64, 74));
    });

    test('should parse map literal with integer keys and boolean values', () {
      const source = '{1: true, 2: false}';
      final doc = parseAstFromString(
        'struct S { map<i32, bool> flags = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final constMap = field.defaultValue!.cast<MapLiteralNode>();
      expect(constMap.span, hasSpan(34, 53));

      final [entry0, entry1] = constMap.entries
          .cast<({IntLiteralNode key, BoolLiteralNode value})>();

      expect(entry0.key.rawValue, '1');
      expect(entry0.key.value, 1);
      expect(entry0.key.span, hasSpan(35, 36));

      expect(entry0.value.rawValue, 'true');
      expect(entry0.value.value, true);
      expect(entry0.value.span, hasSpan(38, 42));

      expect(entry1.key.rawValue, '2');
      expect(entry1.key.value, 2);
      expect(entry1.key.span, hasSpan(44, 45));

      expect(entry1.value.rawValue, 'false');
      expect(entry1.value.value, false);
      expect(entry1.value.span, hasSpan(47, 52));
    });

    test('should parse map literal nested list as value', () {
      const source = '{"numbers": [1, 2, 3]}';
      final doc = parseAstFromString(
        'struct S { map<string, list<i32>> data = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final constMap = field.defaultValue!.cast<MapLiteralNode>();
      expect(constMap.span, hasSpan(41, 63));

      expect(constMap.entries, hasLength(1));

      final [entry] = constMap.entries
          .cast<({StringLiteralNode key, ListLiteralNode value})>();

      expect(entry.key.rawValue, '"numbers"');
      expect(entry.key.value, 'numbers');
      expect(entry.key.span, hasSpan(42, 51));

      final constList = entry.value;
      expect(constList.span, hasSpan(53, 62));

      final [
        IntLiteralNode e0,
        IntLiteralNode e1,
        IntLiteralNode e2,
      ] = constList.elements
          .cast<IntLiteralNode>();

      expect(e0.rawValue, '1');
      expect(e0.value, 1);
      expect(e0.span, hasSpan(54, 55));

      expect(e1.rawValue, '2');
      expect(e1.value, 2);
      expect(e1.span, hasSpan(57, 58));

      expect(e2.rawValue, '3');
      expect(e2.value, 3);
      expect(e2.span, hasSpan(60, 61));
    });

    test('should parse map literal with nested map literal as value', () {
      const source = '{"user": {"id": 123, "active": true}}';
      final doc = parseAstFromString(
        'struct S { map<string, map<string, any>> settings = $source; }',
      ); // Assuming 'any'
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constMap = field.defaultValue!.cast<MapLiteralNode>();

      expect(constMap.span, hasSpan(52, 89));

      final [entry0] = constMap.entries
          .cast<({StringLiteralNode key, MapLiteralNode value})>();

      expect(entry0.key.rawValue, '"user"');
      expect(entry0.key.value, 'user');
      expect(entry0.key.span, hasSpan(53, 59));

      final nestedMap = entry0.value;
      expect(nestedMap.span, hasSpan(61, 88));

      final [ne1, ne2] = nestedMap.entries
          .cast<({StringLiteralNode key, AstNode value})>();

      expect(ne1.key.cast<StringLiteralNode>().rawValue, '"id"');
      expect(ne1.key.cast<StringLiteralNode>().value, 'id');
      expect(ne1.key.span, hasSpan(62, 66));

      expect(ne1.value.cast<IntLiteralNode>().rawValue, '123');
      expect(ne1.value.cast<IntLiteralNode>().value, 123);
      expect(ne1.value.span, hasSpan(68, 71));

      final nestedEntry2 = nestedMap.entries[1];
      expect(nestedEntry2.key.cast<StringLiteralNode>().rawValue, '"active"');
      expect(nestedEntry2.key.cast<StringLiteralNode>().value, 'active');
      expect(nestedEntry2.key.span, hasSpan(73, 81));

      expect(nestedEntry2.value.cast<BoolLiteralNode>().rawValue, 'true');
      expect(nestedEntry2.value.cast<BoolLiteralNode>().value, true);
      expect(nestedEntry2.value.span, hasSpan(83, 87));
    });

    test('should parse map literal with mixed keys and values', () {
      const source = '{"count": 5, 100: "score", true: false}';
      final doc = parseAstFromString(
        'struct S { map<any, any> mixedData = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;

      final constMap = field.defaultValue!.cast<MapLiteralNode>();

      final [entry0, entry1, entry2] = constMap.entries
          .cast<({AstNode key, AstNode value})>();

      expect(entry0.key.cast<StringLiteralNode>().rawValue, '"count"');
      expect(entry0.key.cast<StringLiteralNode>().value, 'count');
      expect(entry0.key.span, hasSpan(38, 45));

      expect(entry0.value.cast<IntLiteralNode>().rawValue, '5');
      expect(entry0.value.cast<IntLiteralNode>().value, 5);
      expect(entry0.value.span, hasSpan(47, 48));

      expect(entry1.key.cast<IntLiteralNode>().rawValue, '100');
      expect(entry1.key.cast<IntLiteralNode>().value, 100);
      expect(entry1.key.span, hasSpan(50, 53));

      expect(entry1.value.cast<StringLiteralNode>().rawValue, '"score"');
      expect(entry1.value.cast<StringLiteralNode>().value, 'score');
      expect(entry1.value.span, hasSpan(55, 62));

      expect(entry2.key.cast<BoolLiteralNode>().rawValue, 'true');
      expect(entry2.key.cast<BoolLiteralNode>().value, true);
      expect(entry2.key.span, hasSpan(64, 68));

      expect(entry2.value.cast<BoolLiteralNode>().rawValue, 'false');
      expect(entry2.value.cast<BoolLiteralNode>().value, false);
      expect(entry2.value.span, hasSpan(70, 75));
    });
  });

  group('MapLiteral AST (equable)', () {
    test('should be equal for identical map literals', () {
      const source = '{"key": "value"}';
      const source2 = '{"key": "value"}';
      final doc1 = parseAstFromString(
        'struct S { map<string, string> m = $source; }',
      );
      final doc2 = parseAstFromString(
        'struct S { map<string, string> m = $source2; }',
      );

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      final map1 = struct1.fields.first.defaultValue!.cast<MapLiteralNode>();
      final map2 = struct2.fields.first.defaultValue!.cast<MapLiteralNode>();

      expect(map1, equals(map2));
    });

    test('should not be equal for different maps literals', () {
      const source1 = '{"key1": "value1"}';
      const source2 = '{"key2": "value2"}';
      final doc1 = parseAstFromString(
        'struct S { map<string, string> m = $source1; }',
      );
      final doc2 = parseAstFromString(
        'struct S { map<string, string> m = $source2; }',
      );

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(struct1, isNot(equals(struct2)));

      final map1 = struct1.fields.first.defaultValue!.cast<MapLiteralNode>();
      final map2 = struct2.fields.first.defaultValue!.cast<MapLiteralNode>();

      expect(map1, isNot(equals(map2)));
    });
  });
}
