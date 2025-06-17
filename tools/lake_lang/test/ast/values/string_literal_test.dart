import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('StringLiteral AST', () {
    test('should parse string literal as StringLiteralNode', () {
      const source = '"hello"';
      final doc = parseAstFromString('struct S { string field = $source; }');
      final struct = doc.definitions.first.cast<StructDefinitionNode>();

      final literal = struct.fields.first.defaultValue!
          .cast<StringLiteralNode>();
      expect(literal.value, 'hello');
      expect(literal.rawValue, '"hello"');
      expect(literal.span, hasSpan(26, 33));
    });

    test('should parse map literal as MapLiteralNode', () {
      const source = '{"key": "value"}';
      final doc = parseAstFromString(
        'struct S { map<string, string> field = $source; }',
      );
      final struct = doc.definitions.first.cast<StructDefinitionNode>();

      final map = struct.fields.first.defaultValue!.cast<MapLiteralNode>();

      final key = map.entries.first.key.cast<StringLiteralNode>();
      expect(key.value, 'key');
      expect(key.rawValue, '"key"');
      expect(key.span, hasSpan(40, 45));

      final value = map.entries.first.value.cast<StringLiteralNode>();
      expect(value.value, 'value');
      expect(value.rawValue, '"value"');
      expect(value.span, hasSpan(47, 54));
    });
  });

  group('StringLiteral AST (equality)', () {
    test(
      'should consider string literals equal if they have the same value',
      () {
        const source1 = '"hello"';
        const source2 = '"hello"';
        final doc1 = parseAstFromString(
          'struct S { string field = $source1; }',
        );
        final doc2 = parseAstFromString(
          'struct S { string field = $source2; }',
        );

        expect(doc1, equals(doc2));

        final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
        final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

        expect(struct1, equals(struct2));

        final literal1 = struct1.fields.first.defaultValue!
            .cast<StringLiteralNode>();
        final literal2 = struct2.fields.first.defaultValue!
            .cast<StringLiteralNode>();

        expect(literal1, equals(literal2));
      },
    );

    test(
      'should consider string literals not equal if they have different values',
      () {
        const source1 = '"hello"';
        const source2 = '"world"';
        final doc1 = parseAstFromString(
          'struct S { string field = $source1; }',
        );
        final doc2 = parseAstFromString(
          'struct S { string field = $source2; }',
        );

        expect(doc1, isNot(equals(doc2)));

        final struct1 = doc1.definitions.first.cast<StructDefinitionNode>();
        final struct2 = doc2.definitions.first.cast<StructDefinitionNode>();

        expect(struct1, isNot(equals(struct2)));

        final literal1 = struct1.fields.first.defaultValue!
            .cast<StringLiteralNode>();
        final literal2 = struct2.fields.first.defaultValue!
            .cast<StringLiteralNode>();

        expect(literal1, isNot(equals(literal2)));
      },
    );
  });
}
