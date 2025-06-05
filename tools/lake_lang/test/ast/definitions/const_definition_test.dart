import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ConstDefinition AST', () {
    test('should parse simple int constant', () {
      const source = 'const i32 myInt = 42;';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ConstDefinitionNode;
      
      expect(def.name.value, 'myInt');
      expect((def.type as BaseTypeNode).value, 'i32');
      expect((def.value as IntConstantNode).value, '42');
    });
  });
}
