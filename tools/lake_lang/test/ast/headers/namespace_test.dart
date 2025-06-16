import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('Namespace AST', () {
    test('should parse simple namespace with *', () {
      const source = 'namespace * Foo';
      final doc = parseAstFromString(source);

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span, hasSpan(0, 15));

      expect(ns.scope.value, '*');
      expect(ns.scope.span, hasSpan(10, 11));

      expect(ns.identifier.value, 'Foo');
      expect(ns.identifier.span, hasSpan(12, 15));
    });

    test('should parse namespace with js scope', () {
      const source = 'namespace js example';
      final doc = parseAstFromString(source);

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span, hasSpan(0, 20));

      expect(ns.scope.value, 'js');
      expect(ns.scope.span, hasSpan(10, 12));

      expect(ns.identifier.value, 'example');
      expect(ns.identifier.span, hasSpan(13, 20));
    });

    test('should parse namespace with dart scope and dotted identifier', () {
      const source = 'namespace dart com.example.api.gen';
      final doc = parseAstFromString(source);

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span, hasSpan(0, 34));

      expect(ns.scope.value, 'dart');
      expect(ns.scope.span, hasSpan(10, 14));

      expect(ns.identifier.value, 'com.example.api.gen');
      expect(ns.identifier.span, hasSpan(15, 34));
    });

    test('should parse multiple namespaces', () {
      const source = 'namespace js foo\nnamespace dart bar';
      final doc = parseAstFromString(source);

      final ns1 = doc.headers[0] as NamespaceNode;
      expect(ns1.span, hasSpan(0, 16));

      expect(ns1.scope.value, 'js');
      expect(ns1.scope.span, hasSpan(10, 12));

      expect(ns1.identifier.value, 'foo');
      expect(ns1.identifier.span, hasSpan(13, 16));

      final ns2 = doc.headers[1] as NamespaceNode;
      expect(ns2.span, hasSpan(17, 35));

      expect(ns2.scope.value, 'dart');
      expect(ns2.scope.span, hasSpan(27, 31));

      expect(ns2.identifier.value, 'bar');
      expect(ns2.identifier.span, hasSpan(32, 35));
    });

    test('should parse namespace with whitespace', () {
      const source = '  namespace   js   foo  ';
      final doc = parseAstFromString(source);

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span, hasSpan(2, 22));

      expect(ns.scope.value, 'js');
      expect(ns.scope.span, hasSpan(14, 16));

      expect(ns.identifier.value, 'foo');
      expect(ns.identifier.span, hasSpan(19, 22));
    });
  });

  group('Namespace AST (equivalence)', () {
    test('should be equivalent to another namespace', () {
      const source1 = 'namespace js foo';
      const source2 = 'namespace js foo';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      final ns1 = doc1.headers.first as NamespaceNode;
      final ns2 = doc2.headers.first as NamespaceNode;

      expect(ns1, equals(ns2));
      expect(ns1.scope, equals(ns2.scope));
      expect(ns1.identifier, equals(ns2.identifier));
    });

    test('should not be equivalent to different namespace', () {
      const source1 = 'namespace js foo';
      const source2 = 'namespace dart bar';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      final ns1 = doc1.headers.first as NamespaceNode;
      final ns2 = doc2.headers.first as NamespaceNode;

      expect(ns1, isNot(equals(ns2)));
      expect(ns1.scope, isNot(equals(ns2.scope)));
      expect(ns1.identifier, isNot(equals(ns2.identifier)));
    });
  });
}
