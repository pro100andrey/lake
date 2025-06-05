import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ConstDefinition AST', () {
    test('should parse int constant', () {
      const source = 'const i32 myInt = 42;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;

      expect(def.identifier.value, 'myInt');
      expect((def.type as BaseTypeNode).type, 'i32');
      expect((def.value as IntConstantNode).value, '42');

      expect(def.span!.text, 'const i32 myInt = 42;');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 21);

      expect(def.identifier.span!.text, 'myInt');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 15);

      expect(def.type.span!.text, 'i32');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 9);

      expect(def.value.span!.text, '42');
      expect(def.value.span!.start.offset, 18);
      expect(def.value.span!.end.offset, 20);
    });

    test('should parse string constant', () {
      const source = 'const string myString = "Hello, World!";';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;

      expect(def.identifier.value, 'myString');
      expect((def.type as BaseTypeNode).type, 'string');
      expect((def.value as LiteralNode).value, '"Hello, World!"');

      expect(def.span!.text, 'const string myString = "Hello, World!";');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 40);

      expect(def.type.span!.text, 'string');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 12);

      expect(def.identifier.span!.text, 'myString');
      expect(def.identifier.span!.start.offset, 13);
      expect(def.identifier.span!.end.offset, 21);

      expect(def.value.span!.text, '"Hello, World!"');
      expect(def.value.span!.start.offset, 24);
      expect(def.value.span!.end.offset, 39);
    });

    test('should parse boolean constant', () {
      const source = 'const bool myBool = true;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;

      expect(def.identifier.value, 'myBool');
      expect((def.type as BaseTypeNode).type, 'bool');
      expect((def.value as IdentifierNode).value, 'true');

      expect(def.span!.text, 'const bool myBool = true;');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 25);

      expect(def.type.span!.text, 'bool');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 10);

      expect(def.identifier.span!.text, 'myBool');
      expect(def.identifier.span!.start.offset, 11);
      expect(def.identifier.span!.end.offset, 17);

      expect(def.value.span!.text, 'true');
      expect(def.value.span!.start.offset, 20);
      expect(def.value.span!.end.offset, 24);
    });

    test('should parse double constant', () {
      const source = 'const double myDouble = 3.14';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;

      expect(def.identifier.value, 'myDouble');
      expect((def.type as BaseTypeNode).type, 'double');
      expect((def.value as DoubleConstantNode).value, '3.14');

      expect(def.span!.text, 'const double myDouble = 3.14');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 28);

      expect(def.type.span!.text, 'double');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 12);

      expect(def.identifier.span!.text, 'myDouble');
      expect(def.identifier.span!.start.offset, 13);
      expect(def.identifier.span!.end.offset, 21);

      expect(def.value.span!.text, '3.14');
      expect(def.value.span!.start.offset, 24);
      expect(def.value.span!.end.offset, 28);
    });

    // array
    test('should parse array constant', () {
      const source = 'const list<i32> myArray = [1, 2, 3];';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions[0] as ConstDefinitionNode;
      final type = def.type as ListTypeNode;
      final elementType = type.elementType as BaseTypeNode;
      final elements = (def.value as ConstListNode).elements
          .cast<IntConstantNode>();

      final e0 = elements[0];
      final e1 = elements[1];
      final e2 = elements[2];

      expect(def.identifier.value, 'myArray');
      expect(elementType.type, 'i32');

      expect(e0.value, '1');
      expect(e0.span!.text, '1');
      expect(e0.span!.start.offset, 27);
      expect(e0.span!.end.offset, 28);

      expect(e1.value, '2');
      expect(e1.span!.text, '2');
      expect(e1.span!.start.offset, 30);
      expect(e1.span!.end.offset, 31);

      expect(e2.value, '3');
      expect(e2.span!.text, '3');
      expect(e2.span!.start.offset, 33);
      expect(e2.span!.end.offset, 34);

      expect(def.span!.text, 'const list<i32> myArray = [1, 2, 3];');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 36);

      expect(elementType.span!.text, 'i32');
      expect(elementType.span!.start.offset, 11);
      expect(elementType.span!.end.offset, 14);

      expect(type.span!.text, 'list<i32>');
      expect(type.span!.start.offset, 6);
      expect(type.span!.end.offset, 15);

      expect(def.identifier.span!.text, 'myArray');
      expect(def.identifier.span!.start.offset, 16);
      expect(def.identifier.span!.end.offset, 23);

      expect(def.value.span!.text, '[1, 2, 3]');
      expect(def.value.span!.start.offset, 26);
      expect(def.value.span!.end.offset, 35);
    });

    test('should parse map constant', () {
      const source = 'const map<string, i32> myMap = {"a": 1, "b": 2};';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions[0] as ConstDefinitionNode;
      final type = def.type as MapTypeNode;
      final keyType = type.keyType as BaseTypeNode;
      final valueType = type.valueType as BaseTypeNode;
      final entries = (def.value as ConstMapNode).entries.cast<MapEntry>();

      final entry0 = entries[0];
      final entry1 = entries[1];

      final k1 = entry0.key as LiteralNode;
      final v1 = entry0.value as IntConstantNode;

      final k2 = entry1.key as LiteralNode;
      final v2 = entry1.value as IntConstantNode;

      expect(k1.value, '"a"');
      expect(k1.span!.text, '"a"');
      expect(k1.span!.start.offset, 32);
      expect(k1.span!.end.offset, 35);

      expect(v1.value, '1');
      expect(v1.span!.text, '1');
      expect(v1.span!.start.offset, 37);
      expect(v1.span!.end.offset, 38);

      expect(k2.value, '"b"');
      expect(k2.span!.text, '"b"');
      expect(k2.span!.start.offset, 40);
      expect(k2.span!.end.offset, 43);

      expect(v2.value, '2');
      expect(v2.span!.text, '2');
      expect(v2.span!.start.offset, 45);
      expect(v2.span!.end.offset, 46);

      expect(def.identifier.value, 'myMap');
      expect(keyType.type, 'string');
      expect(valueType.type, 'i32');

      expect(
        def.span!.text,
        'const map<string, i32> myMap = {"a": 1, "b": 2};',
      );
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 48);

      expect(keyType.span!.text, 'string');
      expect(keyType.span!.start.offset, 10);
      expect(keyType.span!.end.offset, 16);

      expect(valueType.span!.text, 'i32');
      expect(valueType.span!.start.offset, 18);
      expect(valueType.span!.end.offset, 21);

      expect(type.span!.text, 'map<string, i32>');
      expect(type.span!.start.offset, 6);
      expect(type.span!.end.offset, 22);

      expect(def.identifier.span!.text, 'myMap');
      expect(def.identifier.span!.start.offset, 23);
      expect(def.identifier.span!.end.offset, 28);

      expect(def.value.span!.text, '{"a": 1, "b": 2}');
      expect(def.value.span!.start.offset, 31);
      expect(def.value.span!.end.offset, 47);
    });
  });
}
