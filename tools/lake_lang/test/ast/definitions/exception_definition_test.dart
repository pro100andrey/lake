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

      expect((field1.type as BaseTypeNode).type, 'string');
      expect(field1.identifier.value, 'message');

      expect((field2.type as BaseTypeNode).type, 'i32');
      expect(field2.identifier.value, 'code');

      expect(
        def.span!.text,
        'exception MyException { string message; i32 code; }',
      );
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 51);
    });
  });
}
