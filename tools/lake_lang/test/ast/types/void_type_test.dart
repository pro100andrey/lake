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
}
