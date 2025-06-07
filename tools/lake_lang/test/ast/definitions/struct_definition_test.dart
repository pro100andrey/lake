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
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 11);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 8);

      expect(def.fields, isEmpty);
    });

    test('should parse struct with one field', () {
      const source = 'struct S { i32 x }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 18);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 8);

      expect(def.fields, hasLength(1));

      final field = def.fields[0];
      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 11);
      expect(field.type.span.end.offset, 14);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.text, 'x');
      expect(field.identifier.span.start.offset, 15);
      expect(field.identifier.span.end.offset, 16);
    });

    test('should parse struct with multiple fields', () {
      const source = 'struct S { i32 x, string y }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 28);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 8);

      expect(def.fields, hasLength(2));

      final field1 = def.fields[0];
      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.text, 'i32');
      expect(field1.type.span.start.offset, 11);
      expect(field1.type.span.end.offset, 14);

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span.text, 'x');
      expect(field1.identifier.span.start.offset, 15);
      expect(field1.identifier.span.end.offset, 16);
      expect(field1.defaultValue, isNull);

      final field2 = def.fields[1];
      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.type.span.text, 'string');
      expect(field2.identifier.value, 'y');
      expect(field2.identifier.span.text, 'y');
    });

    test('should parse struct with fieldId and default value', () {
      const source = 'struct S { 1: i32 x = 42 }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 26);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 8);

      expect(def.fields, hasLength(1));

      final field = def.fields[0];
      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.value, '1');
      expect(field.fieldId!.span.text, '1');
      expect(field.fieldId!.span.start.offset, 11);
      expect(field.fieldId!.span.end.offset, 12);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 14);
      expect(field.type.span.end.offset, 17);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.text, 'x');
      expect(field.identifier.span.start.offset, 18);
      expect(field.identifier.span.end.offset, 19);

      expect((field.defaultValue! as IntConstantNode).value, '42');
      expect(field.defaultValue!.span.text, '42');
      expect(field.defaultValue!.span.start.offset, 22);
      expect(field.defaultValue!.span.end.offset, 24);
    });

    test('should parse struct with required fields', () {
      const source = 'struct User { required i32 id; required string name; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 54);

      expect(def.identifier.value, 'User');
      expect(def.identifier.span.text, 'User');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 11);

      expect(def.fields, hasLength(2));

      final field1 = def.fields[0];
      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span.text, 'required');
      expect(field1.requirement!.span.start.offset, 14);
      expect(field1.requirement!.span.end.offset, 22);

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.text, 'i32');
      expect(field1.type.span.start.offset, 23);
      expect(field1.type.span.end.offset, 26);

      expect(field1.identifier.value, 'id');
      expect(field1.identifier.span.text, 'id');
      expect(field1.identifier.span.start.offset, 27);
      expect(field1.identifier.span.end.offset, 29);

      expect(field1.defaultValue, isNull);

      final field2 = def.fields[1];
      expect(field2.requirement!.value, 'required');
      expect(field2.requirement!.span.text, 'required');
      expect(field2.requirement!.span.start.offset, 31);
      expect(field2.requirement!.span.end.offset, 39);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.type.span.text, 'string');
      expect(field2.type.span.start.offset, 40);
      expect(field2.type.span.end.offset, 46);

      expect(field2.identifier.value, 'name');
      expect(field2.identifier.span.text, 'name');
      expect(field2.identifier.span.start.offset, 47);
      expect(field2.identifier.span.end.offset, 51);

      expect(field2.defaultValue, isNull);
    });

    test('should parse struct with optional fields', () {
      const source =
          'struct Config { optional string host; optional i32 port; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 58);

      expect(def.identifier.value, 'Config');
      expect(def.identifier.span.text, 'Config');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 13);

      expect(def.fields, hasLength(2));

      final field1 = def.fields[0];
      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span.text, 'optional');
      expect(field1.requirement!.span.start.offset, 16);
      expect(field1.requirement!.span.end.offset, 24);

      expect((field1.type as BaseTypeNode).value, 'string');
      expect(field1.type.span.text, 'string');
      expect(field1.type.span.start.offset, 25);
      expect(field1.type.span.end.offset, 31);

      expect(field1.identifier.value, 'host');
      expect(field1.identifier.span.text, 'host');
      expect(field1.identifier.span.start.offset, 32);
      expect(field1.identifier.span.end.offset, 36);

      final field2 = def.fields[1];
      expect(field2.requirement!.value, 'optional');
      expect(field2.requirement!.span.text, 'optional');
      expect(field2.requirement!.span.start.offset, 38);
      expect(field2.requirement!.span.end.offset, 46);

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.text, 'i32');
      expect(field2.type.span.start.offset, 47);
      expect(field2.type.span.end.offset, 50);

      expect(field2.identifier.value, 'port');
      expect(field2.identifier.span.text, 'port');
      expect(field2.identifier.span.start.offset, 51);
      expect(field2.identifier.span.end.offset, 55);

      expect(field2.defaultValue, isNull);
    });

    test('should parse struct with container types as fields', () {
      const source =
          'struct Data '
          '{ '
          'list<string> tags; map<string, i32> scores; set<uuid> uniqueIds; '
          '}';

      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 80);

      expect(def.identifier.value, 'Data');
      expect(def.identifier.span.text, 'Data');
      expect(def.identifier.span.start.offset, 7);
      expect(def.identifier.span.end.offset, 11);

      expect(def.fields, hasLength(3));

      final field1 = def.fields[0];

      expect(field1.type.span.text, 'list<string>');
      expect(field1.type.span.start.offset, 14);
      expect(field1.type.span.end.offset, 26);

      final field1Type = field1.type as ListTypeNode;
      expect(field1Type.elementType, isA<BaseTypeNode>());
      expect(field1Type.elementType.span.text, 'string');
      expect(field1Type.elementType.span.start.offset, 19);
      expect(field1Type.elementType.span.end.offset, 25);

      expect(field1.identifier.value, 'tags');
      expect(field1.identifier.span.text, 'tags');
      expect(field1.identifier.span.start.offset, 27);
      expect(field1.identifier.span.end.offset, 31);
      expect(field1.defaultValue, isNull);

      final field2 = def.fields[1];
      expect(field2.type.span.text, 'map<string, i32>');
      expect(field2.type.span.start.offset, 33);
      expect(field2.type.span.end.offset, 49);

      final field2Type = field2.type as MapTypeNode;
      expect(field2Type.keyType, isA<BaseTypeNode>());
      expect(field2Type.keyType.span.text, 'string');
      expect(field2Type.keyType.span.start.offset, 37);
      expect(field2Type.keyType.span.end.offset, 43);

      expect(field2Type.valueType, isA<BaseTypeNode>());
      expect(field2Type.valueType.span.text, 'i32');
      expect(field2Type.valueType.span.start.offset, 45);
      expect(field2Type.valueType.span.end.offset, 48);

      expect(field2.identifier.value, 'scores');
      expect(field2.identifier.span.text, 'scores');
      expect(field2.identifier.span.start.offset, 50);
      expect(field2.identifier.span.end.offset, 56);
      expect(field2.defaultValue, isNull);
    });
  });
}
