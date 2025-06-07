import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ListType AST', () {
    test('should parse list of base type', () {
      const source = 'struct S { list<i32> numbers; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;

      final field = def.fields[0];
      expect(field.type, isA<ListTypeNode>());
      final listType = field.type as ListTypeNode;

      expect(listType.elementType, isA<BaseTypeNode>());
      expect((listType.elementType as BaseTypeNode).value, 'i32');
      expect(listType.elementType.span!.text, 'i32');
      expect(listType.elementType.span!.start.offset, 16);
      expect(listType.elementType.span!.end.offset, 19);

      expect(listType.span!.text, 'list<i32>');
      expect(listType.span!.start.offset, 11);
      expect(listType.span!.end.offset, 20);

      expect(field.identifier.value, 'numbers');
      expect(field.identifier.span!.text, 'numbers');
      expect(field.identifier.span!.start.offset, 21);
      expect(field.identifier.span!.end.offset, 28);
    });

    test('should parse list of custom type', () {
      const source = 'struct S { list<CustomType> items; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;

      final field = def.fields[0];
      expect(field.type, isA<ListTypeNode>());
      expect(field.type.span!.text, 'list<CustomType>');
      expect(field.type.span!.start.offset, 11);
      expect(field.type.span!.end.offset, 27);

      final listType = field.type as ListTypeNode;
      expect(listType.elementType, isA<CustomTypeNode>());
      expect((listType.elementType as CustomTypeNode).value, 'CustomType');
      expect(listType.elementType.span!.text, 'CustomType');
      expect(listType.elementType.span!.start.offset, 16);
      expect(listType.elementType.span!.end.offset, 26);

      expect(listType.span!.text, 'list<CustomType>');
      expect(listType.span!.start.offset, 11);
      expect(listType.span!.end.offset, 27);
    });

    test('should parse list of nested container type (list of lists)', () {
      const source = 'struct S { list<list<i32>> nestedLists; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as StructDefinitionNode;

      expect(def.fields[0].type, isA<ListTypeNode>());
      final listType = def.fields[0].type as ListTypeNode;

      expect(listType.elementType, isA<ListTypeNode>());
      expect(listType.elementType.span!.text, 'list<i32>');
      expect(listType.elementType.span!.start.offset, 16);
      expect(listType.elementType.span!.end.offset, 25);

      final nestedType = listType.elementType as ListTypeNode;
      expect((nestedType.elementType as BaseTypeNode).value, 'i32');
      expect(nestedType.elementType.span!.text, 'i32');
      expect(nestedType.elementType.span!.start.offset, 21);
      expect(nestedType.elementType.span!.end.offset, 24);

      expect(nestedType.span!.text, 'list<i32>');
      expect(nestedType.span!.start.offset, 16);
      expect(nestedType.span!.end.offset, 25);

      expect(listType.span!.text, 'list<list<i32>>');
      expect(listType.span!.start.offset, 11);
      expect(listType.span!.end.offset, 26);
    });

    test('should parse list of map type', () {
      const source = 'struct S { list<map<string, i32>> data; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.fields[0].type, isA<ListTypeNode>());

      final listType = def.fields[0].type as ListTypeNode;
      expect(listType.elementType, isA<MapTypeNode>());
      expect(listType.elementType.span!.text, 'map<string, i32>');
      expect(listType.elementType.span!.start.offset, 16);
      expect(listType.elementType.span!.end.offset, 32);

      final map = listType.elementType as MapTypeNode;
      expect((map.keyType as BaseTypeNode).value, 'string');
      expect(map.keyType.span!.text, 'string');
      expect(map.keyType.span!.start.offset, 20);
      expect(map.keyType.span!.end.offset, 26);

      expect(map.valueType, isA<BaseTypeNode>());
      expect((map.valueType as BaseTypeNode).value, 'i32');
      expect(map.valueType.span!.text, 'i32');
      expect(map.valueType.span!.start.offset, 28);
      expect(map.valueType.span!.end.offset, 31);
    });

    test('should parse list of set type', () {
      const source = 'struct S { list<set<string>> tags; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect(def.fields[0].type, isA<ListTypeNode>());

      final listType = def.fields[0].type as ListTypeNode;
      expect(listType.elementType, isA<SetTypeNode>());
      expect(listType.elementType.span!.text, 'set<string>');
      expect(listType.elementType.span!.start.offset, 16);
      expect(listType.elementType.span!.end.offset, 27);

      final setType = listType.elementType as SetTypeNode;
      expect((setType.elementType as BaseTypeNode).value, 'string');
      expect(setType.elementType.span!.text, 'string');
      expect(setType.elementType.span!.start.offset, 20);
      expect(setType.elementType.span!.end.offset, 26);

      expect(listType.span!.text, 'list<set<string>>');
      expect(listType.span!.start.offset, 11);
      expect(listType.span!.end.offset, 28);
    });
  });
}
