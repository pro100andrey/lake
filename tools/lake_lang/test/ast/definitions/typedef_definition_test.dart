import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('TypedefDefinition AST', () {
    test('should parse simple typedef with base type', () {
      const source = 'typedef i32 MyInt;';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 18);

      expect((def.type as BaseTypeNode).value, 'i32');
      expect(def.type.span.start, 8);
      expect(def.type.span.end, 11);

      expect(def.identifier.value, 'MyInt');
      expect(def.identifier.span.start, 12);
      expect(def.identifier.span.end, 17);
    });

    test('should parse typedef with List type', () {
      const source = 'typedef list<string> StringList;';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 32);

      final type = def.type as ListTypeNode;
      expect(type.span.start, 8);
      expect(type.span.end, 20);

      final itemType = type.elementType as BaseTypeNode;
      expect(itemType.value, 'string');
      expect(itemType.span.start, 13);
      expect(itemType.span.end, 19);

      expect(def.identifier.value, 'StringList');
      expect(def.identifier.span.start, 21);
      expect(def.identifier.span.end, 31);
    });

    test('should parse typedef with Map type', () {
      const source = 'typedef map<string, i32> BaseMapType;';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 37);

      final type = def.type as MapTypeNode;
      expect(type.span.start, 8);
      expect(type.span.end, 24);

      final keyType = type.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.start, 12);
      expect(keyType.span.end, 18);

      final valueType = type.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span.start, 20);
      expect(valueType.span.end, 23);

      expect(def.identifier.value, 'BaseMapType');
      expect(def.identifier.span.start, 25);
      expect(def.identifier.span.end, 36);
    });

    test('should parse typedef with Set type', () {
      const source = 'typedef set<binary> BinarySet;';
      final doc = parseAstFromString(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 30);

      final type = def.type as SetTypeNode;
      expect(type.span.start, 8);
      expect(type.span.end, 19);

      final itemType = type.elementType as BaseTypeNode;
      expect(itemType.value, 'binary');
      expect(itemType.span.start, 12);
      expect(itemType.span.end, 18);

      expect(def.identifier.value, 'BinarySet');
      expect(def.identifier.span.start, 20);
      expect(def.identifier.span.end, 29);
    });
  });

  group('TypedefDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source = 'typedef i32 MyInt;';
      const source2 = 'typedef i32 MyInt;';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final def1 = doc1.definitions.first as TypedefDefinitionNode;
      final def2 = doc2.definitions.first as TypedefDefinitionNode;

      expect(def1, equals(def2));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'typedef i32 MyInt;';
      const source2 = 'typedef i32 MyString;';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final def1 = doc1.definitions.first as TypedefDefinitionNode;
      final def2 = doc2.definitions.first as TypedefDefinitionNode;

      expect(def1, isNot(equals(def2)));
    });
  });
}
