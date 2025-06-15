import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('TypedefDefinition AST', () {
    test('should parse simple typedef with base type', () {
      const source = 'typedef i32 MyInt;';
      final doc = parseAndGetAst(source);
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 18);

      expect((def.type as BaseTypeNode).value, 'i32');
      expect(def.type.span.text, 'i32');
      expect(def.type.span.start.offset, 8);
      expect(def.type.span.end.offset, 11);

      expect(def.identifier.value, 'MyInt');
      expect(def.identifier.span.text, 'MyInt');
      expect(def.identifier.span.start.offset, 12);
      expect(def.identifier.span.end.offset, 17);
    });

    test('should parse typedef with List type', () {
      const source = 'typedef list<string> StringList;';
      final doc = parseAndGetAst(source);
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 32);

      final type = def.type as ListTypeNode;
      expect(type.span.text, 'list<string>');
      expect(type.span.start.offset, 8);
      expect(type.span.end.offset, 20);

      final itemType = type.elementType as BaseTypeNode;
      expect(itemType.value, 'string');
      expect(itemType.span.text, 'string');
      expect(itemType.span.start.offset, 13);
      expect(itemType.span.end.offset, 19);

      expect(def.identifier.value, 'StringList');
      expect(def.identifier.span.text, 'StringList');
      expect(def.identifier.span.start.offset, 21);
      expect(def.identifier.span.end.offset, 31);
    });

    test('should parse typedef with Map type', () {
      const source = 'typedef map<string, i32> BaseMapType;';
      final doc = parseAndGetAst(source);
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 37);

      final type = def.type as MapTypeNode;
      expect(type.span.text, 'map<string, i32>');
      expect(type.span.start.offset, 8);
      expect(type.span.end.offset, 24);

      final keyType = type.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.text, 'string');
      expect(keyType.span.start.offset, 12);
      expect(keyType.span.end.offset, 18);

      final valueType = type.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span.text, 'i32');
      expect(valueType.span.start.offset, 20);
      expect(valueType.span.end.offset, 23);

      expect(def.identifier.value, 'BaseMapType');
      expect(def.identifier.span.text, 'BaseMapType');
      expect(def.identifier.span.start.offset, 25);
      expect(def.identifier.span.end.offset, 36);
    });

    test('should parse typedef with Set type', () {
      const source = 'typedef set<binary> BinarySet;';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 30);

      final type = def.type as SetTypeNode;
      expect(type.span.text, 'set<binary>');
      expect(type.span.start.offset, 8);
      expect(type.span.end.offset, 19);

      final itemType = type.elementType as BaseTypeNode;
      expect(itemType.value, 'binary');
      expect(itemType.span.text, 'binary');
      expect(itemType.span.start.offset, 12);
      expect(itemType.span.end.offset, 18);

      expect(def.identifier.value, 'BinarySet');
      expect(def.identifier.span.text, 'BinarySet');
      expect(def.identifier.span.start.offset, 20);
      expect(def.identifier.span.end.offset, 29);
    });
  });

  group('TypedefDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source = 'typedef i32 MyInt;';
      const source2 = 'typedef i32 MyInt;';
      final doc1 = parseAndGetAst(source);
      final doc2 = parseAndGetAst(source2);

      expect(doc1, equals(doc2));

      final def1 = doc1.definitions.first as TypedefDefinitionNode;
      final def2 = doc2.definitions.first as TypedefDefinitionNode;

      expect(def1, equals(def2));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'typedef i32 MyInt;';
      const source2 = 'typedef i32 MyString;';
      final doc1 = parseAndGetAst(source1);
      final doc2 = parseAndGetAst(source2);

      expect(doc1, isNot(equals(doc2)));

      final def1 = doc1.definitions.first as TypedefDefinitionNode;
      final def2 = doc2.definitions.first as TypedefDefinitionNode;

      expect(def1, isNot(equals(def2)));
    });
  });
}
