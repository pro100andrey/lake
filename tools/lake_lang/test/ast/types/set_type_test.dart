import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('SetType AST', () {
    test('should parse set of base type', () {
      const source = 'set<string>';
      final doc = parseAndGetAst('struct S { $source tags; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as SetTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 22);

      final elementType = fieldType.elementType as BaseTypeNode;
      expect(elementType.value, 'string');
      expect(elementType.span.text, 'string');
      expect(elementType.span.start.offset, 15);
      expect(elementType.span.end.offset, 21);
    });

    test('should parse set of custom type', () {
      const source = 'set<UniqueId>';
      final doc = parseAndGetAst('struct S { $source ids; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];
      final fieldType = field.type as SetTypeNode;

      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 24);

      final elementType = fieldType.elementType as CustomTypeNode;
      expect(elementType.value, 'UniqueId');
      expect(elementType.span.text, 'UniqueId');
      expect(elementType.span.start.offset, 15);
      expect(elementType.span.end.offset, 23);
    });

    test('should parse set of nested container type (set of lists)', () {
      const source = 'set<list<i32>>';
      final doc = parseAndGetAst('struct S { $source dataSets; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as SetTypeNode;
      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 25);

      final elementType = fieldType.elementType as ListTypeNode;
      expect(elementType.span.text, 'list<i32>');
      expect(elementType.span.start.offset, 15);
      expect(elementType.span.end.offset, 24);

      final nestedElementType = elementType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'i32');
      expect(nestedElementType.span.text, 'i32');
      expect(nestedElementType.span.start.offset, 20);
      expect(nestedElementType.span.end.offset, 23);
    });

    test('should parse set of map type', () {
      const source = 'set<map<string, i32>>';
      final doc = parseAndGetAst('struct S { $source mapSets; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as SetTypeNode;
      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 32);

      final elementType = fieldType.elementType as MapTypeNode;
      expect(elementType.span.text, 'map<string, i32>');
      expect(elementType.span.start.offset, 15);
      expect(elementType.span.end.offset, 31);

      expect(elementType.keyType, isA<BaseTypeNode>());
      expect(elementType.keyType.span.text, 'string');
      expect(elementType.keyType.span.start.offset, 19);
      expect(elementType.keyType.span.end.offset, 25);

      expect(elementType.valueType, isA<BaseTypeNode>());
      expect(elementType.valueType.span.text, 'i32');
      expect(elementType.valueType.span.start.offset, 27);
      expect(elementType.valueType.span.end.offset, 30);
    });

    test('should parse set of set type (nested sets)', () {
      const source = 'set<set<bool>>';
      final doc = parseAndGetAst('struct S { $source boolSets; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final field = def.fields[0];

      final fieldType = field.type as SetTypeNode;
      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 11);
      expect(fieldType.span.end.offset, 25);

      final elementType = fieldType.elementType as SetTypeNode;
      expect(elementType.span.text, 'set<bool>');
      expect(elementType.span.start.offset, 15);
      expect(elementType.span.end.offset, 24);

      final nestedElementType = elementType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'bool');
      expect(nestedElementType.span.text, 'bool');
      expect(nestedElementType.span.start.offset, 19);
      expect(nestedElementType.span.end.offset, 23);
    });
  });

  group('SetType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'set<CustomType>';
      final doc1 = parseAndGetAst('struct S { $source x; }');
      final doc2 = parseAndGetAst('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAndGetAst('struct S { set<CustomType> x; }');
      final doc2 = parseAndGetAst('struct S { set<AnotherType> x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
