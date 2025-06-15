import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Import AST', () {
    test('should parse simple import', () {
      const source = 'import "foo.lake"';
      final doc = parseAndGetAst(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span.start, 0);
      expect(import.span.end, 17);

      expect(import.path.rawValue, '"foo.lake"');
      expect(import.path.value, 'foo.lake');
      expect(import.path.span.start, 7);
      expect(import.path.span.end, 17);
    });

    test('should parse import with single quotes', () {
      const source = "import 'bar.lake'";
      final doc = parseAndGetAst(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span.start, 0);
      expect(import.span.end, 17);

      expect(import.path.rawValue, "'bar.lake'");
      expect(import.path.value, 'bar.lake');
      expect(import.path.span.start, 7);
      expect(import.path.span.end, 17);
    });

    test('should parse import with whitespace', () {
      const source = '  import   "baz.lake"   ';
      final doc = parseAndGetAst(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span.start, 2);
      expect(import.span.end, 21);

      expect(import.path.rawValue, '"baz.lake"');
      expect(import.path.value, 'baz.lake');
      expect(import.path.span.start, 11);
      expect(import.path.span.end, 21);
    });

    test('should parse multiple imports', () {
      const source = 'import "a.lake"\nimport "b.lake"';
      final doc = parseAndGetAst(source);

      expect(doc.headers, hasLength(2));

      final import1 = doc.headers[0] as ImportNode;
      expect(import1.span.start, 0);
      expect(import1.span.end, 15);

      expect(import1.path.rawValue, '"a.lake"');
      expect(import1.path.value, 'a.lake');
      expect(import1.path.span.start, 7);
      expect(import1.path.span.end, 15);

      final import2 = doc.headers[1] as ImportNode;
      expect(import2.span.start, 16);
      expect(import2.span.end, 31);

      expect(import2.path.rawValue, '"b.lake"');
      expect(import2.path.value, 'b.lake');
      expect(import2.path.span.start, 23);
      expect(import2.path.span.end, 31);
    });

    test('should parse import with path containing directories', () {
      const source = 'import "../common/types/enums.lake"';
      final doc = parseAndGetAst(source);

      expect(doc.headers, hasLength(1));

      final import = doc.headers.first as ImportNode;
      expect(import.span.start, 0);
      expect(import.span.end, 35);

      expect(import.path.rawValue, '"../common/types/enums.lake"');
      expect(import.path.value, '../common/types/enums.lake');
      expect(import.path.span.start, 7);
      expect(import.path.span.end, 35);
    });
  });

  group('Import AST (equivalence)', () {
    test('should be equivalent to another import', () {
      const source1 = 'import "foo.lake"';
      const source2 = 'import "foo.lake"';
      final doc1 = parseAndGetAst(source1);
      final doc2 = parseAndGetAst(source2);

      expect(doc1.headers, hasLength(1));
      expect(doc2.headers, hasLength(1));

      final import1 = doc1.headers.first as ImportNode;
      final import2 = doc2.headers.first as ImportNode;

      expect(import1, import2);
    });

    test('should not be equivalent to different import', () {
      const source1 = 'import "foo.lake"';
      const source2 = 'import "bar.lake"';
      final doc1 = parseAndGetAst(source1);
      final doc2 = parseAndGetAst(source2);

      expect(doc1.headers, hasLength(1));
      expect(doc2.headers, hasLength(1));

      final import1 = doc1.headers.first as ImportNode;
      final import2 = doc2.headers.first as ImportNode;

      expect(import1, isNot(equals(import2)));
    });
  });
}
