import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('Field AST', () {
    test('should parse field without field id', () {
      const source = 'i32 count;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 21));

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span, hasSpan(11, 14));

      expect(field.identifier.value, 'count');
      expect(field.identifier.span, hasSpan(15, 20));

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with field id', () {
      const source = '1: i32 count;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 24));

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span, hasSpan(11, 12));

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span, hasSpan(14, 17));

      expect(field.identifier.value, 'count');
      expect(field.identifier.span, hasSpan(18, 23));

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNotNull);
    });

    test('should parse required field', () {
      const source = '2: required string name;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 35));

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '2');
      expect(field.fieldId!.value, 2);
      expect(field.fieldId!.span, hasSpan(11, 12));

      expect(field.isRequired, isTrue);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isTrue);
      expect(field.requirement!.value, 'required');
      expect(field.requirement!.span, hasSpan(14, 22));

      expect((field.type as BaseTypeNode).value, 'string');
      expect(field.type.span, hasSpan(23, 29));

      expect(field.identifier.span, hasSpan(30, 34));

      expect(field.defaultValue, isNull);
    });

    test('should parse optional field', () {
      const source = '3: optional bool flag;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 33));

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '3');
      expect(field.fieldId!.value, 3);
      expect(field.fieldId!.span, hasSpan(11, 12));

      expect(field.isRequired, isFalse);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isFalse);
      expect(field.requirement!.value, 'optional');
      expect(field.requirement!.span, hasSpan(14, 22));

      expect(field.type is BaseTypeNode, isTrue);
      expect(field.type.span, hasSpan(23, 27));

      expect(field.identifier.value, 'flag');
      expect(field.identifier.span, hasSpan(28, 32));

      expect(field.defaultValue, isNull);
    });

    test('should parse field with default value', () {
      const source = '1: optional i32 count = 0;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 37));

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span, hasSpan(11, 12));

      expect(field.isRequired, isFalse);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isFalse);
      expect(field.requirement!.value, 'optional');
      expect(field.requirement!.span, hasSpan(14, 22));

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span, hasSpan(23, 26));

      expect(field.identifier.value, 'count');
      expect(field.identifier.span, hasSpan(27, 32));

      final defaultValue = field.defaultValue! as IntConstantNode;
      expect(defaultValue.rawValue, '0');
      expect(defaultValue.value, 0);
      expect(defaultValue.span, hasSpan(35, 36));
    });

    test('should parse field with list type', () {
      const source = 'list<string> tags;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 29));

      expect(field.type is ListTypeNode, isTrue);
      expect(field.type.span, hasSpan(11, 23));

      final listType = field.type as ListTypeNode;
      final elementType = listType.elementType as BaseTypeNode;

      expect(elementType.value, 'string');
      expect(elementType.span, hasSpan(16, 22));

      expect(field.identifier.value, 'tags');
      expect(field.identifier.span, hasSpan(24, 28));

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with map type and default value', () {
      const source = 'map<string, i32> dict = {};';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 38));

      expect(field.type is MapTypeNode, isTrue);
      expect(field.type.span, hasSpan(11, 27));

      final mapType = field.type as MapTypeNode;
      expect(mapType.keyType is BaseTypeNode, isTrue);
      expect((mapType.keyType as BaseTypeNode).value, 'string');
      expect(mapType.keyType.span, hasSpan(15, 21));

      expect(mapType.valueType is BaseTypeNode, isTrue);
      expect((mapType.valueType as BaseTypeNode).value, 'i32');
      expect(mapType.valueType.span, hasSpan(23, 26));

      expect(field.identifier.value, 'dict');
      expect(field.identifier.span, hasSpan(28, 32));

      expect(field.defaultValue is ConstMapNode, isTrue);
      final defaultValue = field.defaultValue! as ConstMapNode;
      expect(defaultValue.span, hasSpan(35, 37));
      expect(defaultValue.entries, isEmpty);

      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with nested container type', () {
      const source = 'list<map<string, list<i32>>> complex;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 48));

      expect(field.type.span, hasSpan(11, 39));

      final listType = field.type as ListTypeNode;
      final mapType = listType.elementType as MapTypeNode;
      expect(mapType.span, hasSpan(16, 38));

      final keyType = mapType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span, hasSpan(20, 26));

      final valueType = mapType.valueType as ListTypeNode;
      expect(valueType.span, hasSpan(28, 37));

      final innerListType = valueType.elementType as BaseTypeNode;
      expect(innerListType.value, 'i32');
      expect(innerListType.span, hasSpan(33, 36));

      expect(field.identifier.value, 'complex');
      expect(field.identifier.span, hasSpan(40, 47));

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with custom type', () {
      const source = 'MyType ref;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 22));

      final typeNode = field.type as CustomTypeNode;
      expect(typeNode.value, 'MyType');
      expect(typeNode.span, hasSpan(11, 17));

      expect(field.identifier.value, 'ref');
      expect(field.identifier.span, hasSpan(18, 21));

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with field id, required, and default value', () {
      const source = '4: required i32 count = 10;';
      final doc = parseAstFromString('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span, hasSpan(11, 38));

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '4');
      expect(field.fieldId!.value, 4);
      expect(field.fieldId!.span, hasSpan(11, 12));

      expect(field.isRequired, isTrue);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isTrue);
      expect(field.requirement!.value, 'required');
      expect(field.requirement!.span, hasSpan(14, 22));

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span, hasSpan(23, 26));

      expect(field.identifier.value, 'count');
      expect(field.identifier.span, hasSpan(27, 32));

      final defaultValue = field.defaultValue! as IntConstantNode;
      expect(defaultValue.rawValue, '10');
      expect(defaultValue.value, 10);
      expect(defaultValue.span, hasSpan(35, 37));
    });
  });

  group('Field AST (equivalence)', () {
    test('should be equivalent to another field', () {
      const source1 = '4: required i32 count = 10;';
      const source2 = '4: required i32 count = 10;';
      final doc1 = parseAstFromString('struct S { $source1 }');
      final doc2 = parseAstFromString('struct S { $source2 }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));
      expect(struct1.fields, equals(struct2.fields));
    });

    test('should not be equivalent to different field', () {
      const source1 = '4: required i32 count = 10;';
      const source2 = '5: optional i32 count = 20;';
      final doc1 = parseAstFromString('struct S { $source1 }');
      final doc2 = parseAstFromString('struct S { $source2 }');

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, isNot(equals(struct2)));
      expect(struct1.fields, isNot(equals(struct2.fields)));
    });
  });
}
