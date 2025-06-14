import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Namespace AST', () {
    test('should parse simple namespace with *', () {
      const source = 'namespace * Foo';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(1));

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span.text, source);
      expect(ns.span.start.offset, 0);
      expect(ns.span.end.offset, 15);

      expect(ns.scope.value, '*');
      expect(ns.scope.span.text, '*');
      expect(ns.scope.span.start.offset, 10);
      expect(ns.scope.span.end.offset, 11);

      expect(ns.identifier.value, 'Foo');
      expect(ns.identifier.span.text, 'Foo');
      expect(ns.identifier.span.start.offset, 12);
      expect(ns.identifier.span.end.offset, 15);
    });

    test('should parse namespace with js scope', () {
      const source = 'namespace js example';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(1));

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span.text, source);
      expect(ns.span.start.offset, 0);
      expect(ns.span.end.offset, 20);

      expect(ns.scope.value, 'js');
      expect(ns.scope.span.text, 'js');
      expect(ns.scope.span.start.offset, 10);
      expect(ns.scope.span.end.offset, 12);

      expect(ns.identifier.value, 'example');
      expect(ns.identifier.span.text, 'example');
      expect(ns.identifier.span.start.offset, 13);
      expect(ns.identifier.span.end.offset, 20);
    });

    test('should parse namespace with dart scope and dotted identifier', () {
      const source = 'namespace dart com.example.api.gen';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(1));

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span.text, source);
      expect(ns.span.start.offset, 0);
      expect(ns.span.end.offset, 34);

      expect(ns.scope.value, 'dart');
      expect(ns.scope.span.text, 'dart');
      expect(ns.scope.span.start.offset, 10);
      expect(ns.scope.span.end.offset, 14);

      expect(ns.identifier.value, 'com.example.api.gen');
      expect(ns.identifier.span.text, 'com.example.api.gen');
      expect(ns.identifier.span.start.offset, 15);
      expect(ns.identifier.span.end.offset, 34);
    });

    test('should parse multiple namespaces', () {
      const source = 'namespace js foo\nnamespace dart bar';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(2));

      final ns1 = doc.headers[0] as NamespaceNode;
      expect(ns1.span.text, 'namespace js foo');
      expect(ns1.span.start.offset, 0);
      expect(ns1.span.end.offset, 16);

      expect(ns1.scope.value, 'js');
      expect(ns1.scope.span.text, 'js');
      expect(ns1.scope.span.start.offset, 10);
      expect(ns1.scope.span.end.offset, 12);

      expect(ns1.identifier.value, 'foo');
      expect(ns1.identifier.span.text, 'foo');
      expect(ns1.identifier.span.start.offset, 13);
      expect(ns1.identifier.span.end.offset, 16);

      final ns2 = doc.headers[1] as NamespaceNode;
      expect(ns2.span.text, 'namespace dart bar');
      expect(ns2.span.start.offset, 17);
      expect(ns2.span.end.offset, 35);

      expect(ns2.scope.value, 'dart');
      expect(ns2.scope.span.text, 'dart');
      expect(ns2.scope.span.start.offset, 27);
      expect(ns2.scope.span.end.offset, 31);

      expect(ns2.identifier.value, 'bar');
      expect(ns2.identifier.span.text, 'bar');
      expect(ns2.identifier.span.start.offset, 32);
      expect(ns2.identifier.span.end.offset, 35);
    });

    test('should parse namespace with whitespace', () {
      const source = '  namespace   js   foo  ';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(1));

      final ns = doc.headers.first as NamespaceNode;
      expect(ns.span.text, 'namespace   js   foo');
      expect(ns.span.start.offset, 2);
      expect(ns.span.end.offset, 22);

      expect(ns.scope.value, 'js');
      expect(ns.scope.span.text, 'js');
      expect(ns.scope.span.start.offset, 14);
      expect(ns.scope.span.end.offset, 16);

      expect(ns.identifier.value, 'foo');
      expect(ns.identifier.span.text, 'foo');
      expect(ns.identifier.span.start.offset, 19);
      expect(ns.identifier.span.end.offset, 22);
    });
  });

  group('Namespace AST (equivalence)', () {
    test('should be equivalent to another namespace', () {
      const source1 = 'namespace js foo';
      const source2 = 'namespace js foo';
      final doc1 = parseAst(source1);
      final doc2 = parseAst(source2);

      expect(doc1.headers, hasLength(1));
      expect(doc2.headers, hasLength(1));

      final ns1 = doc1.headers.first as NamespaceNode;
      final ns2 = doc2.headers.first as NamespaceNode;

      expect(ns1, equals(ns2));
      expect(ns1.scope, equals(ns2.scope));
      expect(ns1.identifier, equals(ns2.identifier));
    });

    test('should not be equivalent to different namespace', () {
      const source1 = 'namespace js foo';
      const source2 = 'namespace dart bar';
      final doc1 = parseAst(source1);
      final doc2 = parseAst(source2);

      expect(doc1.headers, hasLength(1));
      expect(doc2.headers, hasLength(1));

      final ns1 = doc1.headers.first as NamespaceNode;
      final ns2 = doc2.headers.first as NamespaceNode;

      expect(ns1, isNot(equals(ns2)));
      expect(ns1.scope, isNot(equals(ns2.scope)));
      expect(ns1.identifier, isNot(equals(ns2.identifier)));
    });
  });
}
