import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('BaseType AST', () {
    test('should parse "string" type', () {
      const source = 'string';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'string');
      expect(fieldType.span, hasSpan(11, 17));
    });

    test('should parse "bool" type', () {
      const source = 'bool';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'bool');
      expect(fieldType.span, hasSpan(11, 15));
    });

    test('should parse "byte" type', () {
      const source = 'byte';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'byte');
      expect(fieldType.span, hasSpan(11, 15));
    });

    test('should parse "double" type', () {
      const source = 'double';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'double');
      expect(fieldType.span, hasSpan(11, 17));

      expect(fieldType.value, 'double');
      expect(fieldType.span, hasSpan(11, 17));
    });

    test('should parse "uuid" type', () {
      const source = 'uuid';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'uuid');
      expect(fieldType.span, hasSpan(11, 15));
    });

    test('should parse "i8" type', () {
      const source = 'i8';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'i8');
      expect(fieldType.span, hasSpan(11, 13));
    });

    test('should parse "i16" type', () {
      const source = 'i16';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'i16');
      expect(fieldType.span, hasSpan(11, 14));
    });

    test('should parse "i32" type', () {
      const source = 'i32';
      final doc = parseAstFromString('struct S { $source x; }');
      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'i32');
      expect(fieldType.span, hasSpan(11, 14));
    });

    test('should parse "i64" type', () {
      const source = 'i64';
      final doc = parseAstFromString('struct S { $source x; }');

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'i64');
      expect(fieldType.span, hasSpan(11, 14));
    });

    test('should parse "binary" type', () {
      const source = 'binary';
      final doc = parseAstFromString('struct S { $source x; }');

      final def = doc.definitions.first.cast<StructDefinitionNode>();
      final fieldType = def.fields[0].type.cast<BaseTypeNode>();

      expect(fieldType.value, 'binary');
      expect(fieldType.span, hasSpan(11, 17));
    });
  });

  group('BaseType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'string';
      final doc1 = parseAstFromString('struct S { $source x; }');
      final doc2 = parseAstFromString('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAstFromString('struct S { string x; }');
      final doc2 = parseAstFromString('struct S { bool x; }');

      final def1 = doc1.definitions.first.cast<StructDefinitionNode>();
      final def2 = doc2.definitions.first.cast<StructDefinitionNode>();

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
