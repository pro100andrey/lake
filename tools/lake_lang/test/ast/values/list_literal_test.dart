import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('ListLiteral AST', () {
    test('should parse empty list literal', () {
      const source = '[]';
      final doc = parseAstFromString(
        'struct S { list<i32> numbers = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constList = field.defaultValue!.cast<ListLiteralNode>();

      expect(constList.span, hasSpan(31, 33));
      expect(constList.elements, isEmpty);
    });

    test('should parse list literal with integer elements', () {
      const source = '[1, 2, 3]';
      final doc = parseAstFromString(
        'struct S { list<i32> numbers = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constList = field.defaultValue!.cast<ListLiteralNode>();

      expect(constList.span, hasSpan(31, 40));

      final [
        IntLiteralNode e0,
        IntLiteralNode e1,
        IntLiteralNode e2,
      ] = constList.elements
          .cast<IntLiteralNode>();

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

    test('should parse list literal with string elements', () {
      const source = '["a", "b", "c"]';
      final doc = parseAstFromString(
        'struct S { list<string> letters = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();
      final field = struct.fields.first;
      final constList = field.defaultValue!.cast<ListLiteralNode>();

      expect(constList.span, hasSpan(34, 49));

      final [
        StringLiteralNode e0,
        StringLiteralNode e1,
        StringLiteralNode e2,
      ] = constList.elements
          .cast<StringLiteralNode>();

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

    test('should parse list literal with mixed primitive elements', () {
      const source = '[1, "two", true]';
      final doc = parseAstFromString(
        'struct S { list<any> mixed = $source; }',
      ); // Assuming 'any' or similar for mixed types
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ListLiteralNode;
      expect(constList.span, hasSpan(29, 45));

      final [
        IntLiteralNode e0,
        StringLiteralNode e1,
        BoolLiteralNode e2,
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

    test('should parse list literal with nested list literal', () {
      const source = '[[1, 2], [3, 4]]';
      final doc = parseAstFromString(
        'struct S { list<list<i32>> nested = $source; }',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ListLiteralNode;
      expect(constList.span, hasSpan(36, 52));

      final [
        ListLiteralNode e0,
        ListLiteralNode e1,
      ] = constList.elements
          .cast<ListLiteralNode>();

      expect(e0.elements, hasLength(2));
      expect(e0.span, hasSpan(37, 43));

      final [
        IntLiteralNode e01,
        IntLiteralNode e02,
      ] = e0.elements
          .cast<IntLiteralNode>();

      expect(e01.rawValue, '1');
      expect(e01.value, 1);
      expect(e01.span, hasSpan(38, 39));

      expect(e02.rawValue, '2');
      expect(e02.value, 2);
      expect(e02.span, hasSpan(41, 42));

      final [
        IntLiteralNode e21,
        IntLiteralNode e22,
      ] = e1.elements
          .cast<IntLiteralNode>();

      expect(e21.rawValue, '3');
      expect(e21.value, 3);
      expect(e21.span, hasSpan(46, 47));

      expect(e22.rawValue, '4');
      expect(e22.value, 4);
      expect(e22.span, hasSpan(49, 50));
    });

    test('should parse list literal with nested map literal', () {
      const source = '[{"key": 1}, {"key": 2}]';
      final doc = parseAstFromString(
        'struct S { '
        'list<map<string, i32>> maps = $source; '
        '}',
      );
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      final constList = field.defaultValue! as ListLiteralNode;
      expect(constList.span, hasSpan(41, 65));

      final [
        MapLiteralNode e1,
        MapLiteralNode e2,
      ] = constList.elements
          .cast<MapLiteralNode>();

      expect(e1.span, hasSpan(42, 52));

      final [entry1] = e1.entries
          .cast<({StringLiteralNode key, IntLiteralNode value})>();

      expect(entry1.key.rawValue, '"key"');
      expect(entry1.key.value, 'key');
      expect(entry1.key.span, hasSpan(43, 48));

      expect(entry1.value.rawValue, '1');
      expect(entry1.value.value, 1);
      expect(entry1.value.span, hasSpan(50, 51));

      expect(e2.span, hasSpan(54, 64));

      final [entry2] = e2.entries
          .cast<({StringLiteralNode key, IntLiteralNode value})>();

      expect(e2.entries, hasLength(1));

      expect(entry2.key.rawValue, '"key"');
      expect(entry2.key.value, 'key');
      expect(entry2.key.span, hasSpan(55, 60));
    });
  });

  group('ListLiteral AST (equality)', () {
    test('should be equal for same list literal', () {
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

    test('should not be equal for different list literals', () {
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
