import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('VoidType AST', () {
    test('should parse void type when used as a function return type', () {
      const source = 'void';
      final doc = parseAst('service MyService { $source doSomething(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;
      final returnType = fn.returnType as VoidTypeNode;

      expect(returnType, isA<VoidTypeNode>());
      expect(returnType.span.text, source);
      expect(returnType.span.start.offset, 20);
      expect(returnType.span.end.offset, 24);
    });

    test(
      'should parse void type as a function return type with parameters',
      () {
        const source = 'void';
        final doc = parseAst(
          'service MyService { $source doSomething(i32 id, string name); }',
        );
        final service = doc.definitions.first as ServiceDefinitionNode;
        final fn = service.functions.first;
        final returnType = fn.returnType as VoidTypeNode;

        expect(returnType, isA<VoidTypeNode>());
        expect(returnType.span.text, source);
        expect(returnType.span.start.offset, 20);
        expect(returnType.span.end.offset, 24);
      },
    );
  });

  group('VoidType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'void';
      final doc1 = parseAst('service MyService { $source doSomething(); }');
      final doc2 = parseAst('service MyService { $source doSomething(); }');

      expect(doc1, equals(doc2));

      final service1 = doc1.definitions.first as ServiceDefinitionNode;
      final service2 = doc2.definitions.first as ServiceDefinitionNode;

      expect(service1, equals(service2));

      final fn1 = service1.functions.first;
      final fn2 = service2.functions.first;

      expect(fn1.returnType, equals(fn2.returnType));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAst('service MyService { void doSomething(); }');
      final doc2 = parseAst('service MyService { int doSomething(); }');

      final def1 = doc1.definitions.first as ServiceDefinitionNode;
      final def2 = doc2.definitions.first as ServiceDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final fn1 = def1.functions.first;
      final fn2 = def2.functions.first;

      expect(fn1.returnType, isNot(equals(fn2.returnType)));
    });
  });
}
