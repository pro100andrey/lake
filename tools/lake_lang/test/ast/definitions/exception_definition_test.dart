import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ExceptionDefinition AST', () {
    test('should parse simple exception', () {
      const source = 'exception MyException {}';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ExceptionDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 24);

      expect(def.identifier.value, 'MyException');
      expect(def.identifier.span!.text, 'MyException');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 21);

      expect(def.fields, isEmpty);
    });

    test('should parse exception with fields without field index', () {
      const source = 'exception MyException { string message; i32 code; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ExceptionDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 51);

      expect(def.identifier.value, 'MyException');
      expect(def.identifier.span!.text, 'MyException');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 21);

      expect(def.fields, hasLength(2));

      expect(def.fields[0].fieldId, isNull);

      expect((def.fields[0].type as BaseTypeNode).type, 'string');
      expect(def.fields[0].type.span!.text, 'string');
      expect(def.fields[0].type.span!.start.offset, 24);
      expect(def.fields[0].type.span!.end.offset, 30);

      expect(def.fields[0].identifier.value, 'message');
      expect(def.fields[0].identifier.span!.text, 'message');
      expect(def.fields[0].identifier.span!.start.offset, 31);
      expect(def.fields[0].identifier.span!.end.offset, 38);

      expect(def.fields[1].fieldId, isNull);

      expect((def.fields[1].type as BaseTypeNode).type, 'i32');
      expect(def.fields[1].type.span!.text, 'i32');
      expect(def.fields[1].type.span!.start.offset, 40);
      expect(def.fields[1].type.span!.end.offset, 43);

      expect(def.fields[1].identifier.value, 'code');
      expect(def.fields[1].identifier.span!.text, 'code');
      expect(def.fields[1].identifier.span!.start.offset, 44);
      expect(def.fields[1].identifier.span!.end.offset, 48);
    });

    test('should parse exception with fields with field index', () {
      const source = 'exception MyException {1: string message; 2: i32 code; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 56);

      expect(def.identifier.value, 'MyException');
      expect(def.identifier.span!.text, 'MyException');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 21);

      expect(def.fields, hasLength(2));

      expect(def.fields[0].fieldId, isNotNull);
      expect(def.fields[0].fieldId!.value, '1');
      expect(def.fields[0].fieldId!.span!.text, '1');
      expect(def.fields[0].fieldId!.span!.start.offset, 23);
      expect(def.fields[0].fieldId!.span!.end.offset, 24);

      expect((def.fields[0].type as BaseTypeNode).type, 'string');
      expect(def.fields[0].type.span!.text, 'string');
      expect(def.fields[0].type.span!.start.offset, 26);
      expect(def.fields[0].type.span!.end.offset, 32);

      expect(def.fields[0].identifier.value, 'message');
      expect(def.fields[0].identifier.span!.text, 'message');
      expect(def.fields[0].identifier.span!.start.offset, 33);
      expect(def.fields[0].identifier.span!.end.offset, 40);

      expect(def.fields[1].fieldId, isNotNull);
      expect(def.fields[1].fieldId!.value, '2');
      expect(def.fields[1].fieldId!.span!.text, '2');
      expect(def.fields[1].fieldId!.span!.start.offset, 42);
      expect(def.fields[1].fieldId!.span!.end.offset, 43);

      expect((def.fields[1].type as BaseTypeNode).type, 'i32');
      expect(def.fields[1].type.span!.text, 'i32');
      expect(def.fields[1].type.span!.start.offset, 45);
      expect(def.fields[1].type.span!.end.offset, 48);

      expect(def.fields[1].identifier.value, 'code');
      expect(def.fields[1].identifier.span!.text, 'code');
      expect(def.fields[1].identifier.span!.start.offset, 49);
      expect(def.fields[1].identifier.span!.end.offset, 53);
    });

    test('should parse exception with required fields', () {
      const source =
          'exception AuthError '
          '{ required string username; required i32 code; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ExceptionDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 68);

      expect(def.identifier.value, 'AuthError');
      expect(def.identifier.span!.text, 'AuthError');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 19);

      expect(def.fields, hasLength(2));

      expect(def.fields[0].fieldId, isNull);
      expect(def.fields[0].requirement!.value, 'required');
      expect(def.fields[0].requirement!.span!.text, 'required');
      expect(def.fields[0].requirement!.span!.start.offset, 22);
      expect(def.fields[0].requirement!.span!.end.offset, 30);

      expect((def.fields[0].type as BaseTypeNode).type, 'string');
      expect(def.fields[0].type.span!.text, 'string');
      expect(def.fields[0].type.span!.start.offset, 31);
      expect(def.fields[0].type.span!.end.offset, 37);

      expect(def.fields[0].identifier.value, 'username');
      expect(def.fields[0].identifier.span!.text, 'username');
      expect(def.fields[0].identifier.span!.start.offset, 38);
      expect(def.fields[0].identifier.span!.end.offset, 46);

      expect(def.fields[1].fieldId, isNull);
      expect(def.fields[1].requirement!.value, 'required');
      expect(def.fields[1].requirement!.span!.text, 'required');
      expect(def.fields[1].requirement!.span!.start.offset, 48);
      expect(def.fields[1].requirement!.span!.end.offset, 56);

      expect((def.fields[1].type as BaseTypeNode).type, 'i32');
      expect(def.fields[1].type.span!.text, 'i32');
      expect(def.fields[1].type.span!.start.offset, 57);
      expect(def.fields[1].type.span!.end.offset, 60);

      expect(def.fields[1].identifier.value, 'code');
      expect(def.fields[1].identifier.span!.text, 'code');
      expect(def.fields[1].identifier.span!.start.offset, 61);
      expect(def.fields[1].identifier.span!.end.offset, 65);
    });
  });
}
