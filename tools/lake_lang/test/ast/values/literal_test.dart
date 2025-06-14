import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Literal AST', () {
    test('should parse string literal as StringConstantNode', () {
      const source = '"hello"';
      final doc = parseAst('struct S { string field = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final literal = struct.fields.first.defaultValue! as LiteralNode;

      expect(literal.value, 'hello');
      expect(literal.rawValue, '"hello"');
      expect(literal.span.text, source);
      expect(literal.span.start.offset, 26);
      expect(literal.span.end.offset, 33);
    });

    test('should parse constant map literal as ConstMapNode', () {
      const source = '{"key": "value"}';
      final doc = parseAst('struct S { map<string, string> field = $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final map = struct.fields.first.defaultValue! as ConstMapNode;

      final key = map.entries.first.key as LiteralNode;
      expect(key.value, 'key');
      expect(key.rawValue, '"key"');
      expect(key.span.text, '"key"');
      expect(key.span.start.offset, 40);
      expect(key.span.end.offset, 45);

      final value = map.entries.first.value as LiteralNode;
      expect(value.value, 'value');
      expect(value.rawValue, '"value"');
      expect(value.span.text, '"value"');
      expect(value.span.start.offset, 47);
      expect(value.span.end.offset, 54);
    });
  });

  group('Literal AST (equality)', () {
    test(
      'should consider string literals equal if they have the same value',
      () {
        const source1 = '"hello"';
        const source2 = '"hello"';
        final doc1 = parseAst('struct S { string field = $source1; }');
        final doc2 = parseAst('struct S { string field = $source2; }');

        expect(doc1, equals(doc2));

        final struct1 = doc1.definitions.first as StructDefinitionNode;
        final struct2 = doc2.definitions.first as StructDefinitionNode;

        expect(struct1, equals(struct2));

        final literal1 = struct1.fields.first.defaultValue! as LiteralNode;
        final literal2 = struct2.fields.first.defaultValue! as LiteralNode;

        expect(literal1, equals(literal2));
      },
    );

    test(
      'should consider string literals not equal if they have different values',
      () {
        const source1 = '"hello"';
        const source2 = '"world"';
        final doc1 = parseAst('struct S { string field = $source1; }');
        final doc2 = parseAst('struct S { string field = $source2; }');

        expect(doc1, isNot(equals(doc2)));

        final struct1 = doc1.definitions.first as StructDefinitionNode;
        final struct2 = doc2.definitions.first as StructDefinitionNode;

        expect(struct1, isNot(equals(struct2)));

        final literal1 = struct1.fields.first.defaultValue! as LiteralNode;
        final literal2 = struct2.fields.first.defaultValue! as LiteralNode;

        expect(literal1, isNot(equals(literal2)));
      },
    );
  });
}
