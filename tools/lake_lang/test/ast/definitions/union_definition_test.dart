import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('UnionDefinition AST', () {
    test('should parse empty union', () {
      const source = 'union U {}';
      final doc = parseAndGetAst(source);
      final def = doc.definitions.first as UnionDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 10);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.text, 'U');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 7);

      expect(def.fields, isEmpty);
    });

    test('should parse union with one field', () {
      const source = 'union U { i32 x }';
      final doc = parseAndGetAst(source);
      final def = doc.definitions.first as UnionDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 17);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.text, 'U');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 7);

      final [FieldNode field] = def.fields;

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 10);
      expect(field.type.span.end.offset, 13);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.text, 'x');
      expect(field.identifier.span.start.offset, 14);
      expect(field.identifier.span.end.offset, 15);
    });

    test('should parse union with multiple fields', () {
      const source = 'union U { i32 x, string y }';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 27);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.text, 'U');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 7);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.text, 'i32');
      expect(field1.type.span.start.offset, 10);
      expect(field1.type.span.end.offset, 13);

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span.text, 'x');
      expect(field1.identifier.span.start.offset, 14);
      expect(field1.identifier.span.end.offset, 15);
      expect(field1.defaultValue, isNull);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.type.span.text, 'string');
      expect(field2.identifier.value, 'y');
      expect(field2.identifier.span.text, 'y');
    });

    test('should parse union with fieldId and default value', () {
      const source = 'union U { 1: i32 x = 42 }';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 25);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.text, 'U');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 7);

      final [FieldNode field] = def.fields;

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span.text, '1');
      expect(field.fieldId!.span.start.offset, 10);
      expect(field.fieldId!.span.end.offset, 11);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.text, 'i32');
      expect(field.type.span.start.offset, 13);
      expect(field.type.span.end.offset, 16);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.text, 'x');
      expect(field.identifier.span.start.offset, 17);
      expect(field.identifier.span.end.offset, 18);

      final defaultValue = field.defaultValue! as IntConstantNode;

      expect(defaultValue.rawValue, '42');
      expect(defaultValue.value, 42);
      expect(defaultValue.span.text, '42');
      expect(defaultValue.span.start.offset, 21);
      expect(defaultValue.span.end.offset, 23);
    });

    test('should parse union with required fields', () {
      const source = 'union User { required i32 id; required string name; }';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 53);

      expect(def.identifier.value, 'User');
      expect(def.identifier.span.text, 'User');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 10);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span.text, 'required');
      expect(field1.requirement!.span.start.offset, 13);
      expect(field1.requirement!.span.end.offset, 21);

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.text, 'i32');
      expect(field1.type.span.start.offset, 22);
      expect(field1.type.span.end.offset, 25);

      expect(field1.identifier.value, 'id');
      expect(field1.identifier.span.text, 'id');
      expect(field1.identifier.span.start.offset, 26);
      expect(field1.identifier.span.end.offset, 28);

      expect(field1.defaultValue, isNull);

      expect(field2.requirement!.value, 'required');
      expect(field2.requirement!.span.text, 'required');
      expect(field2.requirement!.span.start.offset, 30);
      expect(field2.requirement!.span.end.offset, 38);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.type.span.text, 'string');
      expect(field2.type.span.start.offset, 39);
      expect(field2.type.span.end.offset, 45);

      expect(field2.identifier.value, 'name');
      expect(field2.identifier.span.text, 'name');
      expect(field2.identifier.span.start.offset, 46);
      expect(field2.identifier.span.end.offset, 50);

      expect(field2.defaultValue, isNull);
    });

    test('should parse union with optional fields', () {
      const source =
          'union Config { optional string host; optional i32 port; }';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 57);

      expect(def.identifier.value, 'Config');
      expect(def.identifier.span.text, 'Config');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 12);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span.text, 'optional');
      expect(field1.requirement!.span.start.offset, 15);
      expect(field1.requirement!.span.end.offset, 23);

      expect((field1.type as BaseTypeNode).value, 'string');
      expect(field1.type.span.text, 'string');
      expect(field1.type.span.start.offset, 24);
      expect(field1.type.span.end.offset, 30);

      expect(field1.identifier.value, 'host');
      expect(field1.identifier.span.text, 'host');
      expect(field1.identifier.span.start.offset, 31);
      expect(field1.identifier.span.end.offset, 35);

      expect(field2.requirement!.value, 'optional');
      expect(field2.requirement!.span.text, 'optional');
      expect(field2.requirement!.span.start.offset, 37);
      expect(field2.requirement!.span.end.offset, 45);

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.text, 'i32');
      expect(field2.type.span.start.offset, 46);
      expect(field2.type.span.end.offset, 49);

      expect(field2.identifier.value, 'port');
      expect(field2.identifier.span.text, 'port');
      expect(field2.identifier.span.start.offset, 50);
      expect(field2.identifier.span.end.offset, 54);

      expect(field2.defaultValue, isNull);
    });

    test('should parse union with container types as fields', () {
      const source =
          'union Data '
          '{ '
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';

      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 79);

      expect(def.identifier.value, 'Data');
      expect(def.identifier.span.text, 'Data');
      expect(def.identifier.span.start.offset, 6);
      expect(def.identifier.span.end.offset, 10);

      final [FieldNode field1, FieldNode field2, FieldNode field3] = def.fields;

      expect(field1.type.span.text, 'list<string>');
      expect(field1.type.span.start.offset, 13);
      expect(field1.type.span.end.offset, 25);

      final field1Type = field1.type as ListTypeNode;
      expect(field1Type.elementType, isA<BaseTypeNode>());
      expect(field1Type.elementType.span.text, 'string');
      expect(field1Type.elementType.span.start.offset, 18);
      expect(field1Type.elementType.span.end.offset, 24);

      expect(field1.identifier.value, 'tags');
      expect(field1.identifier.span.text, 'tags');
      expect(field1.identifier.span.start.offset, 26);
      expect(field1.identifier.span.end.offset, 30);
      expect(field1.defaultValue, isNull);
      expect(field2.type.span.text, 'map<string, i32>');
      expect(field2.type.span.start.offset, 32);
      expect(field2.type.span.end.offset, 48);

      final field2Type = field2.type as MapTypeNode;
      expect(field2Type.keyType, isA<BaseTypeNode>());
      expect(field2Type.keyType.span.text, 'string');
      expect(field2Type.keyType.span.start.offset, 36);
      expect(field2Type.keyType.span.end.offset, 42);

      expect(field2Type.valueType, isA<BaseTypeNode>());
      expect(field2Type.valueType.span.text, 'i32');
      expect(field2Type.valueType.span.start.offset, 44);
      expect(field2Type.valueType.span.end.offset, 47);

      expect(field2.identifier.value, 'scores');
      expect(field2.identifier.span.text, 'scores');
      expect(field2.identifier.span.start.offset, 49);
      expect(field2.identifier.span.end.offset, 55);
      expect(field2.defaultValue, isNull);

      expect(field3.type.span.text, 'set<uuid>');
      expect(field3.type.span.start.offset, 57);
      expect(field3.type.span.end.offset, 66);

      final field3Type = field3.type as SetTypeNode;
      expect(field3Type.elementType, isA<BaseTypeNode>());
      expect(field3Type.elementType.span.text, 'uuid');
      expect(field3Type.elementType.span.start.offset, 61);
      expect(field3Type.elementType.span.end.offset, 65);

      expect(field3.identifier.value, 'uniqueIds');
      expect(field3.identifier.span.text, 'uniqueIds');
      expect(field3.identifier.span.start.offset, 67);
      expect(field3.identifier.span.end.offset, 76);

      expect(field3.defaultValue, isNull);
    });
  });

  group('UnionDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source =
          'union Data '
          '{'
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';

      const source2 =
          'union Data '
          '{'
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';
      final doc1 = parseAndGetAst(source);
      final doc2 = parseAndGetAst(source2);

      expect(doc1, equals(doc2));

      final def1 = doc1.definitions.first as UnionDefinitionNode;
      final def2 = doc2.definitions.first as UnionDefinitionNode;
      expect(def1, equals(def2));
      expect(def1.fields, equals(def2.fields));
    });

    test('should not be equal for different definitions', () {
      const source1 =
          'union Data '
          '{ '
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';
      const source2 =
          'union Data '
          '{ '
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<string> uniqueIds; '
          '}';
      final doc1 = parseAndGetAst(source1);
      final doc2 = parseAndGetAst(source2);

      expect(doc1, isNot(equals(doc2)));

      final def1 = doc1.definitions.first as UnionDefinitionNode;
      final def2 = doc2.definitions.first as UnionDefinitionNode;

      expect(def1, isNot(equals(def2)));
      expect(def1.fields, isNot(equals(def2.fields)));
    });
  });
}
