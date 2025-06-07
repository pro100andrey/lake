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

      final field = def.fields[0];
      expect(field.type, isA<ListTypeNode>());
      final listType = field.type as ListTypeNode;

      expect(listType.elementType, isA<ListTypeNode>());
      final nestedListType = listType.elementType as ListTypeNode;

      expect(nestedListType.elementType, isA<BaseTypeNode>());
      expect((nestedListType.elementType as BaseTypeNode).value, 'i32');
      expect(nestedListType.elementType.span!.text, 'i32');
      expect(nestedListType.elementType.span!.start.offset, 21);
      expect(nestedListType.elementType.span!.end.offset, 24);

      expect(nestedListType.span!.text, 'list<i32>');
      expect(nestedListType.span!.start.offset, 16);
      expect(nestedListType.span!.end.offset, 25);

      expect(listType.span!.text, 'list<list<i32>>');
      expect(listType.span!.start.offset, 11);
      expect(listType.span!.end.offset, 26);
    });
  });
}
