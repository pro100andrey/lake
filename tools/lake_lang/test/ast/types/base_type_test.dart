import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('BaseType AST', () {
    test('should parse "string" type', () {
      const source = 'string';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'string');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 17);
    });

    test('should parse "bool" type', () {
      const source = 'bool';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'bool');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 15);
    });

    test('should parse "byte" type', () {
      const source = 'byte';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'byte');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 15);
    });

    test('should parse "double" type', () {
      const source = 'double';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'double');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 17);
    });

    test('should parse "uuid" type', () {
      const source = 'uuid';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'uuid');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 15);
    });

    test('should parse "i8" type', () {
      const source = 'i8';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'i8');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 13);
    });

    test('should parse "i16" type', () {
      const source = 'i16';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'i16');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 14);
    });

    test('should parse "i32" type', () {
      const source = 'i32';
      final doc = parseAndGetAst('struct S { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'i32');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 14);
    });

    test('should parse "i64" type', () {
      const source = 'i64';
      final doc = parseAndGetAst('struct S { $source x; }');

      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'i64');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 14);
    });

    test('should parse "binary" type', () {
      const source = 'binary';
      final doc = parseAndGetAst('struct S { $source x; }');

      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as BaseTypeNode;

      expect(fieldType.value, 'binary');
      expect(fieldType.span.start, 11);
      expect(fieldType.span.end, 17);
    });
  });

  group('BaseType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'string';
      final doc1 = parseAndGetAst('struct S { $source x; }');
      final doc2 = parseAndGetAst('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAndGetAst('struct S { string x; }');
      final doc2 = parseAndGetAst('struct S { bool x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
