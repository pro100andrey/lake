import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('Typedef Definition Rule:', () {
    final grammar = LakeGrammarDefinition();
    final parser = resolve(grammar.typedefDefinition().end());

    // Positive Test Cases

    test('should parse simple typedef with base type', () {
      final result = parser.parse('typedef i32 MyInt;');
      final [Token keyword, Token t, Token id, Token sep] =
          result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'typedef');
      expect(t.value, 'i32');
      expect(id.value, 'MyInt');
      expect(sep.value, ';');
    });

    test('should parse typedef with container type', () {
      final result = parser.parse('typedef list<i32> MyList;');
      final [
        Token keyword,
        [Token t, Token ld, Token t1, Token rd],
        Token id,
        Token sep,
      ] = result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'typedef');
      expect(t.value, 'list');
      expect(ld.value, '<');
      expect(t1.value, 'i32');
      expect(rd.value, '>');
      expect(id.value, 'MyList');
      expect(sep.value, ';');
    });

    test('should parse typedef with whitespace', () {
      final result = parser.parse('  typedef   i16   MyShort  ;  ');
      final [Token keyword, Token t, Token id, Token sep] =
          result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'typedef');
      expect(t.value, 'i16');
      expect(id.value, 'MyShort');
      expect(sep.value, ';');
    });

    test('should parse typedef without list separator', () {
      final result = parser.parse('typedef bool Flag');
      final [Token keyword, Token t, Token id, Token? sep] =
          result.value as List;

      expect(result, isA<Success>());
      expect(keyword.value, 'typedef');
      expect(t.value, 'bool');
      expect(id.value, 'Flag');
      expect(sep?.value, isNull);
    });

    // Negative Test Cases

    test('should fail to parse typedef missing type', () {
      final result = parser.parse('typedef MyAlias;');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse typedef missing identifier', () {
      final result = parser.parse('typedef i32 ;');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });

    test('should fail to parse typedef with invalid type', () {
      final result = parser.parse('typedef unknownType Alias;');

      expect(result, isA<Failure>());
      expect(result.message, '"uuid" expected');
    });

    test('should fail to parse typedef with invalid identifier', () {
      final result = parser.parse('typedef i32 1Alias;');

      expect(result, isA<Failure>());
      expect(result.message, '"_" expected');
    });
  });
}
