import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.serviceDefinition().end());
  group('ServiceDefinition grammar (positive):', () {
    test('should parse empty service', () {
      final result = parser.parse('service MyService {}');
      final [
        Token keyword,
        Token id,
        _,
        Token ld,
        List functions,
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'service');
      expect(id.value, 'MyService');
      expect(ld.value, '{');
      expect(functions, isEmpty);
      expect(rd.value, '}');
    });

    test('should parse service with one method', () {
      final result = parser.parse('service S { void foo() }');
      final [
        Token keyword,
        Token id,
        _,
        Token ld,
        [
          [Token t, Token id1, Token ld1, List args, Token rd1, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'service');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t.value, 'void');
      expect(id1.value, 'foo');
      expect(ld1.value, '(');
      expect(args, isEmpty);
      expect(rd1.value, ')');
      expect(rd.value, '}');
    });

    test('should parse service with multiple functions', () {
      final result = parser.parse('service S { void foo(); i32 bar(i32 x); }');
      final [
        Token keyword,
        Token id,
        _,
        Token ld,
        [
          [Token t, Token id1, Token ld1, List args, Token rd1, _, _],
          [Token t1, Token id2, Token ld2, List args1, Token rd2, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'service');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t.value, 'void');
      expect(id1.value, 'foo');
      expect(ld1.value, '(');
      expect(args, isEmpty);
      expect(rd1.value, ')');
      expect(t1.value, 'i32');
      expect(id2.value, 'bar');
      expect(ld2.value, '(');
      expect(args1.length, 1);
      expect(rd2.value, ')');
      expect(rd.value, '}');
    });

    test('should parse service with extends', () {
      final result = parser.parse('service S extends Base { void foo() }');
      final [
        Token keyword,
        Token id,
        [Token keyword1, Token baseId],
        Token ld,
        [
          [Token t, Token id1, Token ld1, List args, Token rd1, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'service');
      expect(id.value, 'S');
      expect(keyword1.value, 'extends');
      expect(baseId.value, 'Base');
      expect(ld.value, '{');
      expect(t.value, 'void');
      expect(id1.value, 'foo');
      expect(ld1.value, '(');
      expect(args, isEmpty);
      expect(rd1.value, ')');
      expect(rd.value, '}');
    });

    test('should parse service with whitespace', () {
      final result = parser.parse('  service   S   {   void foo ( ) ;   }  ');
      final [
        Token keyword,
        Token id,
        _,
        Token ld,
        [
          [Token t, Token id1, Token ld1, List args, Token rd1, _, _],
        ],
        Token rd,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'service');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t.value, 'void');
      expect(id1.value, 'foo');
      expect(ld1.value, '(');
      expect(args, isEmpty);
      expect(rd1.value, ')');
      expect(rd.value, '}');
    });

    test('should parse service with trailing comma in method', () {
      final result = parser.parse('service S { void foo(), }');
      expect(result, isA<Success>());
      final [
        Token keyword,
        Token id,
        _,
        Token ld,
        [
          [Token t, Token id1, Token ld1, List args, Token rd1, _, Token sep],
        ],
        Token rd,
      ] = result.value as List;

      expect(keyword.value, 'service');
      expect(id.value, 'S');
      expect(ld.value, '{');
      expect(t.value, 'void');
      expect(id1.value, 'foo');
      expect(ld1.value, '(');
      expect(args, isEmpty);
      expect(sep.value, ',');
      expect(rd1.value, ')');
      expect(rd.value, '}');
    });
  });

  group('ServiceDefinition grammar (negative):', () {
    test('should fail to parse missing service keyword', () {
      final result = parser.parse('S { void foo() }');

      expect(result, isA<Failure>());
      expect(result.message, '"service" expected');
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('service { void foo() }');

      expect(result, isA<Failure>());
      expect(result.message, '"letter" or "_" for start identifier expected');
    });

    test('should fail to parse missing braces', () {
      final result = parser.parse('service S void foo()');

      expect(result, isA<Failure>());
      expect(result.message, '"{" expected');
    });

    test('should fail to parse invalid method', () {
      final result = parser.parse('service S { foo }');

      expect(result, isA<Failure>());
      expect(result.message, '"}" expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, '"service" expected');
    });
  });
}
