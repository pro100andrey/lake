import 'package:lake_lang/src/parser/lake_lexer.dart';
import 'package:lake_lang/src/parser/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('LakeLexer', () {
    test('lexes empty string', () {
      final lexer = LakeLexer('');
      expect(lexer.currentType, TokenType.eof);
    });

    test('lexes keywords', () {
      final keywords = {
        'struct': TokenType.kwStruct,
        'enum': TokenType.kwEnum,
        'union': TokenType.kwUnion,
        'exception': TokenType.kwException,
        'service': TokenType.kwService,
        'typedef': TokenType.kwTypedef,
        'const': TokenType.kwConst,
        'namespace': TokenType.kwNamespace,
        'import': TokenType.kwImport,
        'extends': TokenType.kwExtends,
        'required': TokenType.kwRequired,
        'optional': TokenType.kwOptional,
        'throws': TokenType.kwThrows,
        'true': TokenType.kwTrue,
        'false': TokenType.kwFalse,
      };

      for (final entry in keywords.entries) {
        final lexer = LakeLexer(entry.key);
        expect(
          lexer.currentType,
          entry.value,
          reason: 'Failed on ${entry.key}',
        );
        expect(lexer.getSlice(), entry.key);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('lexes types', () {
      final types = {
        'i8': TokenType.kwI8,
        'i16': TokenType.kwI16,
        'i32': TokenType.kwI32,
        'i64': TokenType.kwI64,
        'double': TokenType.kwDouble,
        'bool': TokenType.kwBool,
        'string': TokenType.kwString,
        'binary': TokenType.kwBinary,
        'byte': TokenType.kwByte,
        'uuid': TokenType.kwUuid,
        'void': TokenType.kwVoid,
        'list': TokenType.kwList,
        'set': TokenType.kwSet,
        'map': TokenType.kwMap,
        'stream': TokenType.kwStream,
      };

      for (final entry in types.entries) {
        final lexer = LakeLexer(entry.key);
        expect(
          lexer.currentType,
          entry.value,
          reason: 'Failed on ${entry.key}',
        );
        expect(lexer.getSlice(), entry.key);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('lexes identifiers', () {
      final identifiers = [
        'foo',
        'FooBar',
        '_underscore',
        'has_numbers123',
        'a',
        'Z',
        'qualified.identifier',
      ];

      for (final id in identifiers) {
        final lexer = LakeLexer(id);
        expect(
          lexer.currentType,
          TokenType.identifier,
          reason: 'Failed on $id',
        );
        expect(lexer.getSlice(), id);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('lexes integers', () {
      final ints = ['0', '42', '-100', '+999', '1234567890'];

      for (final i in ints) {
        final lexer = LakeLexer(i);
        expect(lexer.currentType, TokenType.intLiteral, reason: 'Failed on $i');
        expect(lexer.getSlice(), i);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('lexes doubles', () {
      final doubles = [
        '0.0',
        '3.14',
        '-0.5',
        '+1.0',
        '1e10',
        '1E-5',
        '-2.5e+3',
        '42.0e1',
      ];

      for (final d in doubles) {
        final lexer = LakeLexer(d);
        expect(
          lexer.currentType,
          TokenType.doubleLiteral,
          reason: 'Failed on $d',
        );
        expect(lexer.getSlice(), d);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('lexes strings', () {
      final strings = [
        '"hello"',
        "'world'",
        '""',
        "''",
        '"with spaces and stuff"',
      ];

      for (final s in strings) {
        final lexer = LakeLexer(s);
        expect(
          lexer.currentType,
          TokenType.stringLiteral,
          reason: 'Failed on $s',
        );
        expect(lexer.getSlice(), s);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('lexes operators and punctuation', () {
      final symbols = {
        '{': TokenType.braceLeft,
        '}': TokenType.braceRight,
        '(': TokenType.parenLeft,
        ')': TokenType.parenRight,
        '[': TokenType.bracketLeft,
        ']': TokenType.bracketRight,
        '<': TokenType.angleLeft,
        '>': TokenType.angleRight,
        ':': TokenType.colon,
        '=': TokenType.equals,
        ',': TokenType.comma,
        ';': TokenType.semicolon,
        '*': TokenType.asterisk,
      };

      for (final entry in symbols.entries) {
        final lexer = LakeLexer(entry.key);
        expect(
          lexer.currentType,
          entry.value,
          reason: 'Failed on ${entry.key}',
        );
        expect(lexer.getSlice(), entry.key);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      }
    });

    test('ignores whitespace and comments', () {
      const input = '''
        // single line comment
        /* multi
           line
           comment */
        const i32 x = 5;
      ''';

      final lexer = LakeLexer(input);
      expect(lexer.currentType, TokenType.kwConst);
      lexer.advance();
      expect(lexer.currentType, TokenType.kwI32);
      lexer.advance();
      expect(lexer.currentType, TokenType.identifier);
      expect(lexer.getSlice(), 'x');
      lexer.advance();
      expect(lexer.currentType, TokenType.equals);
      lexer.advance();
      expect(lexer.currentType, TokenType.intLiteral);
      expect(lexer.getSlice(), '5');
      lexer.advance();
      expect(lexer.currentType, TokenType.semicolon);
      lexer.advance();
      expect(lexer.currentType, TokenType.eof);
    });

    test('lexes a sequence of tokens', () {
      const input =
          'struct Point { 1: required double x; 2: required double y; }';
      final lexer = LakeLexer(input);

      final expected = [
        (TokenType.kwStruct, 'struct'),
        (TokenType.identifier, 'Point'),
        (TokenType.braceLeft, '{'),
        (TokenType.intLiteral, '1'),
        (TokenType.colon, ':'),
        (TokenType.kwRequired, 'required'),
        (TokenType.kwDouble, 'double'),
        (TokenType.identifier, 'x'),
        (TokenType.semicolon, ';'),
        (TokenType.intLiteral, '2'),
        (TokenType.colon, ':'),
        (TokenType.kwRequired, 'required'),
        (TokenType.kwDouble, 'double'),
        (TokenType.identifier, 'y'),
        (TokenType.semicolon, ';'),
        (TokenType.braceRight, '}'),
        (TokenType.eof, ''),
      ];

      for (final exp in expected) {
        expect(lexer.currentType, exp.$1);
        if (exp.$1 != TokenType.eof) {
          expect(lexer.getSlice(), exp.$2);
        }
        lexer.advance();
      }
    });
  });
}
