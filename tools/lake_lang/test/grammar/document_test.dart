import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.document().end());

  group('Document grammar (positive):', () {
    test('should parse empty document', () {
      final result = parser.parse('');
      final [List headers, List definitions] = result.value as List;

      expect(result, isA<Success>());
      expect(headers, isEmpty);
      expect(definitions, isEmpty);
    });

    test('should parse document with only import', () {
      final result = parser.parse('import "foo.lake"');
      final [
        [
          [Token import, Token id, Token? sep],
        ],
        List definitions,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(import.value, 'import');
      expect(id.value, '"foo.lake"');
      expect(sep, isNull);
      expect(definitions, isEmpty);
    });

    test('should parse document with only namespace', () {
      final result = parser.parse('namespace * Foo');
      final [
        [
          [Token namespace, Token star, Token id, Token? sep],
        ],
        List definitions,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(namespace.value, 'namespace');
      expect(star.value, '*');
      expect(id.value, 'Foo');
      expect(sep, isNull);
      expect(definitions, isEmpty);
    });

    test('should parse document with multiple headers', () {
      final result = parser.parse('import "foo.lake"\nnamespace dart Bar');
      final [
        [
          [Token import, Token importId, Token? importSep],
          [Token namespace, Token scope, Token id, Token? namespaceSep],
        ],
        List definitions,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(import.value, 'import');
      expect(importId.value, '"foo.lake"');
      expect(importSep, isNull);
      expect(namespace.value, 'namespace');
      expect(scope.value, 'dart');
      expect(id.value, 'Bar');
      expect(namespaceSep, isNull);
      expect(definitions, isEmpty);
    });

    test('should parse document with const definition', () {
      final result = parser.parse('const i32 X = 1');
      final [
        List headers,
        [
          [
            Token keyword,
            Token t,
            Token id,
            Token eq,
            Token v,
            Token? sep,
          ],
        ],
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(headers, isEmpty);
      expect(keyword.value, 'const');
      expect(t.value, 'i32');
      expect(id.value, 'X');
      expect(eq.value, '=');
      expect(v.value, '1');
      expect(sep, isNull);
    });

    test('should parse document with enum definition', () {
      final result = parser.parse('enum E { A, B }');
      final [
        List headers,
        [
          [
            Token keyword,
            Token id,
            Token lb,
            [[Token id1, _, _], [Token id2, _, _]],
            Token rb,
          ],
        ],
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(headers, isEmpty);
      expect(keyword.value, 'enum');
      expect(id.value, 'E');
      expect(lb.value, '{');
      expect(id1.value, 'A');
      expect(id2.value, 'B');
      expect(rb.value, '}');
    });

    test('should parse document with struct definition', () {
      final result = parser.parse('struct S { i32 x }');
      final [
        List headers,
        [
          [
            Token keyword,
            Token id,
            Token lb,
            [[_, _, Token t, Token id2, _, _]],
            Token rb,
          ],
        ],
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(headers, isEmpty);
      expect(keyword.value, 'struct');
      expect(id.value, 'S');
      expect(lb.value, '{');
      expect(t.value, 'i32');
      expect(id2.value, 'x');
      expect(rb.value, '}');
    });

    test('should parse document with service definition', () {
      final result = parser.parse('service S { void foo() }');
      final [
        List headers,
        [
          [
            Token keyword,
            Token id,
            _,
            Token lb,
            [
              [
                Token t,
                Token id2,
                Token lb2,
                List fields,
                Token rb2,
                _,
                _,
              ],
            ],
            Token rb,
          ],
        ],
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(headers, isEmpty);
      expect(keyword.value, 'service');
      expect(id.value, 'S');
      expect(lb.value, '{');
      expect(t.value, 'void');
      expect(id2.value, 'foo');
      expect(lb2.value, '(');
      expect(fields, isEmpty);
      expect(rb2.value, ')');
      expect(rb.value, '}');
    });

    test('should parse document with multiple definitions', () {
      final result = parser.parse(
        'const i32 X = 1\nenum E { A }\nstruct S { i32 x }',
      );
      final [
        List headers,
        [List constDef, List enumDef, List structDef],
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(headers, isEmpty);
      expect(constDef, isNotEmpty);
      expect(enumDef, isNotEmpty);
      expect(structDef, isNotEmpty);
    });

    test('should parse document with headers and definitions', () {
      final result = parser.parse(
        'import "foo.lake"\nnamespace js Foo\nconst i32 X = 1',
      );

      final [
        [
          List importHeader,
          List namespaceHeader,
        ],
        [
          List constDef,
        ],
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(importHeader, isNotEmpty);
      expect(namespaceHeader, isNotEmpty);
      expect(constDef, isNotEmpty);
    });

    test('should parse document with whitespace and newlines', () {
      final result = parser.parse('  \nimport "foo.lake"\n\nconst i32 X = 1\n');
      final [[List importHeader], [List constDef]] = result.value as List;

      expect(result, isA<Success>());
      expect(importHeader, isNotEmpty);
      expect(constDef, isNotEmpty);
    });
  });

  group('Document grammar (negative):', () {
    test('should fail to parse invalid header', () {
      final result = parser.parse('invalidheader "foo"');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse invalid definition', () {
      final result = parser.parse('const = 1');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse random text', () {
      final result = parser.parse('random text');

      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });
  });
}
