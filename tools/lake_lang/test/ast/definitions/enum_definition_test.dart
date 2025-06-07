import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('EnumDefinition AST', () {
    test('should parse empty enum', () {
      const source = 'enum Color {}';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as EnumDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 13);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span!.text, 'Color');
      expect(def.identifier.span!.start.offset, 5);
      expect(def.identifier.span!.end.offset, 10);

      expect(def.values, isEmpty);
    });

    test('should parse enum with values', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 31);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span!.text, 'Color');
      expect(def.identifier.span!.start.offset, 5);
      expect(def.identifier.span!.end.offset, 10);

      expect(def.values, hasLength(3));

      expect(def.values[0].identifier.value, 'RED');
      expect(def.values[0].identifier.span!.text, 'RED');
      expect(def.values[0].identifier.span!.start.offset, 13);
      expect(def.values[0].identifier.span!.end.offset, 16);

      expect(def.values[0].value, isNull);

      expect(def.values[1].identifier.value, 'GREEN');
      expect(def.values[1].identifier.span!.text, 'GREEN');
      expect(def.values[1].identifier.span!.start.offset, 18);
      expect(def.values[1].identifier.span!.end.offset, 23);

      expect(def.values[1].value, isNull);

      expect(def.values[2].identifier.value, 'BLUE');
      expect(def.values[2].identifier.span!.text, 'BLUE');
      expect(def.values[2].identifier.span!.start.offset, 25);
      expect(def.values[2].identifier.span!.end.offset, 29);

      expect(def.values[2].value, isNull);
    });

    test('should parse enum with values and explicit values', () {
      const source = 'enum Color { RED = 1, GREEN = 2, BLUE = 3 }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as EnumDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 43);

      expect(def.identifier.value, 'Color');
      expect(def.identifier.span!.text, 'Color');
      expect(def.identifier.span!.start.offset, 5);
      expect(def.identifier.span!.end.offset, 10);

      expect(def.values, hasLength(3));

      expect(def.values[0].identifier.value, 'RED');
      expect(def.values[0].identifier.span!.text, 'RED');
      expect(def.values[0].identifier.span!.start.offset, 13);
      expect(def.values[0].identifier.span!.end.offset, 16);

      expect((def.values[0].value!).value, '1');

      expect(def.values[1].identifier.value, 'GREEN');
      expect(def.values[1].identifier.span!.text, 'GREEN');
      expect(def.values[1].identifier.span!.start.offset, 22);
      expect(def.values[1].identifier.span!.end.offset, 27);

      expect((def.values[1].value!).value, '2');

      expect(def.values[2].identifier.value, 'BLUE');
      expect(def.values[2].identifier.span!.text, 'BLUE');
      expect(def.values[2].identifier.span!.start.offset, 33);
      expect(def.values[2].identifier.span!.end.offset, 37);

      expect((def.values[2].value!).value, '3');
    });

    test('should parse enum with values using semicolon separators', () {
      const source = 'enum Direction { NORTH; SOUTH; EAST; WEST; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 44);

      expect(def.identifier.value, 'Direction');
      expect(def.identifier.span!.text, 'Direction');
      expect(def.identifier.span!.start.offset, 5);
      expect(def.identifier.span!.end.offset, 14);

      expect(def.values, hasLength(4));
      expect(def.values[0].identifier.value, 'NORTH');
      expect(def.values[0].identifier.span!.text, 'NORTH');
      expect(def.values[0].identifier.span!.start.offset, 17);
      expect(def.values[0].identifier.span!.end.offset, 22);
      expect(def.values[0].value, isNull);

      expect(def.values[1].identifier.value, 'SOUTH');
      expect(def.values[1].identifier.span!.text, 'SOUTH');
      expect(def.values[1].identifier.span!.start.offset, 24);
      expect(def.values[1].identifier.span!.end.offset, 29);
      expect(def.values[1].value, isNull);

      expect(def.values[2].identifier.value, 'EAST');
      expect(def.values[2].identifier.span!.text, 'EAST');
      expect(def.values[2].identifier.span!.start.offset, 31);
      expect(def.values[2].identifier.span!.end.offset, 35);
      expect(def.values[2].value, isNull);

      expect(def.values[3].identifier.value, 'WEST');
      expect(def.values[3].identifier.span!.text, 'WEST');
      expect(def.values[3].identifier.span!.start.offset, 37);
      expect(def.values[3].identifier.span!.end.offset, 41);
      expect(def.values[3].value, isNull);
    });

    test('should parse enum with mixed explicit and implicit values', () {
      const source =
          'enum Status { PENDING = 1, PROCESSING, COMPLETED = 5, FAILED }';

      final doc = parseAst(source);
      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as EnumDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 62);

      expect(def.identifier.value, 'Status');
      expect(def.identifier.span!.text, 'Status');
      expect(def.identifier.span!.start.offset, 5);
      expect(def.identifier.span!.end.offset, 11);

      expect(def.values, hasLength(4));

      expect(def.values[0].identifier.value, 'PENDING');
      expect(def.values[0].identifier.span!.text, 'PENDING');
      expect(def.values[0].identifier.span!.start.offset, 14);
      expect(def.values[0].identifier.span!.end.offset, 21);

      expect(def.values[0].value!.value, '1');
      expect(def.values[0].value!.span!.text, '1');
      expect(def.values[0].value!.span!.start.offset, 24);
      expect(def.values[0].value!.span!.end.offset, 25);

      expect(def.values[1].identifier.value, 'PROCESSING');
      expect(def.values[1].identifier.span!.text, 'PROCESSING');
      expect(def.values[1].identifier.span!.start.offset, 27);
      expect(def.values[1].identifier.span!.end.offset, 37);
      expect(def.values[1].value, isNull);

      expect(def.values[2].identifier.value, 'COMPLETED');
      expect(def.values[2].identifier.span!.text, 'COMPLETED');
      expect(def.values[2].identifier.span!.start.offset, 39);
      expect(def.values[2].identifier.span!.end.offset, 48);

      expect(def.values[2].value!.value, '5');
      expect(def.values[2].value!.span!.text, '5');
      expect(def.values[2].value!.span!.start.offset, 51);
      expect(def.values[2].value!.span!.end.offset, 52);

      expect(def.values[3].identifier.value, 'FAILED');
      expect(def.values[3].identifier.span!.text, 'FAILED');
      expect(def.values[3].identifier.span!.start.offset, 54);
      expect(def.values[3].identifier.span!.end.offset, 60);
      expect(def.values[3].value, isNull);
    });
  });
}
