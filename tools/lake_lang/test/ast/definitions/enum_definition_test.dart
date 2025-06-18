import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('EnumDefinition AST (positive):', () {
    test('should parse empty enum', () {
      const source = 'enum Color {}';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<EnumDefinitionNode>();

      expect(def.span, hasSpan(0, 13));
      expect(def.identifier.value, 'Color');
      expect(def.identifier.span, hasSpan(5, 10));
      expect(def.members, isEmpty);
    });

    test('should parse enum with values', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<EnumDefinitionNode>();

      expect(def.span, hasSpan(0, 31));

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span, hasSpan(5, 10));

      final [
        EnumMemberNode member1,
        EnumMemberNode member2,
        EnumMemberNode member3,
      ] = def.members;

      expect(member1.identifier.value, 'RED');
      expect(member1.identifier.span, hasSpan(13, 16));
      expect(member1.value, isNull);

      expect(member2.identifier.value, 'GREEN');
      expect(member2.identifier.span, hasSpan(18, 23));
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'BLUE');
      expect(member3.identifier.span, hasSpan(25, 29));
      expect(member3.value, isNull);
    });

    test('should parse enum with values and explicit values', () {
      const source = 'enum Color { RED = 1, GREEN = 2, BLUE = 3 }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<EnumDefinitionNode>();

      expect(def.span, hasSpan(0, 43));

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span, hasSpan(5, 10));

      final [
        EnumMemberNode member1,
        EnumMemberNode member2,
        EnumMemberNode member3,
      ] = def.members;

      expect(member1.identifier.value, 'RED');
      expect(member1.identifier.span, hasSpan(13, 16));
      expect(member1.value!.rawValue, '1');
      expect(member1.value!.value, 1);
      expect(member1.value!.span, hasSpan(19, 20));

      expect(member2.identifier.value, 'GREEN');
      expect(member2.identifier.span, hasSpan(22, 27));
      expect(member2.value!.rawValue, '2');
      expect(member2.value!.value, 2);
      expect(member2.value!.span, hasSpan(30, 31));

      expect(member3.identifier.value, 'BLUE');
      expect(member3.identifier.span, hasSpan(33, 37));
      expect(member3.value!.rawValue, '3');
      expect(member3.value!.value, 3);
      expect(member3.value!.span, hasSpan(40, 41));
    });

    test('should parse enum with values using semicolon separators', () {
      const source = 'enum Direction { NORTH; SOUTH; EAST; WEST; }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<EnumDefinitionNode>();

      expect(def.span, hasSpan(0, 44));

      expect(def.identifier.value, 'Direction');
      expect(def.identifier.span, hasSpan(5, 14));

      final [
        EnumMemberNode member1,
        EnumMemberNode member2,
        EnumMemberNode member3,
        EnumMemberNode member4,
      ] = def.members;

      expect(member1.identifier.value, 'NORTH');
      expect(member1.identifier.span, hasSpan(17, 22));
      expect(member1.value, isNull);

      expect(member2.identifier.value, 'SOUTH');
      expect(member2.identifier.span, hasSpan(24, 29));
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'EAST');
      expect(member3.identifier.span, hasSpan(31, 35));
      expect(member3.value, isNull);

      expect(member4.identifier.value, 'WEST');
      expect(member4.identifier.span, hasSpan(37, 41));
      expect(member4.value, isNull);
    });

    test('should parse enum with mixed explicit and implicit values', () {
      const source =
          'enum Status { PENDING = 1, PROCESSING, COMPLETED = 5, FAILED }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<EnumDefinitionNode>();

      expect(def.span, hasSpan(0, 62));

      expect(def.identifier.value, 'Status');
      expect(def.identifier.span, hasSpan(5, 11));

      final [
        EnumMemberNode member1,
        EnumMemberNode member2,
        EnumMemberNode member3,
        EnumMemberNode member4,
      ] = def.members;

      expect(member1.identifier.value, 'PENDING');
      expect(member1.identifier.span, hasSpan(14, 21));

      expect(member1.value!.rawValue, '1');
      expect(member1.value!.value, 1);
      expect(member1.value!.span, hasSpan(24, 25));

      expect(member2.identifier.value, 'PROCESSING');
      expect(member2.identifier.span, hasSpan(27, 37));
      expect(member2.value, isNull);

      expect(member3.identifier.value, 'COMPLETED');
      expect(member3.identifier.span, hasSpan(39, 48));
      expect(member3.value!.rawValue, '5');
      expect(member3.value!.value, 5);
      expect(member3.value!.span, hasSpan(51, 52));

      expect(member4.identifier.value, 'FAILED');
      expect(member4.identifier.span, hasSpan(54, 60));
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

      final enum1 = doc1.definitions.first.cast<EnumDefinitionNode>();
      final enum2 = doc2.definitions.first.cast<EnumDefinitionNode>();

      expect(enum1, equals(enum2));
      expect(enum1.members, equals(enum2.members));
    });

    test('should not be equable for different definitions', () {
      const source1 = 'enum Color { RED, GREEN, BLUE }';
      const source2 = 'enum Color { YELLOW, ORANGE }';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final enum1 = doc1.definitions.first.cast<EnumDefinitionNode>();
      final enum2 = doc2.definitions.first.cast<EnumDefinitionNode>();

      expect(enum1, isNot(equals(enum2)));
      expect(enum1.members, isNot(equals(enum2.members)));
    });
  });
}
