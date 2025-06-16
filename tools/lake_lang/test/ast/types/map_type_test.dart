import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('MapType AST', () {
    test('should parse map with base types', () {
      const source = 'map<string, i32>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as MapTypeNode;
      expect(fieldType.span, hasSpan(11, 27));

      final keyType = fieldType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span, hasSpan(15, 21));

      final valueType = fieldType.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span, hasSpan(23, 26));
    });

    test('should parse map with custom types', () {
      const source = 'map<CustomKey, CustomValue>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as MapTypeNode;
      expect(fieldType.span, hasSpan(11, 38));

      final keyType = fieldType.keyType as CustomTypeNode;
      expect(keyType.value, 'CustomKey');
      expect(keyType.span, hasSpan(15, 24));

      final valueType = fieldType.valueType as CustomTypeNode;
      expect(valueType.value, 'CustomValue');
      expect(valueType.span, hasSpan(26, 37));
    });

    test('should parse map with a list as value type', () {
      const source = 'map<string, list<i32>>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as MapTypeNode;
      expect(fieldType.span, hasSpan(11, 33));

      final keyType = fieldType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span, hasSpan(15, 21));

      final valueType = fieldType.valueType as ListTypeNode;
      expect(valueType.span, hasSpan(23, 32));

      final nestedElementType = valueType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'i32');
      expect(nestedElementType.span, hasSpan(28, 31));
    });

    test('should parse map with nested map as value type', () {
      const source = 'map<string, map<i32, bool>>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as MapTypeNode;
      expect(fieldType.span, hasSpan(11, 38));

      final keyType = fieldType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span, hasSpan(15, 21));

      final valueType = fieldType.valueType as MapTypeNode;
      expect(valueType.span, hasSpan(23, 37));

      final nestedKeyType = valueType.keyType as BaseTypeNode;
      expect(nestedKeyType.value, 'i32');
      expect(nestedKeyType.span, hasSpan(27, 30));

      final nestedValueType = valueType.valueType as BaseTypeNode;
      expect(nestedValueType.value, 'bool');
      expect(nestedValueType.span, hasSpan(32, 36));
    });

    test('should parse map with a set as key type', () {
      const source = 'map<set<string>, i32>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as MapTypeNode;
      expect(fieldType.span, hasSpan(11, 32));

      final keyType = fieldType.keyType as SetTypeNode;
      expect(keyType.span, hasSpan(15, 26));

      final nestedElementType = keyType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'string');
      expect(nestedElementType.span, hasSpan(19, 25));

      final valueType = fieldType.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span, hasSpan(28, 31));
    });
  });

  group('MapType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'map<string, i32>';
      final doc1 = parseAstFromString('struct S { $source x; }');
      final doc2 = parseAstFromString('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAstFromString('struct S { map<string, i32> x; }');
      final doc2 = parseAstFromString('struct S { map<string, bool> x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
