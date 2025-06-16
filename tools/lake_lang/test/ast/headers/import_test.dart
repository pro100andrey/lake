import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('Import AST', () {
    test('should parse simple import', () {
      const source = 'import "foo.lake"';
      final doc = parseAstFromString(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span, hasSpan(0, 17));

      expect(import.path.rawValue, '"foo.lake"');
      expect(import.path.value, 'foo.lake');
      expect(import.path.span, hasSpan(7, 17));
    });

    test('should parse import with single quotes', () {
      const source = "import 'bar.lake'";
      final doc = parseAstFromString(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span, hasSpan(0, 17));

      expect(import.path.rawValue, "'bar.lake'");
      expect(import.path.value, 'bar.lake');
      expect(import.path.span, hasSpan(7, 17));
    });

    test('should parse import with whitespace', () {
      const source = '  import   "baz.lake"   ';
      final doc = parseAstFromString(source);
      final import = doc.headers.first as ImportNode;

      expect(import.span, hasSpan(2, 21));

      expect(import.path.rawValue, '"baz.lake"');
      expect(import.path.value, 'baz.lake');
      expect(import.path.span, hasSpan(11, 21));
    });

    test('should parse multiple imports', () {
      const source = 'import "a.lake"\nimport "b.lake"';
      final doc = parseAstFromString(source);

      final import1 = doc.headers[0] as ImportNode;
      expect(import1.span, hasSpan(0, 15));

      expect(import1.path.rawValue, '"a.lake"');
      expect(import1.path.value, 'a.lake');
      expect(import1.path.span, hasSpan(7, 15));

      final import2 = doc.headers[1] as ImportNode;
      expect(import2.span, hasSpan(16, 31));

      expect(import2.path.rawValue, '"b.lake"');
      expect(import2.path.value, 'b.lake');
      expect(import2.path.span, hasSpan(23, 31));
    });

    test('should parse import with path containing directories', () {
      const source = 'import "../common/types/enums.lake"';
      final doc = parseAstFromString(source);

      final import = doc.headers.first as ImportNode;
      expect(import.span, hasSpan(0, 35));

      expect(import.path.rawValue, '"../common/types/enums.lake"');
      expect(import.path.value, '../common/types/enums.lake');
      expect(import.path.span, hasSpan(7, 35));
    });
  });

  group('Import AST (equivalence)', () {
    test('should be equivalent to another import', () {
      const source1 = 'import "foo.lake"';
      const source2 = 'import "foo.lake"';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      final import1 = doc1.headers.first as ImportNode;
      final import2 = doc2.headers.first as ImportNode;

      expect(import1, import2);
    });

    test('should not be equivalent to different import', () {
      const source1 = 'import "foo.lake"';
      const source2 = 'import "bar.lake"';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      final import1 = doc1.headers.first as ImportNode;
      final import2 = doc2.headers.first as ImportNode;

      expect(import1, isNot(equals(import2)));
    });
  });
}
