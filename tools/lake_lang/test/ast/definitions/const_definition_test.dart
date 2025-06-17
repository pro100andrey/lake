import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('ConstDefinition AST (positive):', () {
    test('should parse int constant', () {
      const source = 'const i32 myInt = 42;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 21));

      expect(def.type.cast<BaseTypeNode>().value, 'i32');
      expect(def.type.span, hasSpan(6, 9));

      expect(def.identifier.value, 'myInt');
      expect(def.identifier.span, hasSpan(10, 15));

      final intConst = def.value.cast<IntLiteralNode>();
      expect(intConst.rawValue, '42');
      expect(intConst.value, 42);
      expect(intConst.span, hasSpan(18, 20));
    });

    test('should parse string constant', () {
      const source = 'const string myString = "Hello, World!";';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();

      expect(def.span, hasSpan(0, 40));

      expect(def.type.cast<BaseTypeNode>().value, 'string');
      expect(def.type.span, hasSpan(6, 12));

      expect(def.identifier.value, 'myString');
      expect(def.identifier.span, hasSpan(13, 21));

      final literal = def.value.cast<StringLiteralNode>();
      expect(literal.rawValue, '"Hello, World!"');
      expect(literal.value, 'Hello, World!');
      expect(literal.span, hasSpan(24, 39));
    });

    test('should parse boolean constant', () {
      const source = 'const bool myBool = true;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 25));

      expect(def.type.cast<BaseTypeNode>().value, 'bool');
      expect(def.type.span, hasSpan(6, 10));

      expect(def.identifier.value, 'myBool');
      expect(def.identifier.span, hasSpan(11, 17));

      final boolConst = def.value.cast<BoolLiteralNode>();
      expect(boolConst.value, isTrue);
      expect(boolConst.rawValue, 'true');
      expect(boolConst.span, hasSpan(20, 24));
    });

    test('should parse double constant', () {
      const source = 'const double myDouble = 3.14';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 28));

      expect(def.type.cast<BaseTypeNode>().value, 'double');
      expect(def.type.span, hasSpan(6, 12));

      expect(def.identifier.value, 'myDouble');
      expect(def.identifier.span, hasSpan(13, 21));

      final doubleConst = def.value.cast<DoubleLiteralNode>();
      expect(doubleConst.value, 3.14);
      expect(doubleConst.rawValue, '3.14');
      expect(doubleConst.span, hasSpan(24, 28));
    });

    test('should parse array constant', () {
      const source = 'const list<i32> myArray = [1, 2, 3];';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0].cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 36));

      final type = def.type.cast<ListTypeNode>();
      expect(type.span, hasSpan(6, 15));

      final elementType = type.elementType.cast<BaseTypeNode>();
      expect(elementType.value, 'i32');
      expect(elementType.span, hasSpan(11, 14));

      expect(def.identifier.value, 'myArray');
      expect(def.identifier.span, hasSpan(16, 23));

      expect(def.value.span, hasSpan(26, 35));

      final constList = def.value.cast<ListLiteralNode>();
      final elements = constList.elements;

      final [IntLiteralNode e0, IntLiteralNode e1, IntLiteralNode e2] = elements
          .cast<IntLiteralNode>();

      expect(e0.rawValue, '1');
      expect(e0.value, 1);
      expect(e0.span, hasSpan(27, 28));

      expect(e1.rawValue, '2');
      expect(e1.value, 2);
      expect(e1.span, hasSpan(30, 31));

      expect(e2.rawValue, '3');
      expect(e2.value, 3);
      expect(e2.span, hasSpan(33, 34));
    });

    test('should parse empty array constant', () {
      const source = 'const list<i32> myArray = [];';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0].cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 29));

      final type = def.type.cast<ListTypeNode>();
      expect(type.span, hasSpan(6, 15));

      final elementType = type.elementType.cast<BaseTypeNode>();
      expect(elementType.value, 'i32');
      expect(elementType.span, hasSpan(11, 14));

      expect(def.identifier.value, 'myArray');
      expect(def.identifier.span, hasSpan(16, 23));

      expect(def.value.cast<ListLiteralNode>().elements, isEmpty);
      expect(def.value.span, hasSpan(26, 28));
    });

    test('should parse map constant', () {
      const source = 'const map<string, i32> myMap = {"a": 1, "b": 2};';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0].cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 48));

      final type = def.type.cast<MapTypeNode>();
      expect(type.span, hasSpan(6, 22));

      expect(def.identifier.value, 'myMap');
      expect(def.identifier.span, hasSpan(23, 28));

      expect(def.value.span, hasSpan(31, 47));

      final keyType = type.keyType.cast<BaseTypeNode>();
      expect(keyType.value, 'string');
      expect(keyType.span, hasSpan(10, 16));

      final valueType = type.valueType.cast<BaseTypeNode>();
      expect(valueType.value, 'i32');
      expect(valueType.span, hasSpan(18, 21));

      final entries = def.value
          .cast<MapLiteralNode>()
          .entries
          .cast<MapLiteralEntry>();

      final k1 = entries[0].key.cast<StringLiteralNode>();
      expect(k1.rawValue, '"a"');
      expect(k1.span, hasSpan(32, 35));

      final v1 = entries[0].value.cast<IntLiteralNode>();
      expect(v1.rawValue, '1');
      expect(v1.value, 1);
      expect(v1.span, hasSpan(37, 38));

      final k2 = entries[1].key.cast<StringLiteralNode>();
      expect(k2.rawValue, '"b"');
      expect(k2.value, 'b');
      expect(k2.span, hasSpan(40, 43));

      final v2 = entries[1].value.cast<IntLiteralNode>();
      expect(v2.rawValue, '2');
      expect(v2.value, 2);
      expect(v2.span, hasSpan(45, 46));
    });

    test('should parse empty map constant', () {
      const source = 'const map<string, i32> myMap = {};';
      final doc = parseAstFromString(source);

      final def = doc.definitions[0].cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 34));

      final type = def.type.cast<MapTypeNode>();
      expect(type.span, hasSpan(6, 22));

      expect(def.identifier.value, 'myMap');
      expect(def.identifier.span, hasSpan(23, 28));

      expect(def.value.cast<MapLiteralNode>().entries, isEmpty);
      expect(def.value.span, hasSpan(31, 33));
    });

    test('should parse byte constant', () {
      const source = 'const byte myByte = 255;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 24));

      expect(def.type.cast<BaseTypeNode>().value, 'byte');
      expect(def.type.span, hasSpan(6, 10));

      expect(def.identifier.value, 'myByte');
      expect(def.identifier.span, hasSpan(11, 17));

      final byteConst = def.value.cast<IntLiteralNode>();
      expect(byteConst.rawValue, '255');
      expect(byteConst.value, 255);
      expect(byteConst.span, hasSpan(20, 23));
    });

    test('should parse i8 constant', () {
      const source = 'const i8 myI8 = 127;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 20));

      expect(def.type.cast<BaseTypeNode>().value, 'i8');
      expect(def.type.span, hasSpan(6, 8));

      expect(def.identifier.value, 'myI8');
      expect(def.identifier.span, hasSpan(9, 13));

      final intConst = def.value.cast<IntLiteralNode>();
      expect(intConst.rawValue, '127');
      expect(intConst.value, 127);
      expect(intConst.span, hasSpan(16, 19));
    });

    test('should parse i16 constant', () {
      const source = 'const i16 myI16 = 32767;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 24));

      expect(def.type.cast<BaseTypeNode>().value, 'i16');
      expect(def.type.span, hasSpan(6, 9));

      expect(def.identifier.value, 'myI16');
      expect(def.identifier.span, hasSpan(10, 15));

      expect(def.value.cast<IntLiteralNode>().rawValue, '32767');
      expect(def.value.span, hasSpan(18, 23));
    });

    test('should parse i64 constant', () {
      const source = 'const i64 myI64 = 9223372036854775807;';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 38));

      expect(def.type.cast<BaseTypeNode>().value, 'i64');
      expect(def.type.span, hasSpan(6, 9));

      expect(def.identifier.value, 'myI64');
      expect(def.identifier.span, hasSpan(10, 15));

      final intConst = def.value.cast<IntLiteralNode>();
      expect(intConst.rawValue, '9223372036854775807');
      expect(intConst.value, 9223372036854775807);
      expect(intConst.span, hasSpan(18, 37));
    });

    test('should parse binary constant', () {
      const source = 'const binary myBinary = "01010101";';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 35));

      expect(def.type.cast<BaseTypeNode>().value, 'binary');
      expect(def.type.span, hasSpan(6, 12));

      expect(def.identifier.value, 'myBinary');
      expect(def.identifier.span, hasSpan(13, 21));

      final literal = def.value.cast<StringLiteralNode>();
      expect(literal.rawValue, '"01010101"');
      expect(literal.span, hasSpan(24, 34));
    });

    test('should parse uuid constant', () {
      const source =
          'const uuid myUuid = "123e4567-e89b-12d3-a456-426614174000";';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ConstDefinitionNode>();
      expect(def.span, hasSpan(0, 59));

      expect(def.type.cast<BaseTypeNode>().value, 'uuid');
      expect(def.type.span, hasSpan(6, 10));

      expect(def.identifier.value, 'myUuid');
      expect(def.identifier.span, hasSpan(11, 17));

      expect(
        def.value.cast<StringLiteralNode>().rawValue,
        '"123e4567-e89b-12d3-a456-426614174000"',
      );
      expect(def.value.span, hasSpan(20, 58));
    });
  });

  group('ConstDefinition AST (equable)', () {
    test('should be equal for same values', () {
      const source = 'const i32 myInt = 42;';
      const source2 = 'const i32 myInt = 42;';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final const11 = doc1.definitions.first.cast<ConstDefinitionNode>();
      final const12 = doc2.definitions.first.cast<ConstDefinitionNode>();

      expect(const11, equals(const12));
    });

    test('should not be equal for different values', () {
      const source1 = 'const i32 myInt = 42;';
      const source2 = 'const i32 myInt = 43;';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final const11 = doc1.definitions.first.cast<ConstDefinitionNode>();
      final const12 = doc2.definitions.first.cast<ConstDefinitionNode>();

      expect(const11, isNot(equals(const12)));
    });
  });
}
