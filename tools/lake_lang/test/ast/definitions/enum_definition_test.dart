import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('EnumDefinition AST (positive):', () {
    test('should parse empty enum', () {
      const source = 'enum Color {}';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 13);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span.start, 5);
      expect(def.identifier.span.end, 10);

      expect(def.members, isEmpty);
    });

    test('should parse enum with values', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 31);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span.start, 5);
      expect(def.identifier.span.end, 10);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
      ] = def.members;

      expect(member1.identifier.value, 'RED');
      expect(member1.identifier.span.start, 13);
      expect(member1.identifier.span.end, 16);
      expect(member1.value, isNull);

      expect(member2.identifier.value, 'GREEN');
      expect(member2.identifier.span.start, 18);
      expect(member2.identifier.span.end, 23);
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'BLUE');
      expect(member3.identifier.span.start, 25);
      expect(member3.identifier.span.end, 29);
      expect(member3.value, isNull);
    });

    test('should parse enum with values and explicit values', () {
      const source = 'enum Color { RED = 1, GREEN = 2, BLUE = 3 }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 43);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span.start, 5);
      expect(def.identifier.span.end, 10);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
      ] = def.members;

      expect(member1.identifier.value, 'RED');
      expect(member1.identifier.span.start, 13);
      expect(member1.identifier.span.end, 16);
      expect(member1.value!.rawValue, '1');
      expect(member1.value!.value, 1);
      expect(member1.value!.span.start, 19);
      expect(member1.value!.span.end, 20);

      expect(member2.identifier.value, 'GREEN');
      expect(member2.identifier.span.start, 22);
      expect(member2.identifier.span.end, 27);
      expect(member2.value!.rawValue, '2');
      expect(member2.value!.value, 2);
      expect(member2.value!.span.start, 30);
      expect(member2.value!.span.end, 31);

      expect(member3.identifier.value, 'BLUE');
      expect(member3.identifier.span.start, 33);
      expect(member3.identifier.span.end, 37);
      expect(member3.value!.rawValue, '3');
      expect(member3.value!.value, 3);
      expect(member3.value!.span.start, 40);
      expect(member3.value!.span.end, 41);
    });

    test('should parse enum with values using semicolon separators', () {
      const source = 'enum Direction { NORTH; SOUTH; EAST; WEST; }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 44);

      expect(def.identifier.value, 'Direction');
      expect(def.identifier.span.start, 5);
      expect(def.identifier.span.end, 14);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
        EnumValueNode member4,
      ] = def.members;

      expect(member1.identifier.value, 'NORTH');
      expect(member1.identifier.span.start, 17);
      expect(member1.identifier.span.end, 22);
      expect(member1.value, isNull);

      expect(member2.identifier.value, 'SOUTH');
      expect(member2.identifier.span.start, 24);
      expect(member2.identifier.span.end, 29);
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'EAST');
      expect(member3.identifier.span.start, 31);
      expect(member3.identifier.span.end, 35);
      expect(member3.value, isNull);

      expect(member4.identifier.value, 'WEST');
      expect(member4.identifier.span.start, 37);
      expect(member4.identifier.span.end, 41);
      expect(member4.value, isNull);
    });

    test('should parse enum with mixed explicit and implicit values', () {
      const source =
          'enum Status { PENDING = 1, PROCESSING, COMPLETED = 5, FAILED }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 62);

      expect(def.identifier.value, 'Status');
      expect(def.identifier.span.start, 5);
      expect(def.identifier.span.end, 11);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
        EnumValueNode member4,
      ] = def.members;

      expect(member1.identifier.value, 'PENDING');
      expect(member1.identifier.span.start, 14);
      expect(member1.identifier.span.end, 21);

      expect(member1.value!.rawValue, '1');
      expect(member1.value!.value, 1);
      expect(member1.value!.span.start, 24);
      expect(member1.value!.span.end, 25);

      expect(member2.identifier.value, 'PROCESSING');
      expect(member2.identifier.span.start, 27);
      expect(member2.identifier.span.end, 37);
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'COMPLETED');
      expect(member3.identifier.span.start, 39);
      expect(member3.identifier.span.end, 48);
      expect(member3.value!.rawValue, '5');
      expect(member3.value!.value, 5);
      expect(member3.value!.span.start, 51);
      expect(member3.value!.span.end, 52);

      expect(member4.identifier.value, 'FAILED');
      expect(member4.identifier.span.start, 54);
      expect(member4.identifier.span.end, 60);
      expect(member4.value, isNull);
    });
  });

  group('EnumDefinition AST (equable)', () {
    test('should be equable for identical definitions', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      const source2 = 'enum Color { RED, GREEN, BLUE }';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final enum1 = doc1.definitions.first as EnumDefinitionNode;
      final enum2 = doc2.definitions.first as EnumDefinitionNode;

      expect(enum1, equals(enum2));
      expect(enum1.members, equals(enum2.members));
    });

    test('should not be equable for different definitions', () {
      const source1 = 'enum Color { RED, GREEN, BLUE }';
      const source2 = 'enum Color { YELLOW, ORANGE }';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final enum1 = doc1.definitions.first as EnumDefinitionNode;
      final enum2 = doc2.definitions.first as EnumDefinitionNode;

      expect(enum1, isNot(equals(enum2)));
      expect(enum1.members, isNot(equals(enum2.members)));
    });
  });
}
