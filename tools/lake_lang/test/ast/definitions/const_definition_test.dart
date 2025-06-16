import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ConstDefinition AST (positive):', () {
    test('should parse int constant', () {
      const source = 'const i32 myInt = 42;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 21);

      expect((def.type as BaseTypeNode).value, 'i32');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 9);

      expect(def.identifier.value, 'myInt');
      expect(def.identifier.span.start, 10);
      expect(def.identifier.span.end, 15);

      final intConst = def.value as IntConstantNode;
      expect(intConst.rawValue, '42');
      expect(intConst.value, 42);
      expect(intConst.span.start, 18);
      expect(intConst.span.end, 20);
    });

    test('should parse string constant', () {
      const source = 'const string myString = "Hello, World!";';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 40);

      expect((def.type as BaseTypeNode).value, 'string');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 12);

      expect(def.identifier.value, 'myString');
      expect(def.identifier.span.start, 13);
      expect(def.identifier.span.end, 21);

      final literal = def.value as LiteralNode;
      expect(literal.rawValue, '"Hello, World!"');
      expect(literal.value, 'Hello, World!');
      expect(literal.span.start, 24);
      expect(literal.span.end, 39);
    });

    test('should parse boolean constant', () {
      const source = 'const bool myBool = true;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 25);

      expect((def.type as BaseTypeNode).value, 'bool');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 10);

      expect(def.identifier.value, 'myBool');
      expect(def.identifier.span.start, 11);
      expect(def.identifier.span.end, 17);

      final boolConst = def.value as BoolConstantNode;
      expect(boolConst.value, isTrue);
      expect(boolConst.rawValue, 'true');
      expect(boolConst.span.start, 20);
      expect(boolConst.span.end, 24);
    });

    test('should parse double constant', () {
      const source = 'const double myDouble = 3.14';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 28);

      expect((def.type as BaseTypeNode).value, 'double');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 12);

      expect(def.identifier.value, 'myDouble');
      expect(def.identifier.span.start, 13);
      expect(def.identifier.span.end, 21);

      final doubleConst = def.value as DoubleConstantNode;
      expect(doubleConst.value, 3.14);
      expect(doubleConst.rawValue, '3.14');
      expect(doubleConst.span.start, 24);
      expect(doubleConst.span.end, 28);
    });

    test('should parse array constant', () {
      const source = 'const list<i32> myArray = [1, 2, 3];';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 36);

      final type = def.type as ListTypeNode;
      expect(type.span.start, 6);
      expect(type.span.end, 15);

      final elementType = type.elementType as BaseTypeNode;
      expect(elementType.value, 'i32');
      expect(elementType.span.start, 11);
      expect(elementType.span.end, 14);

      expect(def.identifier.value, 'myArray');
      expect(def.identifier.span.start, 16);
      expect(def.identifier.span.end, 23);

      expect(def.value.span.start, 26);
      expect(def.value.span.end, 35);

      final constList = def.value as ConstListNode;
      final elements = constList.elements;

      final e1 = elements[0] as IntConstantNode;
      expect(e1.rawValue, '1');
      expect(e1.value, 1);
      expect(e1.span.start, 27);
      expect(e1.span.end, 28);

      final e2 = elements[1] as IntConstantNode;
      expect(e2.rawValue, '2');
      expect(e2.value, 2);
      expect(e2.span.start, 30);
      expect(e2.span.end, 31);

      final e3 = elements[2] as IntConstantNode;
      expect(e3.rawValue, '3');
      expect(e3.value, 3);
      expect(e3.span.start, 33);
      expect(e3.span.end, 34);
    });

    test('should parse empty array constant', () {
      const source = 'const list<i32> myArray = [];';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 29);

      final type = def.type as ListTypeNode;
      expect(type.span.start, 6);
      expect(type.span.end, 15);

      final elementType = type.elementType as BaseTypeNode;
      expect(elementType.value, 'i32');
      expect(elementType.span.start, 11);
      expect(elementType.span.end, 14);

      expect(def.identifier.value, 'myArray');
      expect(def.identifier.span.start, 16);
      expect(def.identifier.span.end, 23);

      expect((def.value as ConstListNode).elements, isEmpty);
      expect(def.value.span.start, 26);
      expect(def.value.span.end, 28);
    });

    test('should parse map constant', () {
      const source = 'const map<string, i32> myMap = {"a": 1, "b": 2};';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 48);

      final type = def.type as MapTypeNode;
      expect(type.span.start, 6);
      expect(type.span.end, 22);

      expect(def.identifier.value, 'myMap');
      expect(def.identifier.span.start, 23);
      expect(def.identifier.span.end, 28);

      expect(def.value.span.start, 31);
      expect(def.value.span.end, 47);

      final keyType = type.keyType as BaseTypeNode;
      expect(keyType.value, 'string');
      expect(keyType.span.start, 10);
      expect(keyType.span.end, 16);

      final valueType = type.valueType as BaseTypeNode;
      expect(valueType.value, 'i32');
      expect(valueType.span.start, 18);
      expect(valueType.span.end, 21);

      final entries = (def.value as ConstMapNode).entries
          .cast<ConstMapNodePair>();

      final k1 = entries[0].key as LiteralNode;
      expect(k1.rawValue, '"a"');
      expect(k1.span.start, 32);
      expect(k1.span.end, 35);

      final v1 = entries[0].value as IntConstantNode;
      expect(v1.rawValue, '1');
      expect(v1.value, 1);
      expect(v1.span.start, 37);
      expect(v1.span.end, 38);

      final k2 = entries[1].key as LiteralNode;
      expect(k2.rawValue, '"b"');
      expect(k2.value, 'b');
      expect(k2.span.start, 40);
      expect(k2.span.end, 43);

      final v2 = entries[1].value as IntConstantNode;
      expect(v2.rawValue, '2');
      expect(v2.value, 2);
      expect(v2.span.start, 45);
      expect(v2.span.end, 46);
    });

    test('should parse empty map constant', () {
      const source = 'const map<string, i32> myMap = {};';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0] as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 34);

      final type = def.type as MapTypeNode;
      expect(type.span.start, 6);
      expect(type.span.end, 22);

      expect(def.identifier.value, 'myMap');
      expect(def.identifier.span.start, 23);
      expect(def.identifier.span.end, 28);

      expect((def.value as ConstMapNode).entries, isEmpty);
      expect(def.value.span.start, 31);
      expect(def.value.span.end, 33);
    });

    test('should parse byte constant', () {
      const source = 'const byte myByte = 255;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 24);

      expect((def.type as BaseTypeNode).value, 'byte');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 10);

      expect(def.identifier.value, 'myByte');
      expect(def.identifier.span.start, 11);
      expect(def.identifier.span.end, 17);

      final byteConst = def.value as IntConstantNode;
      expect(byteConst.rawValue, '255');
      expect(byteConst.value, 255);
      expect(byteConst.span.start, 20);
      expect(byteConst.span.end, 23);
    });

    test('should parse i8 constant', () {
      const source = 'const i8 myI8 = 127;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 20);

      expect((def.type as BaseTypeNode).value, 'i8');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 8);

      expect(def.identifier.value, 'myI8');
      expect(def.identifier.span.start, 9);
      expect(def.identifier.span.end, 13);

      final intConst = def.value as IntConstantNode;
      expect(intConst.rawValue, '127');
      expect(intConst.value, 127);
      expect(intConst.span.start, 16);
      expect(intConst.span.end, 19);
    });

    test('should parse i16 constant', () {
      const source = 'const i16 myI16 = 32767;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 24);

      expect((def.type as BaseTypeNode).value, 'i16');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 9);

      expect(def.identifier.value, 'myI16');
      expect(def.identifier.span.start, 10);
      expect(def.identifier.span.end, 15);

      expect((def.value as IntConstantNode).rawValue, '32767');
      expect(def.value.span.start, 18);
      expect(def.value.span.end, 23);
    });

    test('should parse i64 constant', () {
      const source = 'const i64 myI64 = 9223372036854775807;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 38);

      expect((def.type as BaseTypeNode).value, 'i64');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 9);

      expect(def.identifier.value, 'myI64');
      expect(def.identifier.span.start, 10);
      expect(def.identifier.span.end, 15);

      final intConst = def.value as IntConstantNode;
      expect(intConst.rawValue, '9223372036854775807');
      expect(intConst.value, 9223372036854775807);
      expect(intConst.span.start, 18);
      expect(intConst.span.end, 37);
    });

    test('should parse binary constant', () {
      const source = 'const binary myBinary = "01010101";';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 35);

      expect((def.type as BaseTypeNode).value, 'binary');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 12);

      expect(def.identifier.value, 'myBinary');
      expect(def.identifier.span.start, 13);
      expect(def.identifier.span.end, 21);

      final literal = def.value as LiteralNode;
      expect(literal.rawValue, '"01010101"');
      expect(literal.span.start, 24);
      expect(literal.span.end, 34);
    });

    test('should parse uuid constant', () {
      const source =
          'const uuid myUuid = "123e4567-e89b-12d3-a456-426614174000";';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first as ConstDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 59);

      expect((def.type as BaseTypeNode).value, 'uuid');
      expect(def.type.span.start, 6);
      expect(def.type.span.end, 10);

      expect(def.identifier.value, 'myUuid');
      expect(def.identifier.span.start, 11);
      expect(def.identifier.span.end, 17);

      expect(
        (def.value as LiteralNode).rawValue,
        '"123e4567-e89b-12d3-a456-426614174000"',
      );
      expect(def.value.span.start, 20);
      expect(def.value.span.end, 58);
    });
  });

  group('ConstDefinition AST (equable)', () {
    test('should be equal for same values', () {
      const source = 'const i32 myInt = 42;';
      const source2 = 'const i32 myInt = 42;';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final const11 = doc1.definitions.first as ConstDefinitionNode;
      final const12 = doc2.definitions.first as ConstDefinitionNode;

      expect(const11, equals(const12));
    });

    test('should not be equal for different values', () {
      const source1 = 'const i32 myInt = 42;';
      const source2 = 'const i32 myInt = 43;';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final const11 = doc1.definitions.first as ConstDefinitionNode;
      final const12 = doc2.definitions.first as ConstDefinitionNode;

      expect(const11, isNot(equals(const12)));
    });
  });
}
