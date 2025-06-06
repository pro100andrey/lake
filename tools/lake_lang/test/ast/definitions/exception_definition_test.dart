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

      expect(def.identifier.value, 'MyException');
      expect(def.fields, isEmpty);

      expect(def.span!.text, 'exception MyException {}');
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 24);

      expect(def.identifier.span!.text, 'MyException');
      expect(def.identifier.span!.start.offset, 10);
      expect(def.identifier.span!.end.offset, 21);
    });

    test('should parse exception with fields without field index', () {
      const source = 'exception MyException { string message; i32 code; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.identifier.value, 'MyException');
      expect(def.fields, hasLength(2));

      final field1 = def.fields[0];
      final field2 = def.fields[1];

      expect(field1.fieldId, isNull);

      expect((field1.type as BaseTypeNode).type, 'string');
      expect(field1.type.span!.start.offset, 24);
      expect(field1.type.span!.end.offset, 30);

      expect(field1.identifier.value, 'message');
      expect(field1.identifier.span!.start.offset, 31);
      expect(field1.identifier.span!.end.offset, 38);

      expect(field2.fieldId, isNull);

      expect((field2.type as BaseTypeNode).type, 'i32');
      expect(field2.type.span!.start.offset, 40);
      expect(field2.type.span!.end.offset, 43);

      expect(field2.identifier.value, 'code');
      expect(field2.identifier.span!.start.offset, 44);
      expect(field2.identifier.span!.end.offset, 48);

      expect(
        def.span!.text,
        'exception MyException { string message; i32 code; }',
      );
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 51);
    });

    test('should parse exception with fields with field index', () {
      const source = 'exception MyException {1: string message; 2: i32 code; }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));
      final def = doc.definitions.first as ExceptionDefinitionNode;

      expect(def.identifier.value, 'MyException');
      expect(def.fields, hasLength(2));

      final field1 = def.fields[0];
      final field2 = def.fields[1];

      expect(field1.fieldId!.value, '1');
      expect(field1.fieldId!.span!.start.offset, 23);
      expect(field1.fieldId!.span!.end.offset, 24);
      
      expect((field1.type as BaseTypeNode).type, 'string');
      expect(field1.type.span!.start.offset, 26);
      expect(field1.type.span!.end.offset, 32);

      expect(field1.identifier.value, 'message');
      expect(field1.identifier.span!.start.offset, 33);
      expect(field1.identifier.span!.end.offset, 40);

      expect(field2.fieldId!.value, '2');
      expect(field2.fieldId!.span!.start.offset, 42);
      expect(field2.fieldId!.span!.end.offset, 43);

      expect((field2.type as BaseTypeNode).type, 'i32');
      expect(field2.type.span!.start.offset, 45);
      expect(field2.type.span!.end.offset, 48);
      
      expect(field2.identifier.value, 'code');
      expect(field2.identifier.span!.start.offset, 49);
      expect(field2.identifier.span!.end.offset, 53);

      expect(
        def.span!.text,
        'exception MyException {1: string message; 2: i32 code; }',
      );
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 56);
    });
  });
}
