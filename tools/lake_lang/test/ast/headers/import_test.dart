import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Import AST', () {
    test('should parse simple import', () {
      const source = 'import "foo.lake"';
      final doc = parseAst(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span.text, source);
      expect(import.span.start.offset, 0);
      expect(import.span.end.offset, 17);

      expect(import.path.value, '"foo.lake"');
      expect(import.path.span.text, '"foo.lake"');
      expect(import.path.span.start.offset, 7);
      expect(import.path.span.end.offset, 17);
    });

    test('should parse import with single quotes', () {
      const source = "import 'bar.lake'";
      final doc = parseAst(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span.text, source);
      expect(import.span.start.offset, 0);
      expect(import.span.end.offset, 17);

      expect(import.path.value, "'bar.lake'");
      expect(import.path.span.text, "'bar.lake'");
      expect(import.path.span.start.offset, 7);
      expect(import.path.span.end.offset, 17);
    });

    test('should parse import with whitespace', () {
      const source = '  import   "baz.lake"   ';
      final doc = parseAst(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span.text, 'import   "baz.lake"');
      expect(import.span.start.offset, 2);
      expect(import.span.end.offset, 21);

      expect(import.path.value, '"baz.lake"');
      expect(import.path.span.text, '"baz.lake"');
      expect(import.path.span.start.offset, 11);
      expect(import.path.span.end.offset, 21);
    });

    test('should parse multiple imports', () {
      const source = 'import "a.lake"\nimport "b.lake"';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(2));

      final import1 = doc.headers[0] as ImportNode;
      expect(import1.span.text, 'import "a.lake"');
      expect(import1.span.start.offset, 0);
      expect(import1.span.end.offset, 15);

      expect(import1.path.value, '"a.lake"');
      expect(import1.path.span.text, '"a.lake"');
      expect(import1.path.span.start.offset, 7);
      expect(import1.path.span.end.offset, 15);

      final import2 = doc.headers[1] as ImportNode;
      expect(import2.span.text, 'import "b.lake"');
      expect(import2.span.start.offset, 16);
      expect(import2.span.end.offset, 31);

      expect(import2.path.value, '"b.lake"');
      expect(import2.path.span.text, '"b.lake"');
      expect(import2.path.span.start.offset, 23);
      expect(import2.path.span.end.offset, 31);
    });

    test('should parse import with path containing directories', () {
      const source = 'import "../common/types/enums.lake"';
      final doc = parseAst(source);

      expect(doc.headers, hasLength(1));

      final import = doc.headers.first as ImportNode;
      expect(import.span.text, source);
      expect(import.span.start.offset, 0);
      expect(import.span.end.offset, 35);

      expect(import.path.value, '"../common/types/enums.lake"');
      expect(import.path.span.text, '"../common/types/enums.lake"');
      expect(import.path.span.start.offset, 7);
      expect(import.path.span.end.offset, 35);
    });
  });
}
