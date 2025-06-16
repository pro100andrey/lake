import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('ExceptionDefinition AST (positive):', () {
    test('should parse simple exception', () {
      const source = 'exception MyException {}';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.span, hasSpan(0, 24));

      expect(def.identifier.value, 'MyException');
      expect(def.identifier.span, hasSpan(10, 21));

      expect(def.fields, isEmpty);
    });

    test('should parse exception with fields without field index', () {
      const source = 'exception MyException { string message; i32 code; }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.span, hasSpan(0, 51));

      expect(def.identifier.value, 'MyException');
      expect(def.identifier.span, hasSpan(10, 21));

      final [FieldNode field, FieldNode field1] = def.fields;

      expect(def.fields, hasLength(2));

      final fieldType = field.type as BaseTypeNode;

      expect(field.fieldId, isNull);
      expect(fieldType.value, 'string');
      expect(fieldType.span, hasSpan(24, 30));

      expect(field.identifier.value, 'message');
      expect(field.identifier.span, hasSpan(31, 38));

      final field1Type = field1.type as BaseTypeNode;

      expect(field1.fieldId, isNull);
      expect(field1Type.value, 'i32');
      expect(field1Type.span, hasSpan(40, 43));

      expect(field1.identifier.value, 'code');
      expect(field1.identifier.span, hasSpan(44, 48));
    });

    test('should parse exception with fields with field index', () {
      const source = 'exception MyException {1: string message; 2: i32 code; }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.span, hasSpan(0, 56));

      expect(def.identifier.value, 'MyException');
      expect(def.identifier.span, hasSpan(10, 21));

      expect(def.fields, hasLength(2));

      final [FieldNode field, FieldNode field1] = def.fields;

      final fieldType = field.type as BaseTypeNode;

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span, hasSpan(23, 24));

      expect(fieldType.value, 'string');
      expect(fieldType.span, hasSpan(26, 32));

      expect(field.identifier.value, 'message');
      expect(field.identifier.span, hasSpan(33, 40));

      final field1Type = field1.type as BaseTypeNode;

      expect(field1.fieldId, isNotNull);
      expect(field1.fieldId!.rawValue, '2');
      expect(field1.fieldId!.value, 2);
      expect(field1.fieldId!.span, hasSpan(42, 43));

      expect(field1Type.value, 'i32');
      expect(field1Type.span, hasSpan(45, 48));

      expect(field1.identifier.value, 'code');
      expect(field1.identifier.span, hasSpan(49, 53));
    });

    test('should parse exception with required fields', () {
      const source =
          'exception AuthError '
          '{ required string username; required i32 code; }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.span, hasSpan(0, 68));
      expect(def.span.end, 68);

      expect(def.identifier.value, 'AuthError');
      expect(def.identifier.span, hasSpan(10, 19));

      expect(def.fields, hasLength(2));

      final [FieldNode field, FieldNode field1] = def.fields;

      expect(field.fieldId, isNull);
      expect(field.requirement!.value, 'required');
      expect(field.requirement!.span, hasSpan(22, 30));

      expect((field.type as BaseTypeNode).value, 'string');
      expect(field.type.span, hasSpan(31, 37));

      expect(field.identifier.value, 'username');
      expect(field.identifier.span, hasSpan(38, 46));

      expect(field1.fieldId, isNull);
      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span, hasSpan(48, 56));

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span, hasSpan(57, 60));

      expect(field1.identifier.value, 'code');
      expect(field1.identifier.span, hasSpan(61, 65));
    });

    test('should parse exception with optional fields', () {
      const source =
          'exception AuthError '
          '{ optional string username; optional i32 code; }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.span, hasSpan(0, 68));

      expect(def.identifier.value, 'AuthError');
      expect(def.identifier.span, hasSpan(10, 19));

      expect(def.fields, hasLength(2));

      final [FieldNode field, FieldNode field1] = def.fields;

      expect(field.fieldId, isNull);
      expect(field.requirement, isNotNull);
      expect(field.requirement!.value, 'optional');
      expect(field.requirement!.span, hasSpan(22, 30));

      expect((field.type as BaseTypeNode).value, 'string');
      expect(field.type.span, hasSpan(31, 37));

      expect(field.identifier.value, 'username');
      expect(field.identifier.span, hasSpan(38, 46));

      expect(field1.fieldId, isNull);
      expect(field1.requirement, isNotNull);
      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span, hasSpan(48, 56));

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span, hasSpan(57, 60));

      expect(field1.identifier.value, 'code');
      expect(field1.identifier.span, hasSpan(61, 65));
    });
  });

  group('ExceptionDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source =
          'exception AuthError '
          '{ required string username; required i32 code; }';

      const source2 =
          'exception AuthError '
          '{ required string username; required i32 code; }';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      final exception1 = doc1.definitions.first as ExceptionDefinitionNode;
      final exception2 = doc2.definitions.first as ExceptionDefinitionNode;

      expect(exception1, equals(exception2));
      expect(exception1.fields, equals(exception2.fields));
    });

    test('should not be equal for different definitions', () {
      const source1 =
          'exception AuthError '
          '{ required string username; required i32 code; }';
      const source2 =
          'exception AuthError '
          '{ required string email; required i32 code; }';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final exception1 = doc1.definitions.first as ExceptionDefinitionNode;
      final exception2 = doc2.definitions.first as ExceptionDefinitionNode;

      expect(exception1, isNot(equals(exception2)));
      expect(exception1.fields, isNot(equals(exception2.fields)));
    });
  });
}
