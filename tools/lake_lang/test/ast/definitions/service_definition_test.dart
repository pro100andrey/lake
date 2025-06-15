import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ServiceDefinition AST (positive):', () {
    test('should parse empty service', () {
      const source = 'service MyService {}';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;

      expect(def.span.start, 0);
      expect(def.span.end, 20);

      expect(def.identifier.value, 'MyService');
      expect(def.identifier.span.start, 8);
      expect(def.identifier.span.end, 17);

      expect(def.extendsService, isNull);
      expect(def.functions, isEmpty);
    });

    test('should parse service with one function', () {
      const source = 'service S { void foo(); }';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 25);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 8);
      expect(def.identifier.span.end, 9);

      expect(def.extendsService, isNull);

      expect(def.functions, hasLength(1));

      expect(def.functions[0].returnType, isA<VoidTypeNode>());
      expect(def.functions[0].returnType.span.start, 12);
      expect(def.functions[0].returnType.span.end, 16);

      expect(def.functions[0].parameters, isEmpty);

      expect(def.functions[0].identifier.value, 'foo');
      expect(def.functions[0].identifier.span.start, 17);
      expect(def.functions[0].identifier.span.end, 20);
    });

    test(
      'should parse service with multiple functions without fieldID',
      () {
        const source = 'service S { void foo(); i32 bar(i32 x); }';
        final doc = parseAndGetAst(source);

        expect(doc.definitions, hasLength(1));

        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.start, 0);
        expect(def.span.end, 41);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.start, 8);
        expect(def.identifier.span.end, 9);

        expect(def.extendsService, isNull);

        expect(def.functions, hasLength(2));

        final fn1 = def.functions[0];
        expect(fn1.returnType, isA<VoidTypeNode>());
        expect(fn1.returnType.span.start, 12);
        expect(fn1.returnType.span.end, 16);

        expect(fn1.parameters, isEmpty);

        expect(fn1.identifier.value, 'foo');
        expect(fn1.identifier.span.start, 17);
        expect(fn1.identifier.span.end, 20);

        final fn2 = def.functions[1];
        expect((fn2.returnType as BaseTypeNode).value, 'i32');
        expect(fn2.returnType.span.start, 24);
        expect(fn2.returnType.span.end, 27);

        expect(fn2.identifier.value, 'bar');
        expect(fn2.identifier.span.start, 28);
        expect(fn2.identifier.span.end, 31);

        expect(fn2.parameters, hasLength(1));

        final fn2Params = fn2.parameters[0];
        expect((fn2Params.type as BaseTypeNode).value, 'i32');
        expect(fn2Params.type.span.start, 32);
        expect(fn2Params.type.span.end, 35);

        expect(fn2Params.identifier.value, 'x');
        expect(fn2Params.identifier.span.start, 36);
        expect(fn2Params.identifier.span.end, 37);
      },
    );

    test('should parse service with function with fieldId', () {
      const source = 'service S { void foo(1: i32 x, 2: i32 y)}';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 41);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 8);
      expect(def.identifier.span.end, 9);

      expect(def.extendsService, isNull);

      expect(def.functions, hasLength(1));

      final fn = def.functions[0];
      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.start, 12);
      expect(fn.returnType.span.end, 16);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.start, 17);
      expect(fn.identifier.span.end, 20);

      expect(fn.parameters, hasLength(2));

      final [FieldNode parameter, FieldNode parameter1] = fn.parameters;

      expect(parameter.fieldId, isNotNull);
      expect(parameter.fieldId!.rawValue, '1');
      expect(parameter.fieldId!.value, 1);
      expect(parameter.fieldId!.span.start, 21);
      expect(parameter.fieldId!.span.end, 22);

      expect((parameter.type as BaseTypeNode).value, 'i32');
      expect(parameter.type.span.start, 24);
      expect(parameter.type.span.end, 27);

      expect(parameter.identifier.value, 'x');
      expect(parameter.identifier.span.start, 28);
      expect(parameter.identifier.span.end, 29);

      expect(parameter1.fieldId, isNotNull);
      expect(parameter1.fieldId!.rawValue, '2');
      expect(parameter1.fieldId!.value, 2);
      expect(parameter1.fieldId!.span.start, 31);
      expect(parameter1.fieldId!.span.end, 32);

      expect((parameter1.type as BaseTypeNode).value, 'i32');
      expect(parameter1.type.span.start, 34);
      expect(parameter1.type.span.end, 37);

      expect(parameter1.identifier.value, 'y');
      expect(parameter1.identifier.span.start, 38);
      expect(parameter1.identifier.span.end, 39);
    });

    test('should parse service with extends', () {
      const source = 'service S extends Base { void foo(); }';
      final doc = parseAndGetAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;
      expect(def.span.start, 0);
      expect(def.span.end, 38);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.start, 8);
      expect(def.identifier.span.end, 9);

      expect(def.extendsService, isNotNull);
      expect(def.extendsService!.value, 'Base');
      expect(def.extendsService!.span.start, 18);
      expect(def.extendsService!.span.end, 22);

      expect(def.functions, hasLength(1));

      final fn = def.functions[0];
      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.start, 25);
      expect(fn.returnType.span.end, 29);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.start, 30);
      expect(fn.identifier.span.end, 33);

      expect(fn.parameters, isEmpty);
    });

    test(
      'should parse service with function arguments and throws without fieldId',
      () {
        const source =
            'service S { i32 foo(1: i32 x, 3: string y) throws (i32 err); }';
        final doc = parseAndGetAst(source);

        expect(doc.definitions, hasLength(1));
        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.start, 0);
        expect(def.span.end, 62);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.start, 8);
        expect(def.identifier.span.end, 9);

        expect(def.extendsService, isNull);

        final [FunctionNode fn] = def.functions;

        expect((fn.returnType as BaseTypeNode).value, 'i32');
        expect(fn.returnType.span.start, 12);
        expect(fn.returnType.span.end, 15);

        expect(fn.identifier.value, 'foo');
        expect(fn.identifier.span.start, 16);
        expect(fn.identifier.span.end, 19);

        final [FieldNode parameter, FieldNode parameter1] = fn.parameters;

        expect(parameter.fieldId!.rawValue, '1');
        expect(parameter.fieldId!.value, 1);
        expect(parameter.fieldId!.span.start, 20);
        expect(parameter.fieldId!.span.end, 21);

        expect((parameter.type as BaseTypeNode).value, 'i32');
        expect(parameter.type.span.start, 23);
        expect(parameter.type.span.end, 26);

        expect(parameter.identifier.value, 'x');
        expect(parameter.identifier.span.start, 27);
        expect(parameter.identifier.span.end, 28);

        expect(parameter1.fieldId!.rawValue, '3');
        expect(parameter1.fieldId!.value, 3);
        expect(parameter1.fieldId!.span.start, 30);
        expect(parameter1.fieldId!.span.end, 31);

        expect((parameter1.type as BaseTypeNode).value, 'string');
        expect(parameter1.type.span.start, 33);
        expect(parameter1.type.span.end, 39);

        expect(parameter1.identifier.value, 'y');
        expect(parameter1.identifier.span.start, 40);
        expect(parameter1.identifier.span.end, 41);

        final [FieldNode throw0] = fn.throws;

        expect(throw0.span.start, 51);
        expect(throw0.span.end, 58);

        expect((throw0.type as BaseTypeNode).value, 'i32');
        expect(throw0.type.span.start, 51);
        expect(throw0.type.span.end, 54);

        expect(throw0.identifier, isNotNull);
        expect(throw0.identifier.value, 'err');
        expect(throw0.identifier.span.start, 55);
        expect(throw0.identifier.span.end, 58);
      },
    );

    test(
      'should parse service with function arguments and throws with fieldId',
      () {
        const source =
            'service S { i32 foo(1: i32 x, 3: string y) throws (1: i32 err); }';
        final doc = parseAndGetAst(source);

        expect(doc.definitions, hasLength(1));
        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.start, 0);
        expect(def.span.end, 65);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.start, 8);
        expect(def.identifier.span.end, 9);

        expect(def.extendsService, isNull);

        final [FunctionNode fn] = def.functions;

        expect((fn.returnType as BaseTypeNode).value, 'i32');
        expect(fn.returnType.span.start, 12);
        expect(fn.returnType.span.end, 15);

        expect(fn.identifier.value, 'foo');
        expect(fn.identifier.span.start, 16);
        expect(fn.identifier.span.end, 19);

        final [FieldNode p1, FieldNode p2] = fn.parameters;

        expect(p1.fieldId!.rawValue, '1');
        expect(p1.fieldId!.value, 1);
        expect(p1.fieldId!.span.start, 20);
        expect(p1.fieldId!.span.end, 21);

        expect((p1.type as BaseTypeNode).value, 'i32');
        expect(p1.type.span.start, 23);
        expect(p1.type.span.end, 26);

        expect(p1.identifier.value, 'x');
        expect(p1.identifier.span.start, 27);
        expect(p1.identifier.span.end, 28);

        expect(p2.fieldId!.rawValue, '3');
        expect(p2.fieldId!.value, 3);
        expect(p2.fieldId!.span.start, 30);
        expect(p2.fieldId!.span.end, 31);

        expect((p2.type as BaseTypeNode).value, 'string');
        expect(p2.type.span.start, 33);
        expect(p2.type.span.end, 39);

        expect(p2.identifier.value, 'y');
        expect(p2.identifier.span.start, 40);
        expect(p2.identifier.span.end, 41);

        final [FieldNode throwField] = fn.throws;

        expect(throwField.span.start, 51);
        expect(throwField.span.end, 61);

        expect(throwField.fieldId!.rawValue, '1');
        expect(throwField.fieldId!.value, 1);
        expect(throwField.fieldId!.span.start, 51);
        expect(throwField.fieldId!.span.end, 52);

        expect((throwField.type as BaseTypeNode).value, 'i32');
        expect(throwField.type.span.start, 54);
        expect(throwField.type.span.end, 57);

        expect(throwField.identifier.value, 'err');
        expect(throwField.identifier.span.start, 58);
        expect(throwField.identifier.span.end, 61);
      },
    );

    test(
      'should parse service with multiple functions separated by semicolon',
      () {
        const source =
            'service S { void func1(); string func2(); i32 func3(); }';
        final doc = parseAndGetAst(source);

        expect(doc.definitions, hasLength(1));

        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.start, 0);
        expect(def.span.end, 56);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.start, 8);
        expect(def.identifier.span.end, 9);

        expect(def.extendsService, isNull);
        expect(def.functions, hasLength(3));

        final [FunctionNode func1, FunctionNode func2, FunctionNode func3] =
            def.functions;

        expect(func1.returnType, isA<VoidTypeNode>());
        expect(func1.returnType.span.start, 12);
        expect(func1.returnType.span.end, 16);

        expect(func1.identifier.value, 'func1');
        expect(func1.identifier.span.start, 17);
        expect(func1.identifier.span.end, 22);

        expect((func2.returnType as BaseTypeNode).value, 'string');
        expect(func2.returnType.span.start, 26);
        expect(func2.returnType.span.end, 32);

        expect(func2.identifier.value, 'func2');
        expect(func2.identifier.span.start, 33);
        expect(func2.identifier.span.end, 38);

        expect((func3.returnType as BaseTypeNode).value, 'i32');
        expect(func3.returnType.span.start, 42);
        expect(func3.returnType.span.end, 45);

        expect(func3.identifier.value, 'func3');
        expect(func3.identifier.span.start, 46);
        expect(func3.identifier.span.end, 51);
        expect(func3.parameters, isEmpty);
      },
    );
  });

  group('ServiceDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source = 'service AuthService { void login(); }';
      const source2 = 'service AuthService { void login(); }';
      final doc1 = parseAndGetAst(source);
      final doc2 = parseAndGetAst(source2);

      expect(doc1, equals(doc2));

      final service1 = doc1.definitions.first as ServiceDefinitionNode;
      final service2 = doc2.definitions.first as ServiceDefinitionNode;

      expect(service1, equals(service2));
      expect(service1.functions, equals(service2.functions));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'service AuthService { void login(); }';
      const source2 = 'service AuthService { void logout(); }';
      final doc1 = parseAndGetAst(source1);
      final doc2 = parseAndGetAst(source2);

      expect(doc1, isNot(equals(doc2)));

      final service1 = doc1.definitions.first as ServiceDefinitionNode;
      final service2 = doc2.definitions.first as ServiceDefinitionNode;

      expect(service1, isNot(equals(service2)));
      expect(service1.functions, isNot(equals(service2.functions)));
    });
  });
}
