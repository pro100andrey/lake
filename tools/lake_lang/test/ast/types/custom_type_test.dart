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
}
