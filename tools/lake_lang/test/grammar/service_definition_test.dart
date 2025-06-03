import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceDefinition Rule:', () {
    final grammar = LakeGrammarDefinition();
    // [12] Service ::= 'service' Identifier ( 'extends' Identifier )? 
    // '{' Function* '}'
    final parser = resolve(grammar.serviceDefinition().end());

    // Positive cases

    test('should parse empty service', () {
      final result = parser.parse('service MyService {}');
      expect(result, isA<Success>());
    });

    test('should parse service with one function', () {
      final result = parser.parse('service S { void foo() }');
      expect(result, isA<Success>());
    });

    test('should parse service with multiple functions', () {
      final result = parser.parse('service S { void foo(); i32 bar(i32 x); }');
      expect(result, isA<Success>());
    });

    test('should parse service with extends', () {
      final result = parser.parse('service S extends Base { void foo() }');
      expect(result, isA<Success>());
    });

    test('should parse service with whitespace', () {
      final result = parser.parse('  service   S   {   void foo ( ) ;   }  ');
      expect(result, isA<Success>());
    });

    test('should parse service with trailing comma in function', () {
      final result = parser.parse('service S { void foo(), }');
      expect(result, isA<Success>());
    });

    // Negative cases

    test('should fail to parse missing service keyword', () {
      final result = parser.parse('S { void foo() }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing identifier', () {
      final result = parser.parse('service { void foo() }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse missing braces', () {
      final result = parser.parse('service S void foo()');
      expect(result, isA<Failure>());
    });

    test('should fail to parse invalid function', () {
      final result = parser.parse('service S { foo }');
      expect(result, isA<Failure>());
    });

    test('should fail to parse empty string', () {
      final result = parser.parse('');
      expect(result, isA<Failure>());
    });
  });
}
