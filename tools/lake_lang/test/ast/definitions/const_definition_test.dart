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
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 21);

      expect((def.type as BaseTypeNode).type, 'i32');
      expect(def.type.span!.text, 'i32');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 9);

      expect(def.identifier.value, 'myInt');
      expect(def.identifier.span!.text, 'myInt');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 15);

      expect((def.value as IntConstantNode).value, '42');
      expect(def.value.span!.text, '42');
      expect(def.value.span!.start.offset, 18);
      expect(def.value.span!.end.offset, 20);
    });

    test('should parse string constant', () {
      const source = 'const string myString = "Hello, World!";';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 40);

      expect((def.type as BaseTypeNode).type, 'string');
      expect(def.type.span!.text, 'string');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 12);

      expect(def.identifier.value, 'myString');
      expect(def.identifier.span!.text, 'myString');
      expect(def.identifier.span!.start.offset, 13);
      expect(def.identifier.span!.end.offset, 21);

      expect((def.value as LiteralNode).value, '"Hello, World!"');
      expect(def.value.span!.text, '"Hello, World!"');
      expect(def.value.span!.start.offset, 24);
      expect(def.value.span!.end.offset, 39);
    });

    test('should parse boolean constant', () {
      const source = 'const bool myBool = true;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 25);

      expect((def.type as BaseTypeNode).type, 'bool');
      expect(def.type.span!.text, 'bool');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 10);

      expect(def.identifier.value, 'myBool');
      expect(def.identifier.span!.text, 'myBool');
      expect(def.identifier.span!.start.offset, 11);
      expect(def.identifier.span!.end.offset, 17);

      expect((def.value as IdentifierNode).value, 'true');
      expect(def.value.span!.text, 'true');
      expect(def.value.span!.start.offset, 20);
      expect(def.value.span!.end.offset, 24);
    });

    test('should parse double constant', () {
      const source = 'const double myDouble = 3.14';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 28);

      expect((def.type as BaseTypeNode).type, 'double');
      expect(def.type.span!.text, 'double');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 12);

      expect(def.identifier.value, 'myDouble');
      expect(def.identifier.span!.text, 'myDouble');
      expect(def.identifier.span!.start.offset, 13);
      expect(def.identifier.span!.end.offset, 21);

      expect((def.value as DoubleConstantNode).value, '3.14');
      expect(def.value.span!.text, '3.14');
      expect(def.value.span!.start.offset, 24);
      expect(def.value.span!.end.offset, 28);
    });

    test('should parse array constant', () {
      const source = 'const list<i32> myArray = [1, 2, 3];';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 36);

      final type = def.type as ListTypeNode;
      expect(type.span!.text, 'list<i32>');
      expect(type.span!.start.offset, 6);
      expect(type.span!.end.offset, 15);

      final elementType = type.elementType as BaseTypeNode;
      expect(elementType.type, 'i32');
      expect(elementType.span!.text, 'i32');
      expect(elementType.span!.start.offset, 11);
      expect(elementType.span!.end.offset, 14);

      expect(def.identifier.value, 'myArray');
      expect(def.identifier.span!.text, 'myArray');
      expect(def.identifier.span!.start.offset, 16);
      expect(def.identifier.span!.end.offset, 23);

      expect(def.value.span!.text, '[1, 2, 3]');
      expect(def.value.span!.start.offset, 26);
      expect(def.value.span!.end.offset, 35);

      final elements = (def.value as ConstListNode).elements
          .cast<IntConstantNode>();
      expect(elements[0].value, '1');
      expect(elements[0].span!.text, '1');
      expect(elements[0].span!.start.offset, 27);
      expect(elements[0].span!.end.offset, 28);

      expect(elements[1].value, '2');
      expect(elements[1].span!.text, '2');
      expect(elements[1].span!.start.offset, 30);
      expect(elements[1].span!.end.offset, 31);

      expect(elements[2].value, '3');
      expect(elements[2].span!.text, '3');
      expect(elements[2].span!.start.offset, 33);
      expect(elements[2].span!.end.offset, 34);
    });

    test('should parse empty array constant', () {
      const source = 'const list<i32> myArray = [];';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 29);

      final type = def.type as ListTypeNode;
      expect(type.span!.text, 'list<i32>');
      expect(type.span!.start.offset, 6);
      expect(type.span!.end.offset, 15);

      final elementType = type.elementType as BaseTypeNode;
      expect(elementType.type, 'i32');
      expect(elementType.span!.text, 'i32');
      expect(elementType.span!.start.offset, 11);
      expect(elementType.span!.end.offset, 14);

      expect(def.identifier.value, 'myArray');
      expect(def.identifier.span!.text, 'myArray');
      expect(def.identifier.span!.start.offset, 16);
      expect(def.identifier.span!.end.offset, 23);

      expect((def.value as ConstListNode).elements, isEmpty);

      expect(def.value.span!.text, '[]');
      expect(def.value.span!.start.offset, 26);
      expect(def.value.span!.end.offset, 28);
    });

    test('should parse map constant', () {
      const source = 'const map<string, i32> myMap = {"a": 1, "b": 2};';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 48);

      final type = def.type as MapTypeNode;
      expect(type.span!.text, 'map<string, i32>');
      expect(type.span!.start.offset, 6);
      expect(type.span!.end.offset, 22);

      expect(def.identifier.value, 'myMap');
      expect(def.identifier.span!.text, 'myMap');
      expect(def.identifier.span!.start.offset, 23);
      expect(def.identifier.span!.end.offset, 28);

      expect(def.value.span!.text, '{"a": 1, "b": 2}');
      expect(def.value.span!.start.offset, 31);
      expect(def.value.span!.end.offset, 47);

      final keyType = type.keyType as BaseTypeNode;
      expect(keyType.type, 'string');
      expect(keyType.span!.text, 'string');
      expect(keyType.span!.start.offset, 10);
      expect(keyType.span!.end.offset, 16);

      final valueType = type.valueType as BaseTypeNode;
      expect(valueType.type, 'i32');
      expect(valueType.span!.text, 'i32');
      expect(valueType.span!.start.offset, 18);
      expect(valueType.span!.end.offset, 21);

      final entries = (def.value as ConstMapNode).entries.cast<MapEntry>();

      final k1 = entries[0].key as LiteralNode;
      expect(k1.value, '"a"');
      expect(k1.span!.text, '"a"');
      expect(k1.span!.start.offset, 32);
      expect(k1.span!.end.offset, 35);

      final v1 = entries[0].value as IntConstantNode;
      expect(v1.value, '1');
      expect(v1.span!.text, '1');
      expect(v1.span!.start.offset, 37);
      expect(v1.span!.end.offset, 38);

      final k2 = entries[1].key as LiteralNode;
      expect(k2.value, '"b"');
      expect(k2.span!.text, '"b"');
      expect(k2.span!.start.offset, 40);
      expect(k2.span!.end.offset, 43);

      final v2 = entries[1].value as IntConstantNode;
      expect(v2.value, '2');
      expect(v2.span!.text, '2');
      expect(v2.span!.start.offset, 45);
      expect(v2.span!.end.offset, 46);
    });

    test('should parse empty map constant', () {
      const source = 'const map<string, i32> myMap = {};';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 34);

      final type = def.type as MapTypeNode;
      expect(type.span!.text, 'map<string, i32>');
      expect(type.span!.start.offset, 6);
      expect(type.span!.end.offset, 22);

      expect(def.identifier.value, 'myMap');
      expect(def.identifier.span!.text, 'myMap');
      expect(def.identifier.span!.start.offset, 23);
      expect(def.identifier.span!.end.offset, 28);

      expect((def.value as ConstMapNode).entries, isEmpty);

      expect(def.value.span!.text, '{}');
      expect(def.value.span!.start.offset, 31);
      expect(def.value.span!.end.offset, 33);
    });

    test('should parse byte constant', () {
      const source = 'const byte myByte = 255;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 24);

      expect((def.type as BaseTypeNode).type, 'byte');
      expect(def.type.span!.text, 'byte');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 10);

      expect(def.identifier.value, 'myByte');
      expect(def.identifier.span!.text, 'myByte');
      expect(def.identifier.span!.start.offset, 11);
      expect(def.identifier.span!.end.offset, 17);

      expect((def.value as IntConstantNode).value, '255');
      expect(def.value.span!.text, '255');
      expect(def.value.span!.start.offset, 20);
      expect(def.value.span!.end.offset, 23);
    });

    test('should parse i8 constant', () {
      const source = 'const i8 myI8 = 127;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 20);

      expect((def.type as BaseTypeNode).type, 'i8');
      expect(def.type.span!.text, 'i8');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 8);

      expect(def.identifier.value, 'myI8');
      expect(def.identifier.span!.text, 'myI8');
      expect(def.identifier.span!.start.offset, 9);
      expect(def.identifier.span!.end.offset, 13);

      expect((def.value as IntConstantNode).value, '127');
      expect(def.value.span!.text, '127');
      expect(def.value.span!.start.offset, 16);
      expect(def.value.span!.end.offset, 19);
    });

    test('should parse i16 constant', () {
      const source = 'const i16 myI16 = 32767;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 24);

      expect((def.type as BaseTypeNode).type, 'i16');
      expect(def.type.span!.text, 'i16');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 9);

      expect(def.identifier.value, 'myI16');
      expect(def.identifier.span!.text, 'myI16');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 15);

      expect((def.value as IntConstantNode).value, '32767');
      expect(def.value.span!.text, '32767');
      expect(def.value.span!.start.offset, 18);
      expect(def.value.span!.end.offset, 23);
    });

    test('should parse i64 constant', () {
      const source = 'const i64 myI64 = 9223372036854775807;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 38);

      expect((def.type as BaseTypeNode).type, 'i64');
      expect(def.type.span!.text, 'i64');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 9);

      expect(def.identifier.value, 'myI64');
      expect(def.identifier.span!.text, 'myI64');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 15);

      expect((def.value as IntConstantNode).value, '9223372036854775807');
      expect(def.value.span!.text, '9223372036854775807');
      expect(def.value.span!.start.offset, 18);
      expect(def.value.span!.end.offset, 37);
    });

    test('should parse binary constant', () {
      const source = 'const binary myBinary = "01010101";';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 35);

      expect((def.type as BaseTypeNode).type, 'binary');
      expect(def.type.span!.text, 'binary');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 12);

      expect(def.identifier.value, 'myBinary');
      expect(def.identifier.span!.text, 'myBinary');
      expect(def.identifier.span!.start.offset, 13);
      expect(def.identifier.span!.end.offset, 21);

      expect((def.value as LiteralNode).value, '"01010101"');
      expect(def.value.span!.text, '"01010101"');
      expect(def.value.span!.start.offset, 24);
      expect(def.value.span!.end.offset, 34);
    });

    test('should parse uuid constant', () {
      const source =
          'const uuid myUuid = "123e4567-e89b-12d3-a456-426614174000";';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 59);

      expect((def.type as BaseTypeNode).type, 'uuid');
      expect(def.type.span!.text, 'uuid');
      expect(def.type.span!.start.offset, 6);
      expect(def.type.span!.end.offset, 10);

      expect(def.identifier.value, 'myUuid');
      expect(def.identifier.span!.text, 'myUuid');
      expect(def.identifier.span!.start.offset, 11);
      expect(def.identifier.span!.end.offset, 17);

      expect(
        (def.value as LiteralNode).value,
        '"123e4567-e89b-12d3-a456-426614174000"',
      );
      expect(def.value.span!.text, '"123e4567-e89b-12d3-a456-426614174000"');
      expect(def.value.span!.start.offset, 20);
      expect(def.value.span!.end.offset, 58);
    });
  });
}
