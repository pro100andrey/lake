import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ListType AST', () {
    test('should parse list of base type', () {
      const source = 'list<i32>';
      final doc = parseAstFromString('struct S { $source numbers; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as ListTypeNode;
      final elementType = fieldType.elementType as BaseTypeNode;

      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 20);

      expect(elementType.value, 'i32');
      expect(elementType.span.start, 16);
      expect(elementType.span.end, 19);
    });

    test('should parse list of custom type', () {
      const source = 'list<CustomType>';
      final doc = parseAstFromString('struct S { $source items; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as ListTypeNode;
      final elementType = fieldType.elementType as CustomTypeNode;

      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 27);

      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 27);

      expect(elementType.value, 'CustomType');
      expect(elementType.span.start, 16);
      expect(elementType.span.end, 26);
    });

    test('should parse list of nested container type (list of lists)', () {
      const source = 'list<list<i32>>';
      final doc = parseAstFromString('struct S { $source nestedLists; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 26);

      final elementType = fieldType.elementType as ListTypeNode;
      expect(elementType.span.start, 16);
      expect(elementType.span.end, 25);

      final nestedType = elementType.elementType as BaseTypeNode;
      expect(nestedType.value, 'i32');
      expect(nestedType.span.start, 21);
      expect(nestedType.span.end, 24);
    });

    test('should parse list of map type', () {
      const source = 'list<map<string, i32>>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 33);

      final elementType = fieldType.elementType as MapTypeNode;
      expect(elementType.span.start, 16);
      expect(elementType.span.end, 32);

      expect(elementType.keyType, isA<BaseTypeNode>());
      expect(elementType.keyType.span.start, 20);
      expect(elementType.keyType.span.end, 26);

      expect(elementType.valueType, isA<BaseTypeNode>());
      expect(elementType.valueType.span.start, 28);
      expect(elementType.valueType.span.end, 31);
    });

    test('should parse list of set type', () {
      const source = 'list<set<string>>';
      final doc = parseAstFromString('struct S { $source tags; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 28);

      final elementType = fieldType.elementType as SetTypeNode;
      expect(elementType.span.start, 16);
      expect(elementType.span.end, 27);

      expect(elementType.elementType, isA<BaseTypeNode>());
      expect(elementType.elementType.span.start, 20);
      expect(elementType.elementType.span.end, 26);
    });
  });

  group('ListType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'list<CustomType>';
      final doc1 = parseAstFromString('struct S { $source x; }');
      final doc2 = parseAstFromString('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAstFromString('struct S { list<CustomType> x; }');
      final doc2 = parseAstFromString('struct S { list<AnotherType> y; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
