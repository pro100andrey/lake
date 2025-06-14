import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('EnumDefinition AST', () {
    test('should parse empty enum', () {
      const source = 'enum Color {}';
      final doc = parseAst(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 13);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span.text, 'Color');
      expect(def.identifier.span.start.offset, 5);
      expect(def.identifier.span.end.offset, 10);

      expect(def.members, isEmpty);
    });

    test('should parse enum with values', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      final doc = parseAst(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 31);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span.text, 'Color');
      expect(def.identifier.span.start.offset, 5);
      expect(def.identifier.span.end.offset, 10);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
      ] = def.members;

      expect(member1.identifier.value, 'RED');
      expect(member1.identifier.span.text, 'RED');
      expect(member1.identifier.span.start.offset, 13);
      expect(member1.identifier.span.end.offset, 16);
      expect(member1.value, isNull);

      expect(member2.identifier.value, 'GREEN');
      expect(member2.identifier.span.text, 'GREEN');
      expect(member2.identifier.span.start.offset, 18);
      expect(member2.identifier.span.end.offset, 23);
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'BLUE');
      expect(member3.identifier.span.text, 'BLUE');
      expect(member3.identifier.span.start.offset, 25);
      expect(member3.identifier.span.end.offset, 29);
      expect(member3.value, isNull);
    });

    test('should parse enum with values and explicit values', () {
      const source = 'enum Color { RED = 1, GREEN = 2, BLUE = 3 }';
      final doc = parseAst(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 43);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span.text, 'Color');
      expect(def.identifier.span.start.offset, 5);
      expect(def.identifier.span.end.offset, 10);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
      ] = def.members;

      expect(member1.identifier.value, 'RED');
      expect(member1.identifier.span.text, 'RED');
      expect(member1.identifier.span.start.offset, 13);
      expect(member1.identifier.span.end.offset, 16);
      expect(member1.value!.rawValue, '1');
      expect(member1.value!.value, 1);
      expect(member1.value!.span.text, '1');
      expect(member1.value!.span.start.offset, 19);
      expect(member1.value!.span.end.offset, 20);

      expect(member2.identifier.value, 'GREEN');
      expect(member2.identifier.span.text, 'GREEN');
      expect(member2.identifier.span.start.offset, 22);
      expect(member2.identifier.span.end.offset, 27);
      expect(member2.value!.rawValue, '2');
      expect(member2.value!.value, 2);
      expect(member2.value!.span.text, '2');
      expect(member2.value!.span.start.offset, 30);
      expect(member2.value!.span.end.offset, 31);

      expect(member3.identifier.value, 'BLUE');
      expect(member3.identifier.span.text, 'BLUE');
      expect(member3.identifier.span.start.offset, 33);
      expect(member3.identifier.span.end.offset, 37);
      expect(member3.value!.rawValue, '3');
      expect(member3.value!.value, 3);
      expect(member3.value!.span.text, '3');
      expect(member3.value!.span.start.offset, 40);
      expect(member3.value!.span.end.offset, 41);
    });

    test('should parse enum with values using semicolon separators', () {
      const source = 'enum Direction { NORTH; SOUTH; EAST; WEST; }';
      final doc = parseAst(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 44);

      expect(def.identifier.value, 'Direction');
      expect(def.identifier.span.text, 'Direction');
      expect(def.identifier.span.start.offset, 5);
      expect(def.identifier.span.end.offset, 14);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
        EnumValueNode member4,
      ] = def.members;

      expect(member1.identifier.value, 'NORTH');
      expect(member1.identifier.span.text, 'NORTH');
      expect(member1.identifier.span.start.offset, 17);
      expect(member1.identifier.span.end.offset, 22);
      expect(member1.value, isNull);

      expect(member2.identifier.value, 'SOUTH');
      expect(member2.identifier.span.text, 'SOUTH');
      expect(member2.identifier.span.start.offset, 24);
      expect(member2.identifier.span.end.offset, 29);
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'EAST');
      expect(member3.identifier.span.text, 'EAST');
      expect(member3.identifier.span.start.offset, 31);
      expect(member3.identifier.span.end.offset, 35);
      expect(member3.value, isNull);

      expect(member4.identifier.value, 'WEST');
      expect(member4.identifier.span.text, 'WEST');
      expect(member4.identifier.span.start.offset, 37);
      expect(member4.identifier.span.end.offset, 41);
      expect(member4.value, isNull);
    });

    test('should parse enum with mixed explicit and implicit values', () {
      const source =
          'enum Status { PENDING = 1, PROCESSING, COMPLETED = 5, FAILED }';
      final doc = parseAst(source);
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 62);

      expect(def.identifier.value, 'Status');
      expect(def.identifier.span.text, 'Status');
      expect(def.identifier.span.start.offset, 5);
      expect(def.identifier.span.end.offset, 11);

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
        EnumValueNode member4,
      ] = def.members;

      expect(member1.identifier.value, 'PENDING');
      expect(member1.identifier.span.text, 'PENDING');
      expect(member1.identifier.span.start.offset, 14);
      expect(member1.identifier.span.end.offset, 21);

      expect(member1.value!.rawValue, '1');
      expect(member1.value!.value, 1);
      expect(member1.value!.span.text, '1');
      expect(member1.value!.span.start.offset, 24);
      expect(member1.value!.span.end.offset, 25);

      expect(member2.identifier.value, 'PROCESSING');
      expect(member2.identifier.span.text, 'PROCESSING');
      expect(member2.identifier.span.start.offset, 27);
      expect(member2.identifier.span.end.offset, 37);
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'COMPLETED');
      expect(member3.identifier.span.text, 'COMPLETED');
      expect(member3.identifier.span.start.offset, 39);
      expect(member3.identifier.span.end.offset, 48);
      expect(member3.value!.rawValue, '5');
      expect(member3.value!.value, 5);
      expect(member3.value!.span.text, '5');
      expect(member3.value!.span.start.offset, 51);
      expect(member3.value!.span.end.offset, 52);

      expect(member4.identifier.value, 'FAILED');
      expect(member4.identifier.span.text, 'FAILED');
      expect(member4.identifier.span.start.offset, 54);
      expect(member4.identifier.span.end.offset, 60);
      expect(member4.value, isNull);
    });
  });

  group('EnumDefinition AST (equable)', () {
    test('should be equable for identical definitions', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      const source2 = 'enum Color { RED, GREEN, BLUE }';
      final doc1 = parseAst(source);
      final doc2 = parseAst(source2);
      expect(doc1, equals(doc2));
      expect(doc1.definitions.first, equals(doc2.definitions.first));
    });

    test('should not be equable for different definitions', () {
      const source1 = 'enum Color { RED, GREEN, BLUE }';
      const source2 = 'enum Color { YELLOW, ORANGE }';
      final doc1 = parseAst(source1);
      final doc2 = parseAst(source2);

      expect(doc1, isNot(equals(doc2)));
      expect(doc1.definitions.first, isNot(equals(doc2.definitions.first)));
    });
  });
}
