import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Field AST', () {
    test('should parse field without field id', () {
      const source = 'i32 count;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 21);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 11);
      expect(field.type.span.end.offset, 14);

      expect(field.identifier.value, 'count');
      expect(field.identifier.span.text, 'count');
      expect(field.identifier.span.start.offset, 15);
      expect(field.identifier.span.end.offset, 20);

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with field id', () {
      const source = '1: i32 count;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 24);

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '1');
      expect(field.fieldId!.span.text, '1');
      expect(field.fieldId!.span.start.offset, 11);
      expect(field.fieldId!.span.end.offset, 12);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 14);
      expect(field.type.span.end.offset, 17);

      expect(field.identifier.value, 'count');
      expect(field.identifier.span.text, 'count');
      expect(field.identifier.span.start.offset, 18);
      expect(field.identifier.span.end.offset, 23);

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNotNull);
    });

    test('should parse required field', () {
      const source = '2: required string name;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 35);

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '2');
      expect(field.fieldId!.span.text, '2');
      expect(field.fieldId!.span.start.offset, 11);
      expect(field.fieldId!.span.end.offset, 12);

      expect(field.isRequired, isTrue);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isTrue);
      expect(field.requirement!.value, 'required');
      expect(field.requirement!.span.text, 'required');
      expect(field.requirement!.span.start.offset, 14);
      expect(field.requirement!.span.end.offset, 22);

      expect((field.type as BaseTypeNode).value, 'string');
      expect(field.type.span.text, 'string');
      expect(field.type.span.start.offset, 23);
      expect(field.type.span.end.offset, 29);

      expect(field.identifier.span.text, 'name');
      expect(field.identifier.span.start.offset, 30);
      expect(field.identifier.span.end.offset, 34);

      expect(field.defaultValue, isNull);
    });

    test('should parse optional field', () {
      const source = '3: optional bool flag;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 33);

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '3');
      expect(field.fieldId!.span.text, '3');
      expect(field.fieldId!.span.start.offset, 11);
      expect(field.fieldId!.span.end.offset, 12);

      expect(field.isRequired, isFalse);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isFalse);
      expect(field.requirement!.value, 'optional');
      expect(field.requirement!.span.text, 'optional');
      expect(field.requirement!.span.start.offset, 14);

      expect(field.type is BaseTypeNode, isTrue);
      expect(field.type.span.text, 'bool');
      expect(field.type.span.start.offset, 23);
      expect(field.type.span.end.offset, 27);

      expect(field.identifier.value, 'flag');
      expect(field.identifier.span.text, 'flag');
      expect(field.identifier.span.start.offset, 28);
      expect(field.identifier.span.end.offset, 32);

      expect(field.defaultValue, isNull);
    });

    test('should parse field with default value', () {
      const source = '1: optional i32 count = 0;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 37);

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '1');
      expect(field.fieldId!.span.text, '1');
      expect(field.fieldId!.span.start.offset, 11);
      expect(field.fieldId!.span.end.offset, 12);

      expect(field.isRequired, isFalse);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isFalse);
      expect(field.requirement!.value, 'optional');
      expect(field.requirement!.span.text, 'optional');
      expect(field.requirement!.span.start.offset, 14);
      expect(field.requirement!.span.end.offset, 22);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 23);
      expect(field.type.span.end.offset, 26);

      expect(field.identifier.value, 'count');
      expect(field.identifier.span.text, 'count');
      expect(field.identifier.span.start.offset, 27);
      expect(field.identifier.span.end.offset, 32);

      expect(field.defaultValue, isNotNull);
      expect((field.defaultValue! as IntConstantNode).value, '0');
      expect(field.defaultValue!.span.text, '0');
      expect(field.defaultValue!.span.start.offset, 35);
      expect(field.defaultValue!.span.end.offset, 36);
    });

    test('should parse field with list type', () {
      const source = 'list<string> tags;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 29);

      expect(field.type is ListTypeNode, isTrue);
      expect(field.type.span.text, 'list<string>');
      expect(field.type.span.start.offset, 11);
      expect(field.type.span.end.offset, 23);

      final listType = field.type as ListTypeNode;
      final elementType = listType.elementType as BaseTypeNode;

      expect(elementType.value, 'string');
      expect(elementType.span.text, 'string');
      expect(elementType.span.start.offset, 16);
      expect(elementType.span.end.offset, 22);

      expect(field.identifier.value, 'tags');
      expect(field.identifier.span.text, 'tags');
      expect(field.identifier.span.start.offset, 24);
      expect(field.identifier.span.end.offset, 28);

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with map type and default value', () {
      const source = 'map<string, i32> dict = {};';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 38);

      expect(field.type is MapTypeNode, isTrue);
      expect(field.type.span.text, 'map<string, i32>');
      expect(field.type.span.start.offset, 11);
      expect(field.type.span.end.offset, 27);

      final mapType = field.type as MapTypeNode;
      expect(mapType.keyType is BaseTypeNode, isTrue);
      expect((mapType.keyType as BaseTypeNode).value, 'string');
      expect(mapType.keyType.span.text, 'string');
      expect(mapType.keyType.span.start.offset, 15);
      expect(mapType.keyType.span.end.offset, 21);

      expect(mapType.valueType is BaseTypeNode, isTrue);
      expect((mapType.valueType as BaseTypeNode).value, 'i32');
      expect(mapType.valueType.span.text, 'i32');
      expect(mapType.valueType.span.start.offset, 23);
      expect(mapType.valueType.span.end.offset, 26);

      expect(field.identifier.value, 'dict');
      expect(field.identifier.span.text, 'dict');
      expect(field.identifier.span.start.offset, 28);
      expect(field.identifier.span.end.offset, 32);

      expect(field.defaultValue is ConstMapNode, isTrue);
      final defaultValue = field.defaultValue! as ConstMapNode;
      expect(defaultValue.span.text, '{}');
      expect(defaultValue.span.start.offset, 35);
      expect(defaultValue.span.end.offset, 37);
      expect(defaultValue.entries, isEmpty);

      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with nested container type', () {
      const source = 'list<map<string, list<i32>>> complex;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 48);

      expect(field.type.span.text, 'list<map<string, list<i32>>>');
      expect(field.type.span.start.offset, 11);
      expect(field.type.span.end.offset, 39);

      final listType = field.type as ListTypeNode;
      final mapType = listType.elementType as MapTypeNode;
      expect(mapType.span.text, 'map<string, list<i32>>');
      expect(mapType.span.start.offset, 16);
      expect(mapType.span.end.offset, 38);

      final keyType = mapType.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.text, 'string');
      expect(keyType.span.start.offset, 20);
      expect(keyType.span.end.offset, 26);

      final valueType = mapType.valueType as ListTypeNode;
      expect(valueType.span.text, 'list<i32>');
      expect(valueType.span.start.offset, 28);
      expect(valueType.span.end.offset, 37);

      final innerListType = valueType.elementType as BaseTypeNode;
      expect(innerListType.value, 'i32');
      expect(innerListType.span.text, 'i32');
      expect(innerListType.span.start.offset, 33);
      expect(innerListType.span.end.offset, 36);

      expect(field.identifier.value, 'complex');
      expect(field.identifier.span.text, 'complex');
      expect(field.identifier.span.start.offset, 40);
      expect(field.identifier.span.end.offset, 47);

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with custom type', () {
      const source = 'MyType ref;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 22);

      final typeNode = field.type as CustomTypeNode;
      expect(typeNode.value, 'MyType');
      expect(typeNode.span.text, 'MyType');
      expect(typeNode.span.start.offset, 11);
      expect(typeNode.span.end.offset, 17);

      expect(field.identifier.value, 'ref');
      expect(field.identifier.span.text, 'ref');
      expect(field.identifier.span.start.offset, 18);
      expect(field.identifier.span.end.offset, 21);

      expect(field.defaultValue, isNull);
      expect(field.isRequired, isFalse);
      expect(field.fieldId, isNull);
    });

    test('should parse field with field id, required, and default value', () {
      const source = '4: required i32 count = 10;';
      final doc = parseAst('struct S { $source }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;

      expect(field.span.text, source);
      expect(field.span.start.offset, 11);
      expect(field.span.end.offset, 38);

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '4');
      expect(field.fieldId!.span.text, '4');
      expect(field.fieldId!.span.start.offset, 11);
      expect(field.fieldId!.span.end.offset, 12);

      expect(field.isRequired, isTrue);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.isRequired, isTrue);
      expect(field.requirement!.value, 'required');
      expect(field.requirement!.span.text, 'required');
      expect(field.requirement!.span.start.offset, 14);
      expect(field.requirement!.span.end.offset, 22);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 23);
      expect(field.type.span.end.offset, 26);

      expect(field.identifier.value, 'count');
      expect(field.identifier.span.text, 'count');
      expect(field.identifier.span.start.offset, 27);
      expect(field.identifier.span.end.offset, 32);

      expect(field.defaultValue, isNotNull);
      expect((field.defaultValue! as IntConstantNode).value, '10');
      expect(field.defaultValue!.span.text, '10');
      expect(field.defaultValue!.span.start.offset, 35);
      expect(field.defaultValue!.span.end.offset, 37);
    });
  });
}
