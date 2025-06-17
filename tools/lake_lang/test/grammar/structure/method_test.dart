import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.method().end());

  group('Method grammar (positive):', () {
    test('should parse method with no arguments', () {
      final result = parser.parse('void foo()');
      final [Token t, Token id, Token ld, List args, Token rd, _, _] =
          result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'void');
      expect(id.value, 'foo');
      expect(ld.value, '(');
      expect(args, isEmpty);
      expect(rd.value, ')');
    });

    test('should parse method with one field argument', () {
      final result = parser.parse('i32 bar(i32 x)');
      final [
        Token t,
        Token id,
        Token ld,
        [[_, _, Token t1, Token id1, _, _]],
        Token rd,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'i32');
      expect(id.value, 'bar');
      expect(ld.value, '(');
      expect(t1.value, 'i32');
      expect(id1.value, 'x');
      expect(rd.value, ')');
    });

    test('should parse method with multiple field arguments', () {
      final result = parser.parse('string baz(i32 x, string y)');
      final [
        Token t,
        Token id,
        Token ld,
        [
          [_, _, Token t1, Token id1, _, _],
          [_, _, Token t2, Token id2, _, _],
        ],
        Token rd,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'string');
      expect(id.value, 'baz');
      expect(ld.value, '(');
      expect(t1.value, 'i32');
      expect(id1.value, 'x');
      expect(t2.value, 'string');
      expect(id2.value, 'y');
      expect(rd.value, ')');
    });

    test('should parse method with stream argument', () {
      final result = parser.parse('void streamFunc(stream<i32> s)');
      final [
        Token t,
        Token id,
        Token ld,
        [
          [
            _,
            _,
            [Token stream, Token lt, Token type, Token gt],
            Token id1,
            _,
            _,
          ],
        ],
        Token rd,
        _,
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'void');
      expect(id.value, 'streamFunc');
      expect(ld.value, '(');
      expect(stream.value, 'stream');
      expect(lt.value, '<');
      expect(type.value, 'i32');
      expect(gt.value, '>');
      expect(id1.value, 's');
      expect(rd.value, ')');
    });

    test('should parse method with throws clause', () {
      final result = parser.parse(
        'void errFunc() '
        'throws ( '
        '1: InvalidArgumentsException invalidArgs, '
        '2: UserNotFoundException userNotFound '
        ')',
      );

      final [
        Token t,
        Token id,
        Token ld,
        List args,
        Token rd,
        [
          Token throws,
          Token ld1,
          [
            [[Token idx1, _], _, Token t1, Token id1, _, _],
            [[Token idx2, _], _, Token t2, Token id2, _, _],
          ],
          Token rd1,
        ],
        _,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'void');
      expect(id.value, 'errFunc');
      expect(ld.value, '(');
      expect(args, isEmpty);
      expect(rd.value, ')');
      expect(throws.value, 'throws');
      expect(ld1.value, '(');
      expect(idx1.value, '1');
      expect(t1.value, 'InvalidArgumentsException');
      expect(id1.value, 'invalidArgs');
      expect(idx2.value, '2');
      expect(t2.value, 'UserNotFoundException');
      expect(id2.value, 'userNotFound');
      expect(rd1.value, ')');
    });

    test('should parse method with trailing comma', () {
      final result = parser.parse('void foo(),');
      final [Token t, Token id, Token ld, List args, Token rd, _, Token sep] =
          result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'void');
      expect(id.value, 'foo');
      expect(ld.value, '(');
      expect(args, isEmpty);
      expect(rd.value, ')');
      expect(sep.value, ',');
    });

    test('should parse method with trailing semicolon', () {
      final result = parser.parse('void foo();');
      final [Token t, Token id, Token ld, List args, Token rd, _, Token sep] =
          result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'void');
      expect(id.value, 'foo');
      expect(ld.value, '(');
      expect(args, isEmpty);
      expect(rd.value, ')');
      expect(sep.value, ';');
    });

    test('should parse method with whitespace', () {
      final result = parser.parse('  i32   spaced  (  i32   x  ,  i32 y )  ');
      expect(result, isA<Success>());
      final [
        Token t,
        Token id,
        Token ld,
        [
          [_, _, Token t1, Token id1, _, _],
          [_, _, Token t2, Token id2, _, _],
        ],
        Token rd,
        _,
        _,
      ] = result.value as List;

      expect(t.value, 'i32');
      expect(id.value, 'spaced');
      expect(ld.value, '(');
      expect(t1.value, 'i32');
      expect(id1.value, 'x');
      expect(t2.value, 'i32');
      expect(id2.value, 'y');
      expect(rd.value, ')');
    });

    test('should parse method with no return type (identifier)', () {
      final result = parser.parse('CustomType customFunc()');
      final [Token t, Token id, Token ld, List args, Token rd, _, _] =
          result.value as List;

      expect(result, isA<Success>());
      expect(t.value, 'CustomType');
      expect(id.value, 'customFunc');
      expect(ld.value, '(');
      expect(args, isEmpty);
      expect(rd.value, ')');
    });
  });

  group('Method grammar (negative):', () {
    test('should fail to parse missing method parentheses', () {
      final result = parser.parse('void foo');

      expect(result, isA<Failure>());
      expect(result.message, '"(" expected');
    });

    test('should fail to parse missing method name', () {
      final result = parser.parse('void ()');

      expect(result, isA<Failure>());
      expect(result.message, '"letter" or "_" for start identifier expected');
    });

    test('should fail to parse invalid method argument', () {
      final result = parser.parse('void foo(,)');

      expect(result, isA<Failure>());
      expect(result.message, '")" expected');
    });

    test('should fail to parse empty string as method', () {
      final result = parser.parse('');

      expect(result, isA<Failure>());
      expect(result.message, 'return type expected');
    });

    test('should fail to parse only type ', () {
      final result = parser.parse('i32');

      expect(result, isA<Failure>());
      expect(result.message, '"letter" or "_" for start identifier expected');
    });
  });
}
