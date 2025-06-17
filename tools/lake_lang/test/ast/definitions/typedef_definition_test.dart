import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('TypedefDefinition AST', () {
    test('should parse simple typedef with base type', () {
      const source = 'typedef i32 MyInt;';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<TypedefDefinitionNode>();

      expect(def.span, hasSpan(0, 18));

      expect(def.type.cast<BaseTypeNode>().value, 'i32');
      expect(def.type.span, hasSpan(8, 11));

      expect(def.identifier.value, 'MyInt');
      expect(def.identifier.span, hasSpan(12, 17));
    });

    test('should parse typedef with List type', () {
      const source = 'typedef list<string> StringList;';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<TypedefDefinitionNode>();

      expect(def.span, hasSpan(0, 32));

      final type = def.type.cast<ListTypeNode>();
      expect(type.span, hasSpan(8, 20));

      final itemType = type.elementType.cast<BaseTypeNode>();
      expect(itemType.value, 'string');
      expect(itemType.span, hasSpan(13, 19));

      expect(def.identifier.value, 'StringList');
      expect(def.identifier.span, hasSpan(21, 31));
    });

    test('should parse typedef with Map type', () {
      const source = 'typedef map<string, i32> BaseMapType;';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<TypedefDefinitionNode>();

      expect(def.span, hasSpan(0, 37));

      final type = def.type.cast<MapTypeNode>();
      expect(type.span, hasSpan(8, 24));

      final keyType = type.keyType.cast<BaseTypeNode>();
      expect(keyType.value, 'string');
      expect(keyType.span, hasSpan(12, 18));

      final valueType = type.valueType.cast<BaseTypeNode>();
      expect(valueType.value, 'i32');
      expect(valueType.span, hasSpan(20, 23));

      expect(def.identifier.value, 'BaseMapType');
      expect(def.identifier.span, hasSpan(25, 36));
    });

    test('should parse typedef with Set type', () {
      const source = 'typedef set<binary> BinarySet;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<TypedefDefinitionNode>();

      expect(def.span, hasSpan(0, 30));

      final type = def.type.cast<SetTypeNode>();
      expect(type.span, hasSpan(8, 19));

      final itemType = type.elementType.cast<BaseTypeNode>();
      expect(itemType.value, 'binary');
      expect(itemType.span, hasSpan(12, 18));

      expect(def.identifier.value, 'BinarySet');
      expect(def.identifier.span, hasSpan(20, 29));
    });
  });

  group('TypedefDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source = 'typedef i32 MyInt;';
      const source2 = 'typedef i32 MyInt;';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final def1 = doc1.definitions.first.cast<TypedefDefinitionNode>();
      final def2 = doc2.definitions.first.cast<TypedefDefinitionNode>();

      expect(def1, equals(def2));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'typedef i32 MyInt;';
      const source2 = 'typedef i32 MyString;';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final def1 = doc1.definitions.first.cast<TypedefDefinitionNode>();
      final def2 = doc2.definitions.first.cast<TypedefDefinitionNode>();

      expect(def1, isNot(equals(def2)));
    });
  });
}
