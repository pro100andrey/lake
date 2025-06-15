import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('MapType AST', () {
    test('should parse map with base types', () {
      const source = 'map<string, i32>';
      final doc = parseAndGetAst('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as MapTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 27);

      final keyType = fieldType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.text, 'string');
      expect(keyType.span.start.offset, 15);
      expect(keyType.span.end.offset, 21);

      final valueType = fieldType.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span.text, 'i32');
      expect(valueType.span.start.offset, 23);
      expect(valueType.span.end.offset, 26);
    });

    test('should parse map with custom types', () {
      const source = 'map<CustomKey, CustomValue>';
      final doc = parseAndGetAst('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as MapTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 38);

      final keyType = fieldType.keyType as CustomTypeNode;
      expect(keyType.value, 'CustomKey');
      expect(keyType.span.text, 'CustomKey');
      expect(keyType.span.start.offset, 15);
      expect(keyType.span.end.offset, 24);

      final valueType = fieldType.valueType as CustomTypeNode;
      expect(valueType.value, 'CustomValue');
      expect(valueType.span.text, 'CustomValue');
      expect(valueType.span.start.offset, 26);
      expect(valueType.span.end.offset, 37);
    });

    test('should parse map with a list as value type', () {
      const source = 'map<string, list<i32>>';
      final doc = parseAndGetAst('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as MapTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 33);

      final keyType = fieldType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.text, 'string');
      expect(keyType.span.start.offset, 15);
      expect(keyType.span.end.offset, 21);

      final valueType = fieldType.valueType as ListTypeNode;
      expect(valueType.span.text, 'list<i32>');
      expect(valueType.span.start.offset, 23);
      expect(valueType.span.end.offset, 32);

      final nestedElementType = valueType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'i32');
      expect(nestedElementType.span.text, 'i32');
      expect(nestedElementType.span.start.offset, 28);
      expect(nestedElementType.span.end.offset, 31);
    });

    test('should parse map with nested map as value type', () {
      const source = 'map<string, map<i32, bool>>';
      final doc = parseAndGetAst('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as MapTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 38);

      final keyType = fieldType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.text, 'string');
      expect(keyType.span.start.offset, 15);
      expect(keyType.span.end.offset, 21);

      final valueType = fieldType.valueType as MapTypeNode;
      expect(valueType.span.text, 'map<i32, bool>');
      expect(valueType.span.start.offset, 23);
      expect(valueType.span.end.offset, 37);

      final nestedKeyType = valueType.keyType as BaseTypeNode;
      expect(nestedKeyType.value, 'i32');
      expect(nestedKeyType.span.text, 'i32');
      expect(nestedKeyType.span.start.offset, 27);
      expect(nestedKeyType.span.end.offset, 30);

      final nestedValueType = valueType.valueType as BaseTypeNode;
      expect(nestedValueType.value, 'bool');
      expect(nestedValueType.span.text, 'bool');
      expect(nestedValueType.span.start.offset, 32);
      expect(nestedValueType.span.end.offset, 36);
    });

    test('should parse map with a set as key type', () {
      const source = 'map<set<string>, i32>';
      final doc = parseAndGetAst('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as MapTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 32);

      final keyType = fieldType.keyType as SetTypeNode;
      expect(keyType.span.text, 'set<string>');
      expect(keyType.span.start.offset, 15);
      expect(keyType.span.end.offset, 26);

      final nestedElementType = keyType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'string');
      expect(nestedElementType.span.text, 'string');
      expect(nestedElementType.span.start.offset, 19);
      expect(nestedElementType.span.end.offset, 25);

      final valueType = fieldType.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span.text, 'i32');
      expect(valueType.span.start.offset, 28);
      expect(valueType.span.end.offset, 31);
    });
  });

  group('MapType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'map<string, i32>';
      final doc1 = parseAndGetAst('struct S { $source x; }');
      final doc2 = parseAndGetAst('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAndGetAst('struct S { map<string, i32> x; }');
      final doc2 = parseAndGetAst('struct S { map<string, bool> x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
