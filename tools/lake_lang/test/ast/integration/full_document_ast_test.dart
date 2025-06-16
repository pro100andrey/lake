import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('Full Document AST', () {
    final ast = parseAstFromFile(
      'test/ast/integration/test_data/full_document_ast_test.lake',
    );

    test(
      'should parse the document successfully and check root properties',
      () {
        expect(ast.headers.length, 3);
        expect(ast.definitions.length, 22);
        expect(ast.span.start, 22);
        expect(ast.span.end, 2472);
      },
    );

    test('should correctly parse import header', () {
      final importHeader = ast.headers[0] as ImportNode;
      expect(importHeader.span.start, 22);
      expect(importHeader.span.end, 48);

      expect(importHeader.path.value, 'common/types.lake');
      expect(importHeader.path.span.start, 29);
      expect(importHeader.path.span.end, 48);
    });

    test('should correctly parse first namespace header (dart core_utils)', () {
      final namespace = ast.headers[1] as NamespaceNode;
      expect(namespace.span.start, 50);
      expect(namespace.span.end, 75);

      expect(namespace.scope.value, 'dart');
      expect(namespace.scope.span.start, 60);
      expect(namespace.scope.span.end, 64);

      expect(namespace.identifier.value, 'core_utils');
      expect(namespace.identifier.span.start, 65);
      expect(namespace.identifier.span.end, 75);
    });

    test(
      'should correctly parse second namespace header (js web_components)',
      () {
        final namespace = ast.headers[2] as NamespaceNode;

        expect(namespace.span, hasSpan(76, 103));

        expect(namespace.scope.value, 'js');
        expect(namespace.scope.span, hasSpan(86, 88));

        expect(namespace.identifier.value, 'web_components');
        expect(namespace.identifier.span, hasSpan(89, 103));
      },
    );

    test('should parse i32 MAX_USERS constant', () {
      final constant = ast.definitions[0] as ConstDefinitionNode;
      expect(constant.span, hasSpan(129, 156));

      final type = constant.type as BaseTypeNode;
      expect(type.value, 'i32');
      expect(type.span, hasSpan(135, 138));

      expect(constant.identifier.value, 'MAX_USERS');
      expect(constant.identifier.span, hasSpan(139, 148));

      final value = constant.value as IntConstantNode;
      expect(value.value, 1000);
      expect(value.span, hasSpan(151, 155));
    });

    test('should parse string ADMIN_EMAIL constant', () {
      final constant = ast.definitions[1] as ConstDefinitionNode;
      expect(constant.span, hasSpan(158, 205));

      final type = constant.type as BaseTypeNode;
      expect(type.value, 'string');
      expect(type.span, hasSpan(164, 170));

      expect(constant.identifier.value, 'ADMIN_EMAIL');
      expect(constant.identifier.span, hasSpan(171, 182));

      final value = constant.value as LiteralNode;
      expect(value.value, 'admin@example.com');
      expect(value.span, hasSpan(185, 204));
    });
  });
}
