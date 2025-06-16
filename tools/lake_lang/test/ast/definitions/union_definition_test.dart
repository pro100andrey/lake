import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('UnionDefinition AST', () {
    test('should parse empty union', () {
      const source = 'union U {}';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as UnionDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 10);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 7);

      expect(def.fields, isEmpty);
    });

    test('should parse union with one field', () {
      const source = 'union U { i32 x }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as UnionDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 17);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 7);

      final [FieldNode field] = def.fields;

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.start, 10);
      expect(field.type.span.end, 13);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.start, 14);
      expect(field.identifier.span.end, 15);
    });

    test('should parse union with multiple fields', () {
      const source = 'union U { i32 x, string y }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 27);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 7);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.start, 10);
      expect(field1.type.span.end, 13);

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span.start, 14);
      expect(field1.identifier.span.end, 15);
      expect(field1.defaultValue, isNull);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.identifier.value, 'y');
    });

    test('should parse union with fieldId and default value', () {
      const source = 'union U { 1: i32 x = 42 }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 25);

      expect(def.identifier.value, 'U');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 7);

      final [FieldNode field] = def.fields;

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span.start, 10);
      expect(field.fieldId!.span.end, 11);

      expect((field.type as BaseTypeNode).value, 'i32');
      expect(field.type.span.start, 13);
      expect(field.type.span.end, 16);

      expect(field.identifier.value, 'x');
      expect(field.identifier.span.start, 17);
      expect(field.identifier.span.end, 18);

      final defaultValue = field.defaultValue! as IntConstantNode;

      expect(defaultValue.rawValue, '42');
      expect(defaultValue.value, 42);
      expect(defaultValue.span.start, 21);
      expect(defaultValue.span.end, 23);
    });

    test('should parse union with required fields', () {
      const source = 'union User { required i32 id; required string name; }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 53);

      expect(def.identifier.value, 'User');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 10);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span.start, 13);
      expect(field1.requirement!.span.end, 21);

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.start, 22);
      expect(field1.type.span.end, 25);

      expect(field1.identifier.value, 'id');
      expect(field1.identifier.span.start, 26);
      expect(field1.identifier.span.end, 28);

      expect(field1.defaultValue, isNull);

      expect(field2.requirement!.value, 'required');
      expect(field2.requirement!.span.start, 30);
      expect(field2.requirement!.span.end, 38);

      expect((field2.type as BaseTypeNode).value, 'string');
      expect(field2.type.span.start, 39);
      expect(field2.type.span.end, 45);

      expect(field2.identifier.value, 'name');
      expect(field2.identifier.span.start, 46);
      expect(field2.identifier.span.end, 50);

      expect(field2.defaultValue, isNull);
    });

    test('should parse union with optional fields', () {
      const source =
          'union Config { optional string host; optional i32 port; }';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 57);

      expect(def.identifier.value, 'Config');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 12);

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span.start, 15);
      expect(field1.requirement!.span.end, 23);

      expect((field1.type as BaseTypeNode).value, 'string');
      expect(field1.type.span.start, 24);
      expect(field1.type.span.end, 30);

      expect(field1.identifier.value, 'host');
      expect(field1.identifier.span.start, 31);
      expect(field1.identifier.span.end, 35);

      expect(field2.requirement!.value, 'optional');
      expect(field2.requirement!.span.start, 37);
      expect(field2.requirement!.span.end, 45);

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.start, 46);
      expect(field2.type.span.end, 49);

      expect(field2.identifier.value, 'port');
      expect(field2.identifier.span.start, 50);
      expect(field2.identifier.span.end, 54);

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

      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as UnionDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 79);

      expect(def.identifier.value, 'Data');
      expect(def.identifier.span.start, 6);
      expect(def.identifier.span.end, 10);

      final [FieldNode field1, FieldNode field2, FieldNode field3] = def.fields;

      expect(field1.type.span.start, 13);
      expect(field1.type.span.end, 25);

      final field1Type = field1.type as ListTypeNode;
      expect(field1Type.elementType, isA<BaseTypeNode>());
      expect(field1Type.elementType.span.start, 18);
      expect(field1Type.elementType.span.end, 24);

      expect(field1.identifier.value, 'tags');
      expect(field1.identifier.span.start, 26);
      expect(field1.identifier.span.end, 30);
      expect(field1.defaultValue, isNull);
      expect(field2.type.span.start, 32);
      expect(field2.type.span.end, 48);

      final field2Type = field2.type as MapTypeNode;
      expect(field2Type.keyType, isA<BaseTypeNode>());
      expect(field2Type.keyType.span.start, 36);
      expect(field2Type.keyType.span.end, 42);

      expect(field2Type.valueType, isA<BaseTypeNode>());
      expect(field2Type.valueType.span.start, 44);
      expect(field2Type.valueType.span.end, 47);

      expect(field2.identifier.value, 'scores');
      expect(field2.identifier.span.start, 49);
      expect(field2.identifier.span.end, 55);
      expect(field2.defaultValue, isNull);

      expect(field3.type.span.start, 57);
      expect(field3.type.span.end, 66);

      final field3Type = field3.type as SetTypeNode;
      expect(field3Type.elementType, isA<BaseTypeNode>());
      expect(field3Type.elementType.span.start, 61);
      expect(field3Type.elementType.span.end, 65);

      expect(field3.identifier.value, 'uniqueIds');
      expect(field3.identifier.span.start, 67);
      expect(field3.identifier.span.end, 76);

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
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

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
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final def1 = doc1.definitions.first as UnionDefinitionNode;
      final def2 = doc2.definitions.first as UnionDefinitionNode;

      expect(def1, isNot(equals(def2)));
      expect(def1.fields, isNot(equals(def2.fields)));
    });
  });
}
