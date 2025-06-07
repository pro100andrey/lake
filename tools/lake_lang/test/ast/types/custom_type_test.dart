import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('CustomType AST', () {
    test('should parse custom type when used as a struct field', () {
      const source = 'CustomType';
      final doc = parseAst('struct Data { $source x; }');

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as StructDefinitionNode;
      expect((def.fields[0].type as CustomTypeNode).value, 'CustomType');

      expect(def.fields[0].type.span!.text, source);
      expect(def.fields[0].type.span!.start.offset, 14);
      expect(def.fields[0].type.span!.end.offset, 24);
    });
  });
}
