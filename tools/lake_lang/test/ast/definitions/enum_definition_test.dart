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

      expect(def.identifier.value, 'Color');
      expect(def.values, isEmpty);
      expect(def.span!.text, 'enum Color {}');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 14);

      expect(def.identifier.span!.text, 'Color');
      expect(def.identifier.span!.start.offset, 5);
      expect(def.identifier.span!.end.offset, 10);
    });

    test('should parse enum with values', () {
      const source = 'enum Color { RED, GREEN, BLUE }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.identifier.value, 'Color');
      expect(def.values, hasLength(3));
      expect(def.values[0].identifier.value, 'RED');
      expect(def.values[1].identifier.value, 'GREEN');
      expect(def.values[2].identifier.value, 'BLUE');
      expect(def.values[0].value, isNull);
      expect(def.values[1].value, isNull);
      expect(def.values[2].value, isNull);

      expect(def.span!.text, 'enum Color { RED, GREEN, BLUE }');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 30);
    });

    test('should parse enum with explicit int values', () {
      const source = 'enum Status { OK = 0, ERROR = 1 }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.identifier.value, 'Status');
      expect(def.values, hasLength(2));
      expect(def.values[0].identifier.value, 'OK');
      expect(def.values[0].value, isNotNull);
      expect((def.values[0].value!).value, '0');
      expect(def.values[1].identifier.value, 'ERROR');
      expect(def.values[1].value, isNotNull);
      expect((def.values[1].value!).value, '1');
    });

    test('should parse enum with trailing comma', () {
      const source = 'enum E { A, B, }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.identifier.value, 'E');
      expect(def.values, hasLength(2));
      expect(def.values[0].identifier.value, 'A');
      expect(def.values[1].identifier.value, 'B');
    });

    test('should parse enum with mixed separators', () {
      const source = 'enum E { A, B; C, }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.identifier.value, 'E');
      expect(def.values, hasLength(3));
      expect(def.values[0].identifier.value, 'A');
      expect(def.values[1].identifier.value, 'B');
      expect(def.values[2].identifier.value, 'C');
    });

    test('should parse enum with whitespace', () {
      const source = '  enum   E   {   A ,  B   }  ';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as EnumDefinitionNode;

      expect(def.identifier.value, 'E');
      expect(def.values, hasLength(2));
      expect(def.values[0].identifier.value, 'A');
      expect(def.values[1].identifier.value, 'B');
    });
  });
}
