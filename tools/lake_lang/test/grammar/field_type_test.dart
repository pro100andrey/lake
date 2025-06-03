import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('FieldType Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [19] FieldType ::= ContainerType | BaseType | Identifier
    final parser = resolve(grammar.fieldType().end());

    // Positive cases

    test('should parse base type: bool', () {
      final result = parser.parse('bool');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, 'bool');
    });

    test('should parse base type: i32', () {
      final result = parser.parse('i32');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, 'i32');
    });

    test('should parse base type: string', () {
      final result = parser.parse('string');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, 'string');
    });

    test('should parse identifier type', () {
      final result = parser.parse('MyType');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, 'MyType');
    });

    test('should parse identifier with dot', () {
      final result = parser.parse('pkg.Type');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, 'pkg.Type');
    });

    test('should parse list type', () {
      final result = parser.parse('list<i32>');
      expect(result, isA<Success>());
    });

    test('should parse set type', () {
      final result = parser.parse('set<string>');
      expect(result, isA<Success>());
    });

    test('should parse map type', () {
      final result = parser.parse('map<string, i64>');
      expect(result, isA<Success>());
    });

    test('should parse nested container type', () {
      final result = parser.parse('list<map<string, list<i32>>>');
      expect(result, isA<Success>());
    });

    test('should parse identifier with underscores', () {
      final result = parser.parse('_myType_123');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, '_myType_123');
    });

    test('should parse type with whitespace', () {
      final result = parser.parse('   i64   ');
      final Token(:String value) = result.value;
      expect(result, isA<Success>());
      expect(value, 'i64');
    });

    // Negative cases

    test('should fail to parse incomplete container type', () {
      final result = parser.parse('list<');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('map<string string>');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse map with missing comma', () {
      final result = parser.parse('stream<string>');
      expect(result, isA<Failure>());
      expect(result.message, 'end of input expected');
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid identifier', () {
      final result = parser.parse('1abc');
      expect(result, isA<Failure>());
    });

    test('should fail to parse type with invalid characters', () {
      final result = parser.parse('list<i32!>');
      expect(result, isA<Failure>());
    });
  });
}
