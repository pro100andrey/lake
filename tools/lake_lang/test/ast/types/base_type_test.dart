import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('BaseType AST', () {
    test('should parse "string" type', () {
      const source = 'string';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect((def.fields[0].type as BaseTypeNode).value, 'string');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 17);
    });

    test('should parse "bool" type', () {
      const source = 'bool';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'bool');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 15);
    });

    test('should parse "byte" type', () {
      const source = 'byte';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'byte');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 15);
    });

    test('should parse "double" type', () {
      const source = 'double';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'double');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 17);
    });

    test('should parse "uuid" type', () {
      const source = 'uuid';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'uuid');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 15);
    });

    test('should parse "i8" type', () {
      const source = 'i8';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'i8');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 13);
    });

    test('should parse "i16" type', () {
      const source = 'i16';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'i16');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 14);
    });

    test('should parse "i32" type', () {
      const source = 'i32';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'i32');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 14);
    });

    test('should parse "i64" type', () {
      const source = 'i64';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'i64');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 14);
    });

    test('should parse "binary" type', () {
      const source = 'binary';
      final doc = parseAst('struct S { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;

      expect((def.fields[0].type as BaseTypeNode).value, 'binary');
      expect(def.fields[0].type.span.text, source);
      expect(def.fields[0].type.span.start.offset, 11);
      expect(def.fields[0].type.span.end.offset, 17);
    });
  });
}
