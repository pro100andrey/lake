import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('TypedefDefinition AST', () {
    test('should parse simple typedef with base type', () {
      const source = 'typedef i32 MyInt;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as TypedefDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 18);

      expect((def.type as BaseTypeNode).type, 'i32');
      expect(def.type.span!.text, 'i32');
      expect(def.type.span!.start.offset, 8);
      expect(def.type.span!.end.offset, 11);

      expect(def.identifier.value, 'MyInt');
      expect(def.identifier.span!.text, 'MyInt');
      expect(def.identifier.span!.start.offset, 12);
      expect(def.identifier.span!.end.offset, 17);
    });

    test('should parse typedef with Map type', () {
      const source = 'typedef map<string, i32> BaseMapType;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 37);

      final type = def.type as MapTypeNode;
      expect(type.span!.text, 'map<string, i32>');
      expect(type.span!.start.offset, 8);
      expect(type.span!.end.offset, 24);

      final keyType = type.keyType as BaseTypeNode;
      expect(keyType.type, 'string');
      expect(keyType.span!.text, 'string');
      expect(keyType.span!.start.offset, 12);
      expect(keyType.span!.end.offset, 18);

      final valueType = type.valueType as BaseTypeNode;
      expect(valueType.type, 'i32');
      expect(valueType.span!.text, 'i32');
      expect(valueType.span!.start.offset, 20);
      expect(valueType.span!.end.offset, 23);

      expect(def.identifier.value, 'BaseMapType');
      expect(def.identifier.span!.text, 'BaseMapType');
      expect(def.identifier.span!.start.offset, 25);
      expect(def.identifier.span!.end.offset, 36);
    });

    test('should parse typedef with Set type', () {
      const source = 'typedef set<binary> BinarySet;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as TypedefDefinitionNode;

      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 30);

      final type = def.type as SetTypeNode;
      expect(type.span!.text, 'set<binary>');
      expect(type.span!.start.offset, 8);
      expect(type.span!.end.offset, 19);

      final itemType = type.itemType as BaseTypeNode;
      expect(itemType.type, 'binary');
      expect(itemType.span!.text, 'binary');
      expect(itemType.span!.start.offset, 12);
      expect(itemType.span!.end.offset, 18);

      expect(def.identifier.value, 'BinarySet');
      expect(def.identifier.span!.text, 'BinarySet');
      expect(def.identifier.span!.start.offset, 20);
      expect(def.identifier.span!.end.offset, 29);
    });
  });
}
