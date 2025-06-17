import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('VoidType AST', () {
    test('should parse void type when used as a method return type', () {
      const source = 'void';
      final doc = parseAstFromString(
        'service MyService { $source doSomething(); }',
      );
      final service = doc.definitions.first.cast<ServiceDefinitionNode>();
      final fn = service.methods.first;
      final returnType = fn.returnType.cast<VoidTypeNode>();
      expect(returnType.span, hasSpan(20, 24));
    });

    test(
      'should parse void type as a method return type with parameters',
      () {
        const source = 'void';
        final doc = parseAstFromString(
          'service MyService { $source doSomething(i32 id, string name); }',
        );
        final service = doc.definitions.first.cast<ServiceDefinitionNode>();
        final fn = service.methods.first;
        final returnType = fn.returnType.cast<VoidTypeNode>();
        expect(returnType.span, hasSpan(20, 24));
      },
    );
  });

  group('VoidType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'void';
      final doc1 = parseAstFromString(
        'service MyService { $source doSomething(); }',
      );
      final doc2 = parseAstFromString(
        'service MyService { $source doSomething(); }',
      );

      expect(doc1, equals(doc2));

      final service1 = doc1.definitions.first.cast<ServiceDefinitionNode>();
      final service2 = doc2.definitions.first.cast<ServiceDefinitionNode>();

      expect(service1, equals(service2));

      final fn1 = service1.methods.first;
      final fn2 = service2.methods.first;

      expect(fn1.returnType, equals(fn2.returnType));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAstFromString(
        'service MyService { void doSomething(); }',
      );
      final doc2 = parseAstFromString(
        'service MyService { int doSomething(); }',
      );

      final def1 = doc1.definitions.first.cast<ServiceDefinitionNode>();
      final def2 = doc2.definitions.first.cast<ServiceDefinitionNode>();

      expect(def1, isNot(equals(def2)));

      final fn1 = def1.methods.first;
      final fn2 = def2.methods.first;

      expect(fn1.returnType, isNot(equals(fn2.returnType)));
    });
  });
}
