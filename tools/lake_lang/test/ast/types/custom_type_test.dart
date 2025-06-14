import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('CustomType AST', () {
    test('should parse custom type when used as a struct field', () {
      const source = 'CustomType';
      final doc = parseAst('struct Data { $source x; }');
      final def = doc.definitions.first as StructDefinitionNode;
      final fieldType = def.fields[0].type as CustomTypeNode;

      expect(fieldType.value, 'CustomType');
      expect(fieldType.span.text, source);
      expect(fieldType.span.start.offset, 14);
      expect(fieldType.span.end.offset, 24);
    });

    test('should parse custom in service', () {
      const source = 'CustomType';
      final doc = parseAst('service MyService { $source getData(); }');
      final def = doc.definitions.first as ServiceDefinitionNode;
      final function1 = def.functions.first;

      expect((function1.returnType as CustomTypeNode).value, 'CustomType');
      expect(function1.returnType.span.text, source);
      expect(function1.returnType.span.start.offset, 20);
      expect(function1.returnType.span.end.offset, 30);
    });
  });

  group('CustomType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'CustomType';
      final doc1 = parseAst('struct S { $source x; }');
      final doc2 = parseAst('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAst('struct S { CustomType x; }');
      final doc2 = parseAst('struct S { AnotherType x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
