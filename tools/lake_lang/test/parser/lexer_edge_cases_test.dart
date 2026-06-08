import 'package:lake_lang/src/parser/lake_lexer.dart';
import 'package:lake_lang/src/parser/token_type.dart';
import 'package:test/test.dart';

/// Collects all tokens from a lexer into a list of (type, slice) tuples.
List<(TokenType, String)> _tokenize(String input) {
  final lexer = LakeLexer(input);
  final tokens = <(TokenType, String)>[];
  while (lexer.currentType != TokenType.eof) {
    tokens.add((lexer.currentType, lexer.getSlice()));
    lexer.advance();
  }
  return tokens;
}

void main() {
  group('LakeLexer edge cases', () {
    group('Nested block comments', () {
      test('simple nested /* ... /* ... */ ... */ is skipped entirely', () {
        const input = '/* outer /* inner */ still outer */ struct';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwStruct);
        expect(lexer.getSlice(), 'struct');
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      });

      test('deeply nested comments are handled', () {
        const input = '/* a /* b /* c */ d */ e */ enum';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwEnum);
      });

      test('adjacent block comments are both skipped', () {
        const input = '/* first */ /* second */ import';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwImport);
      });

      test('block comment followed by line comment', () {
        const input = '/* block */ // line\nstruct';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwStruct);
      });
    });

    group('Unclosed string literal', () {
      test('unclosed double-quoted string consumes to end', () {
        const input = '"hello';
        final lexer = LakeLexer(input);
        // The lexer consumes until end of input since no closing quote
        expect(lexer.currentType, TokenType.stringLiteral);
        expect(lexer.getSlice(), '"hello');
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      });

      test('unclosed single-quoted string consumes to end', () {
        const input = "'hello";
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.stringLiteral);
        expect(lexer.getSlice(), "'hello");
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      });
    });

    group('Sign-only tokens backtrack', () {
      test('standalone + is not an int literal', () {
        // + followed by non-digit; lexer backtracks
        const input = '+ foo';
        final tokens = _tokenize(input);
        // The '+' should produce an error token since it's not
        // in the ASCII lookup table as a single-char punctuation
        // and it fails the number path, falling through to unrecognized.
        expect(tokens.first.$1, TokenType.error);
        expect(tokens.first.$2, '+');
        expect(tokens[1].$1, TokenType.identifier);
        expect(tokens[1].$2, 'foo');
      });

      test('standalone - is not an int literal', () {
        const input = '- bar';
        final tokens = _tokenize(input);
        expect(tokens.first.$1, TokenType.error);
        expect(tokens.first.$2, '-');
        expect(tokens[1].$1, TokenType.identifier);
        expect(tokens[1].$2, 'bar');
      });

      test('+ followed by digit IS a valid int', () {
        const input = '+42';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.intLiteral);
        expect(lexer.getSlice(), '+42');
      });

      test('- followed by digit IS a valid int', () {
        const input = '-7';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.intLiteral);
        expect(lexer.getSlice(), '-7');
      });
    });

    group('Identifier ending with dot (backtrack)', () {
      test('foo. backtracks to foo then lexes dot-like context', () {
        // "foo." — the lexer should produce "foo" as identifier,
        // then '.' is not a recognized char, so error.
        const input = 'foo.';
        final tokens = _tokenize(input);
        expect(tokens.length, 2);
        expect(tokens[0].$1, TokenType.identifier);
        expect(tokens[0].$2, 'foo');
        // The trailing dot becomes an error token
        expect(tokens[1].$1, TokenType.error);
        expect(tokens[1].$2, '.');
      });

      test('qualified identifier with trailing dot backtracks', () {
        const input = 'a.b.';
        final tokens = _tokenize(input);
        expect(tokens[0].$1, TokenType.identifier);
        expect(tokens[0].$2, 'a.b');
        expect(tokens[1].$1, TokenType.error);
        expect(tokens[1].$2, '.');
      });
    });

    group('Error token for unrecognized chars', () {
      test('@ produces error token', () {
        const input = '@';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.error);
        expect(lexer.getSlice(), '@');
      });

      test('# produces error token', () {
        const input = '#';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.error);
        expect(lexer.getSlice(), '#');
      });

      test('~ produces error token', () {
        const input = '~';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.error);
        expect(lexer.getSlice(), '~');
      });

      test('unrecognized char followed by valid tokens', () {
        const input = '@struct';
        final tokens = _tokenize(input);
        expect(tokens[0].$1, TokenType.error);
        expect(tokens[0].$2, '@');
        expect(tokens[1].$1, TokenType.kwStruct);
        expect(tokens[1].$2, 'struct');
      });

      test('multiple unrecognized chars produce multiple error tokens', () {
        const input = '@#~';
        final tokens = _tokenize(input);
        expect(tokens.length, 3);
        for (final t in tokens) {
          expect(t.$1, TokenType.error);
        }
      });
    });

    group('consumeDocComments()', () {
      test('returns null when there are no doc comments', () {
        final lexer = LakeLexer('struct Foo {}');
        expect(lexer.consumeDocComments(), isNull);
      });

      test('returns null for regular // comments (non-doc)', () {
        final lexer = LakeLexer('// just a comment\nstruct');
        expect(lexer.currentType, TokenType.kwStruct);
        // Regular comments are NOT doc comments
        expect(lexer.consumeDocComments(), isNull);
      });

      test('returns null after already consumed', () {
        final lexer = LakeLexer('/// doc\nstruct');
        expect(lexer.currentType, TokenType.kwStruct);
        expect(lexer.consumeDocComments(), isNotNull);
        // Second call should return null
        expect(lexer.consumeDocComments(), isNull);
      });
    });

    group('Multiple /// doc comment lines joined with newline', () {
      test('two doc comment lines joined', () {
        const input = '/// Line one\n/// Line two\nstruct';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwStruct);
        final doc = lexer.consumeDocComments();
        expect(doc, 'Line one\nLine two');
      });

      test('three doc comment lines joined', () {
        const input = '/// First\n/// Second\n/// Third\nenum';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwEnum);
        final doc = lexer.consumeDocComments();
        expect(doc, 'First\nSecond\nThird');
      });

      test('doc comments with leading/trailing whitespace are trimmed', () {
        const input = '///   Padded  \nstruct';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwStruct);
        final doc = lexer.consumeDocComments();
        expect(doc, 'Padded');
      });

      test('empty doc comment line', () {
        const input = '///\nstruct';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwStruct);
        final doc = lexer.consumeDocComments();
        expect(doc, '');
      });
    });

    group('Empty input edge cases', () {
      test('empty string produces eof', () {
        final lexer = LakeLexer('');
        expect(lexer.currentType, TokenType.eof);
      });

      test('whitespace-only produces eof', () {
        final lexer = LakeLexer('   \t\n\r  ');
        expect(lexer.currentType, TokenType.eof);
      });

      test('comment-only produces eof', () {
        final lexer = LakeLexer('// just a comment');
        expect(lexer.currentType, TokenType.eof);
      });

      test('block comment-only produces eof', () {
        final lexer = LakeLexer('/* block */');
        expect(lexer.currentType, TokenType.eof);
      });

      test('advancing past eof keeps returning eof', () {
        final lexer = LakeLexer('');
        expect(lexer.currentType, TokenType.eof);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      });
    });

    group('Very long identifiers and numbers', () {
      test('very long identifier', () {
        final longId = 'a' * 1000;
        final lexer = LakeLexer(longId);
        expect(lexer.currentType, TokenType.identifier);
        expect(lexer.getSlice(), longId);
      });

      test('very long integer literal', () {
        final longNum = '9' * 500;
        final lexer = LakeLexer(longNum);
        expect(lexer.currentType, TokenType.intLiteral);
        expect(lexer.getSlice(), longNum);
      });

      test('very long string literal', () {
        final longStr = '"${'x' * 1000}"';
        final lexer = LakeLexer(longStr);
        expect(lexer.currentType, TokenType.stringLiteral);
        expect(lexer.getSlice(), longStr);
      });
    });

    group('Qualified identifiers', () {
      test('simple qualified identifier a.b', () {
        final lexer = LakeLexer('a.b');
        expect(lexer.currentType, TokenType.identifier);
        expect(lexer.getSlice(), 'a.b');
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      });

      test('triple qualified identifier a.b.c', () {
        final lexer = LakeLexer('a.b.c');
        expect(lexer.currentType, TokenType.identifier);
        expect(lexer.getSlice(), 'a.b.c');
        lexer.advance();
        expect(lexer.currentType, TokenType.eof);
      });

      test('qualified identifier with underscores', () {
        final lexer = LakeLexer('my_pkg.sub_mod.Type');
        expect(lexer.currentType, TokenType.identifier);
        expect(lexer.getSlice(), 'my_pkg.sub_mod.Type');
      });

      test('qualified identifier followed by angle bracket', () {
        // e.g. common.Types<i32> — should get identifier then angle
        const input = 'common.Types<';
        final tokens = _tokenize(input);
        expect(tokens[0].$1, TokenType.identifier);
        expect(tokens[0].$2, 'common.Types');
        expect(tokens[1].$1, TokenType.angleLeft);
      });
    });

    group('Misc lexer edge cases', () {
      test('single slash alone is an error (not a comment start)', () {
        const input = '/ foo';
        final tokens = _tokenize(input);
        // '/' is not recognized; not in ASCII lookup, not a string/digit/letter
        expect(tokens[0].$1, TokenType.error);
        expect(tokens[0].$2, '/');
        expect(tokens[1].$1, TokenType.identifier);
      });

      test('currentStart and currentEnd are correct', () {
        const input = '  struct';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.kwStruct);
        expect(lexer.currentStart, 2);
        expect(lexer.currentEnd, 8);
      });

      test('numbers with exponent notation', () {
        const input = '1e10';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.doubleLiteral);
        expect(lexer.getSlice(), '1e10');
      });

      test('number with decimal and exponent', () {
        const input = '3.14e2';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.doubleLiteral);
        expect(lexer.getSlice(), '3.14e2');
      });

      test('negative number with exponent', () {
        const input = '-1E+3';
        final lexer = LakeLexer(input);
        expect(lexer.currentType, TokenType.doubleLiteral);
        expect(lexer.getSlice(), '-1E+3');
      });
    });
  });
}
