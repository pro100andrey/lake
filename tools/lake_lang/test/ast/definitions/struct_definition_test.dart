import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('StructDefinition AST', () {
    test('should parse empty struct', () {
      const source = 'struct S {}';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 11);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span!.text, 'S');
      expect(def.identifier.span!.start.offset, 7);
      expect(def.identifier.span!.end.offset, 8);

      expect(def.fields, isEmpty);
    });

    test('should parse struct with one field', () {
      const source = 'struct S { i32 x }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 18);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span!.text, 'S');
      expect(def.identifier.span!.start.offset, 7);
      expect(def.identifier.span!.end.offset, 8);

      expect(def.fields, hasLength(1));

      final field = def.fields[0];
      expect((field.type as BaseTypeNode).type, 'i32');
      expect(field.type.span!.text, 'i32');
      expect(field.type.span!.start.offset, 11);
      expect(field.type.span!.end.offset, 14);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span!.text, 'x');
      expect(field.identifier.span!.start.offset, 15);
      expect(field.identifier.span!.end.offset, 16);
    });

    test('should parse struct with multiple fields', () {
      const source = 'struct S { i32 x, string y }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 28);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span!.text, 'S');
      expect(def.identifier.span!.start.offset, 7);
      expect(def.identifier.span!.end.offset, 8);

      expect(def.fields, hasLength(2));

      final field1 = def.fields[0];
      expect((field1.type as BaseTypeNode).type, 'i32');
      expect(field1.type.span!.text, 'i32');
      expect(field1.type.span!.start.offset, 11);
      expect(field1.type.span!.end.offset, 14);

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span!.text, 'x');
      expect(field1.identifier.span!.start.offset, 15);
      expect(field1.identifier.span!.end.offset, 16);
      expect(field1.defaultValue, isNull);

      final field2 = def.fields[1];
      expect((field2.type as BaseTypeNode).type, 'string');
      expect(field2.type.span!.text, 'string');
      expect(field2.identifier.value, 'y');
      expect(field2.identifier.span!.text, 'y');
    });

    test('should parse struct with fieldId and default value', () {
      const source = 'struct S { 1: i32 x = 42 }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 26);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span!.text, 'S');
      expect(def.identifier.span!.start.offset, 7);
      expect(def.identifier.span!.end.offset, 8);

      expect(def.fields, hasLength(1));

      final field = def.fields[0];
      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '1');
      expect(field.fieldId!.span!.text, '1');
      expect(field.fieldId!.span!.start.offset, 11);
      expect(field.fieldId!.span!.end.offset, 12);

      expect((field.type as BaseTypeNode).type, 'i32');
      expect(field.type.span!.text, 'i32');
      expect(field.type.span!.start.offset, 14);
      expect(field.type.span!.end.offset, 17);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span!.text, 'x');
      expect(field.identifier.span!.start.offset, 18);
      expect(field.identifier.span!.end.offset, 19);

      expect((field.defaultValue! as IntConstantNode).value, '42');
      expect(field.defaultValue!.span!.text, '42');
      expect(field.defaultValue!.span!.start.offset, 22);
      expect(field.defaultValue!.span!.end.offset, 24);
    });
  });
}
