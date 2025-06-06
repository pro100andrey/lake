import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('TypedefDefinition AST', () {
    test('should parse simple typedef with base type', () {
      const source = 'typedef i32 MyInt;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as TypedefDefinitionNode;
      expect(def.span!.text, source);
      expect(def.span!.start.offset, 0);
      expect(def.span!.end.offset, 18);

      expect((def.type as BaseTypeNode).type, 'i32');
      expect(def.type.span!.text, 'i32');
      expect(def.type.span!.start.offset, 8);
      expect(def.type.span!.end.offset, 11);

      expect(def.identifier.value, 'MyInt');
      expect(def.identifier.span!.text, 'MyInt');
      expect(def.identifier.span!.start.offset, 12);
      expect(def.identifier.span!.end.offset, 17);
    });

    

  });
}
