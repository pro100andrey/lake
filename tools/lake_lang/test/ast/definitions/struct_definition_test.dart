import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('StructDefinition AST (positive):', () {
    test('should parse empty struct', () {
      const source = 'struct S {}';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 11);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 8);

      expect(def.fields, isEmpty);
    });

    test('should parse struct with one field', () {
      const source = 'struct S { i32 x }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 18);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 8);

      expect(def.fields, hasLength(1));

      final field = def.fields[0];
      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.start, 11);
      expect(field.type.span.end, 14);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.start, 15);
      expect(field.identifier.span.end, 16);
    });

    test('should parse struct with multiple fields', () {
      const source = 'struct S { i32 x, string y }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 28);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 8);

      expect(def.fields, hasLength(2));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.start, 11);
      expect(field1.type.span.end, 14);

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span.start, 15);
      expect(field1.identifier.span.end, 16);
      expect(field1.defaultValue, isNull);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.identifier.value, 'y');
    });

    test('should parse struct with fieldId and default value', () {
      const source = 'struct S { 1: i32 x = 42 }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 26);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 8);

      expect(def.fields, hasLength(1));

      final [FieldNode field] = def.fields;

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span.start, 11);
      expect(field.fieldId!.span.end, 12);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.start, 14);
      expect(field.type.span.end, 17);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.start, 18);
      expect(field.identifier.span.end, 19);

      final defaultValue = field.defaultValue! as IntConstantNode;

      expect(defaultValue.rawValue, '42');
      expect(defaultValue.value, 42);
      expect(defaultValue.span.start, 22);
      expect(defaultValue.span.end, 24);
    });

    test('should parse struct with required fields', () {
      const source = 'struct User { required i32 id; required string name; }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 54);

      expect(def.identifier.value, 'User');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 11);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span.start, 14);
      expect(field1.requirement!.span.end, 22);

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.start, 23);
      expect(field1.type.span.end, 26);

      expect(field1.identifier.value, 'id');
      expect(field1.identifier.span.start, 27);
      expect(field1.identifier.span.end, 29);

      expect(field1.defaultValue, isNull);

      expect(field2.requirement!.value, 'required');
      expect(field2.requirement!.span.start, 31);
      expect(field2.requirement!.span.end, 39);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.type.span.start, 40);
      expect(field2.type.span.end, 46);

      expect(field2.identifier.value, 'name');
      expect(field2.identifier.span.start, 47);
      expect(field2.identifier.span.end, 51);

      expect(field2.defaultValue, isNull);
    });

    test('should parse struct with optional fields', () {
      const source =
          'struct Config { optional string host; optional i32 port; }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 58);

      expect(def.identifier.value, 'Config');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 13);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span.start, 16);
      expect(field1.requirement!.span.end, 24);

      expect((field1.type as BaseTypeNode).value, 'string');
      expect(field1.type.span.start, 25);
      expect(field1.type.span.end, 31);

      expect(field1.identifier.value, 'host');
      expect(field1.identifier.span.start, 32);
      expect(field1.identifier.span.end, 36);

      expect(field2.requirement!.value, 'optional');
      expect(field2.requirement!.span.start, 38);
      expect(field2.requirement!.span.end, 46);

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.start, 47);
      expect(field2.type.span.end, 50);

      expect(field2.identifier.value, 'port');
      expect(field2.identifier.span.start, 51);
      expect(field2.identifier.span.end, 55);

      expect(field2.defaultValue, isNull);
    });

    test('should parse struct with container types as fields', () {
      const source =
          'struct Data '
          '{ '
          'list<string> tags; map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';

      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 80);

      expect(def.identifier.value, 'Data');
      expect(def.identifier.span.start, 7);
      expect(def.identifier.span.end, 11);

      final [FieldNode field1, FieldNode field2, FieldNode field3] = def.fields;

      expect(field1.type.span.start, 14);
      expect(field1.type.span.end, 26);

      final field1Type = field1.type as ListTypeNode;
      expect(field1Type.elementType, isA<BaseTypeNode>());
      expect(field1Type.elementType.span.start, 19);
      expect(field1Type.elementType.span.end, 25);

      expect(field1.identifier.value, 'tags');
      expect(field1.identifier.span.start, 27);
      expect(field1.identifier.span.end, 31);
      expect(field1.defaultValue, isNull);

      expect(field2.type.span.start, 33);
      expect(field2.type.span.end, 49);

      final field2Type = field2.type as MapTypeNode;
      expect(field2Type.keyType, isA<BaseTypeNode>());
      expect(field2Type.keyType.span.start, 37);
      expect(field2Type.keyType.span.end, 43);

      expect(field2Type.valueType, isA<BaseTypeNode>());
      expect(field2Type.valueType.span.start, 45);
      expect(field2Type.valueType.span.end, 48);

      expect(field2.identifier.value, 'scores');
      expect(field2.identifier.span.start, 50);
      expect(field2.identifier.span.end, 56);
      expect(field2.defaultValue, isNull);
    });
  });

  group('StructDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source = 'struct User { string name; i32 age; }';
      const source2 = 'struct User { string name; i32 age; }';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));
      expect(struct1.fields, equals(struct2.fields));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'struct User { string name; i32 age; }';
      const source2 = 'struct User { string email; i32 age; }';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, isNot(equals(struct2)));
      expect(struct1.fields, isNot(equals(struct2.fields)));
    });
  });
}
