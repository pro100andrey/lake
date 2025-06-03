import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Document Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [1] Document ::=  Header* Definition*
    final parser = resolve(grammar.document().end());

    // Positive cases

    test('should parse empty document', () {
      final result = parser.parse('');
      expect(result, isA<Success>());
    });

    test('should parse document with only import', () {
      final result = parser.parse('import "foo.lake"');
      expect(result, isA<Success>());
    });

    test('should parse document with only namespace', () {
      final result = parser.parse('namespace * Foo');
      expect(result, isA<Success>());
    });

    test('should parse document with multiple headers', () {
      final result = parser.parse('import "foo.lake"\nnamespace dart Bar');
      expect(result, isA<Success>());
    });

    test('should parse document with const definition', () {
      final result = parser.parse('const i32 X = 1');
      expect(result, isA<Success>());
    });

    test('should parse document with enum definition', () {
      final result = parser.parse('enum E { A, B }');
      expect(result, isA<Success>());
    });

    test('should parse document with struct definition', () {
      final result = parser.parse('struct S { i32 x }');
      expect(result, isA<Success>());
    });

    test('should parse document with service definition', () {
      final result = parser.parse('service S { void foo() }');
      expect(result, isA<Success>());
    });

    test('should parse document with multiple definitions', () {
      final result = parser.parse(
        'const i32 X = 1\nenum E { A }\nstruct S { i32 x }',
      );
      expect(result, isA<Success>());
    });

    test('should parse document with headers and definitions', () {
      final result = parser.parse(
        'import "foo.lake"\nnamespace js Foo\nconst i32 X = 1',
      );
      expect(result, isA<Success>());
    });

    test('should parse document with whitespace and newlines', () {
      final result = parser.parse('  \nimport "foo.lake"\n\nconst i32 X = 1\n');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse invalid header', () {
      final result = parser.parse('invalidheader "foo"');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid definition', () {
      final result = parser.parse('const = 1');
      expect(result, isA<Failure>());
    });

    test('should fail to parse random text', () {
      final result = parser.parse('random text');
      expect(result, isA<Failure>());
    });
  });
}
