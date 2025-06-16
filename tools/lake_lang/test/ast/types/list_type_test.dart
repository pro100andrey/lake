import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('ListType AST', () {
    test('should parse list of base type', () {
      const source = 'list<i32>';
      final doc = parseAstFromString('struct S { $source numbers; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span, hasSpan(11, 20));

      final elementType = fieldType.elementType as BaseTypeNode;
      expect(elementType.value, 'i32');
      expect(elementType.span, hasSpan(16, 19));
    });

    test('should parse list of custom type', () {
      const source = 'list<CustomType>';
      final doc = parseAstFromString('struct S { $source items; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span, hasSpan(11, 27));

      final elementType = fieldType.elementType as CustomTypeNode;
      expect(elementType.value, 'CustomType');
      expect(elementType.span, hasSpan(16, 26));
    });

    test('should parse list of nested container type (list of lists)', () {
      const source = 'list<list<i32>>';
      final doc = parseAstFromString('struct S { $source nestedLists; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span, hasSpan(11, 26));

      final elementType = fieldType.elementType as ListTypeNode;
      expect(elementType.span, hasSpan(16, 25));

      final nestedType = elementType.elementType as BaseTypeNode;
      expect(nestedType.value, 'i32');
      expect(nestedType.span, hasSpan(21, 24));
    });

    test('should parse list of map type', () {
      const source = 'list<map<string, i32>>';
      final doc = parseAstFromString('struct S { $source data; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span, hasSpan(11, 33));

      final elementType = fieldType.elementType as MapTypeNode;
      expect(elementType.span, hasSpan(16, 32));

      expect(elementType.keyType, isA<BaseTypeNode>());
      expect(elementType.keyType.span, hasSpan(20, 26));

      expect(elementType.valueType, isA<BaseTypeNode>());
      expect(elementType.valueType.span, hasSpan(28, 31));
    });

    test('should parse list of set type', () {
      const source = 'list<set<string>>';
      final doc = parseAstFromString('struct S { $source tags; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as ListTypeNode;
      expect(fieldType.span, hasSpan(11, 28));

      final elementType = fieldType.elementType as SetTypeNode;
      expect(elementType.span, hasSpan(16, 27));

      expect(elementType.elementType, isA<BaseTypeNode>());
      expect(elementType.elementType.span, hasSpan(20, 26));
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
