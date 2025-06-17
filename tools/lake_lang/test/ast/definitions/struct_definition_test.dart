import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('StructDefinition AST (positive):', () {
    test('should parse empty struct', () {
      const source = 'struct S {}';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 11));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(7, 8));

      expect(def.fields, isEmpty);
    });

    test('should parse struct with one field', () {
      const source = 'struct S { i32 x }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 18));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(7, 8));

      expect(def.fields, hasLength(1));

      final field = def.fields[0];
      expect(field.type.cast<BaseTypeNode>().value, 'i32');
      expect(field.type.span, hasSpan(11, 14));

      expect(field.identifier.value, 'x');
      expect(field.identifier.span, hasSpan(15, 16));
    });

    test('should parse struct with multiple fields', () {
      const source = 'struct S { i32 x, string y }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 28));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(7, 8));

      expect(def.fields, hasLength(2));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.type.cast<BaseTypeNode>().value, 'i32');
      expect(field1.type.span, hasSpan(11, 14));

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span, hasSpan(15, 16));
      expect(field1.defaultValue, isNull);

      expect(field2.type.cast<BaseTypeNode>().value, 'string');
      expect(field2.identifier.value, 'y');
    });

    test('should parse struct with fieldId and default value', () {
      const source = 'struct S { 1: i32 x = 42 }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 26));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(7, 8));

      expect(def.fields, hasLength(1));

      final [FieldNode field] = def.fields;

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span, hasSpan(11, 12));

      expect(field.type.cast<BaseTypeNode>().value, 'i32');
      expect(field.type.span, hasSpan(14, 17));

      expect(field.identifier.value, 'x');
      expect(field.identifier.span, hasSpan(18, 19));

      final defaultValue = field.defaultValue!.cast<IntLiteralNode>();

      expect(defaultValue.rawValue, '42');
      expect(defaultValue.value, 42);
      expect(defaultValue.span, hasSpan(22, 24));
    });

    test('should parse struct with required fields', () {
      const source = 'struct User { required i32 id; required string name; }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 54));

      expect(def.identifier.value, 'User');
      expect(def.identifier.span, hasSpan(7, 11));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span, hasSpan(14, 22));

      expect(field1.type.cast<BaseTypeNode>().value, 'i32');
      expect(field1.type.span, hasSpan(23, 26));

      expect(field1.identifier.value, 'id');
      expect(field1.identifier.span, hasSpan(27, 29));

      expect(field1.defaultValue, isNull);

      expect(field2.requirement!.value, 'required');
      expect(field2.requirement!.span, hasSpan(31, 39));

      expect(field2.type.cast<BaseTypeNode>().value, 'string');
      expect(field2.type.span, hasSpan(40, 46));

      expect(field2.identifier.value, 'name');
      expect(field2.identifier.span, hasSpan(47, 51));

      expect(field2.defaultValue, isNull);
    });

    test('should parse struct with optional fields', () {
      const source =
          'struct Config { optional string host; optional i32 port; }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 58));

      expect(def.identifier.value, 'Config');
      expect(def.identifier.span, hasSpan(7, 13));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span, hasSpan(16, 24));

      expect(field1.type.cast<BaseTypeNode>().value, 'string');
      expect(field1.type.span, hasSpan(25, 31));

      expect(field1.identifier.value, 'host');
      expect(field1.identifier.span, hasSpan(32, 36));

      expect(field2.requirement!.value, 'optional');
      expect(field2.requirement!.span, hasSpan(38, 46));

      expect(field2.type.cast<BaseTypeNode>().value, 'i32');
      expect(field2.type.span, hasSpan(47, 50));

      expect(field2.identifier.value, 'port');
      expect(field2.identifier.span, hasSpan(51, 55));

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

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      expect(def.span, hasSpan(0, 80));

      expect(def.identifier.value, 'Data');
      expect(def.identifier.span, hasSpan(7, 11));

      final [FieldNode field1, FieldNode field2, FieldNode field3] = def.fields;

      expect(field1.type.span, hasSpan(14, 26));

      final field1Type = field1.type.cast<ListTypeNode>();
      expect(field1Type.elementType, isA<BaseTypeNode>());
      expect(field1Type.elementType.span, hasSpan(19, 25));

      expect(field1.identifier.value, 'tags');
      expect(field1.identifier.span, hasSpan(27, 31));
      expect(field1.defaultValue, isNull);

      expect(field2.type.span, hasSpan(33, 49));

      final field2Type = field2.type.cast<MapTypeNode>();
      expect(field2Type.keyType, isA<BaseTypeNode>());
      expect(field2Type.keyType.span, hasSpan(37, 43));

      expect(field2Type.valueType, isA<BaseTypeNode>());
      expect(field2Type.valueType.span, hasSpan(45, 48));

      expect(field2.identifier.value, 'scores');
      expect(field2.identifier.span, hasSpan(50, 56));
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

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(struct1, equals(struct2));
      expect(struct1.fields, equals(struct2.fields));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'struct User { string name; i32 age; }';
      const source2 = 'struct User { string email; i32 age; }';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(struct1, isNot(equals(struct2)));
      expect(struct1.fields, isNot(equals(struct2.fields)));
    });
  });
}
