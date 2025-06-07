import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('ServiceDefinition AST', () {
    test('should parse empty service', () {
      const source = 'service MyService {}';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;

      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 20);

      expect(def.identifier.value, 'MyService');
      expect(def.identifier.span.text, 'MyService');
      expect(def.identifier.span.start.offset, 8);
      expect(def.identifier.span.end.offset, 17);

      expect(def.extendsService, isNull);
      expect(def.functions, isEmpty);
    });

    test('should parse service with one function', () {
      const source = 'service S { void foo(); }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 25);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 8);
      expect(def.identifier.span.end.offset, 9);

      expect(def.extendsService, isNull);

      expect(def.functions, hasLength(1));

      expect(def.functions[0].returnType, isA<VoidTypeNode>());
      expect(def.functions[0].returnType.span.text, 'void');
      expect(def.functions[0].returnType.span.start.offset, 12);
      expect(def.functions[0].returnType.span.end.offset, 16);

      expect(def.functions[0].parameters, isEmpty);

      expect(def.functions[0].identifier.value, 'foo');
      expect(def.functions[0].identifier.span.text, 'foo');
      expect(def.functions[0].identifier.span.start.offset, 17);
      expect(def.functions[0].identifier.span.end.offset, 20);
    });

    test(
      'should parse service with multiple functions without fieldID',
      () {
        const source = 'service S { void foo(); i32 bar(i32 x); }';
        final doc = parseAst(source);

        expect(doc.definitions, hasLength(1));

        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.text, source);
        expect(def.span.start.offset, 0);
        expect(def.span.end.offset, 41);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.text, 'S');
        expect(def.identifier.span.start.offset, 8);
        expect(def.identifier.span.end.offset, 9);

        expect(def.extendsService, isNull);

        expect(def.functions, hasLength(2));

        final fn1 = def.functions[0];
        expect(fn1.returnType, isA<VoidTypeNode>());
        expect(fn1.returnType.span.text, 'void');
        expect(fn1.returnType.span.start.offset, 12);
        expect(fn1.returnType.span.end.offset, 16);

        expect(fn1.parameters, isEmpty);

        expect(fn1.identifier.value, 'foo');
        expect(fn1.identifier.span.text, 'foo');
        expect(fn1.identifier.span.start.offset, 17);
        expect(fn1.identifier.span.end.offset, 20);

        final fn2 = def.functions[1];
        expect((fn2.returnType as BaseTypeNode).value, 'i32');
        expect(fn2.returnType.span.text, 'i32');
        expect(fn2.returnType.span.start.offset, 24);
        expect(fn2.returnType.span.end.offset, 27);

        expect(fn2.identifier.value, 'bar');
        expect(fn2.identifier.span.text, 'bar');
        expect(fn2.identifier.span.start.offset, 28);
        expect(fn2.identifier.span.end.offset, 31);

        expect(fn2.parameters, hasLength(1));

        final fn2Params = fn2.parameters[0];
        expect((fn2Params.type as BaseTypeNode).value, 'i32');
        expect(fn2Params.type.span.text, 'i32');
        expect(fn2Params.type.span.start.offset, 32);
        expect(fn2Params.type.span.end.offset, 35);

        expect(fn2Params.identifier.value, 'x');
        expect(fn2Params.identifier.span.text, 'x');
        expect(fn2Params.identifier.span.start.offset, 36);
        expect(fn2Params.identifier.span.end.offset, 37);
      },
    );

    test('should parse service with function with fieldId', () {
      const source = 'service S { void foo(1: i32 x, 2: i32 y)}';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 41);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 8);
      expect(def.identifier.span.end.offset, 9);

      expect(def.extendsService, isNull);

      expect(def.functions, hasLength(1));

      final fn = def.functions[0];
      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.text, 'void');
      expect(fn.returnType.span.start.offset, 12);
      expect(fn.returnType.span.end.offset, 16);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.text, 'foo');
      expect(fn.identifier.span.start.offset, 17);
      expect(fn.identifier.span.end.offset, 20);

      expect(fn.parameters, hasLength(2));

      expect(fn.parameters[0].fieldId, isNotNull);
      expect(fn.parameters[0].fieldId!.value, '1');
      expect(fn.parameters[0].fieldId!.span.text, '1');
      expect(fn.parameters[0].fieldId!.span.start.offset, 21);
      expect(fn.parameters[0].fieldId!.span.end.offset, 22);

      expect((fn.parameters[0].type as BaseTypeNode).value, 'i32');
      expect(fn.parameters[0].type.span.text, 'i32');
      expect(fn.parameters[0].type.span.start.offset, 24);
      expect(fn.parameters[0].type.span.end.offset, 27);

      expect(fn.parameters[0].identifier.value, 'x');
      expect(fn.parameters[0].identifier.span.text, 'x');
      expect(fn.parameters[0].identifier.span.start.offset, 28);
      expect(fn.parameters[0].identifier.span.end.offset, 29);

      expect(fn.parameters[1].fieldId, isNotNull);
      expect(fn.parameters[1].fieldId!.value, '2');
      expect(fn.parameters[1].fieldId!.span.text, '2');
      expect(fn.parameters[1].fieldId!.span.start.offset, 31);
      expect(fn.parameters[1].fieldId!.span.end.offset, 32);

      expect((fn.parameters[1].type as BaseTypeNode).value, 'i32');
      expect(fn.parameters[1].type.span.text, 'i32');
      expect(fn.parameters[1].type.span.start.offset, 34);
      expect(fn.parameters[1].type.span.end.offset, 37);

      expect(fn.parameters[1].identifier.value, 'y');
      expect(fn.parameters[1].identifier.span.text, 'y');
      expect(fn.parameters[1].identifier.span.start.offset, 38);
      expect(fn.parameters[1].identifier.span.end.offset, 39);
    });

    test('should parse service with extends', () {
      const source = 'service S extends Base { void foo(); }';
      final doc = parseAst(source);

      expect(doc.definitions, hasLength(1));

      final def = doc.definitions.first as ServiceDefinitionNode;
      expect(def.span.text, source);
      expect(def.span.start.offset, 0);
      expect(def.span.end.offset, 38);

      expect(def.identifier.value, 'S');
      expect(def.identifier.span.text, 'S');
      expect(def.identifier.span.start.offset, 8);
      expect(def.identifier.span.end.offset, 9);

      expect(def.extendsService, isNotNull);
      expect(def.extendsService!.value, 'Base');
      expect(def.extendsService!.span.text, 'Base');
      expect(def.extendsService!.span.start.offset, 18);
      expect(def.extendsService!.span.end.offset, 22);

      expect(def.functions, hasLength(1));

      final fn = def.functions[0];
      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.text, 'void');
      expect(fn.returnType.span.start.offset, 25);
      expect(fn.returnType.span.end.offset, 29);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.text, 'foo');
      expect(fn.identifier.span.start.offset, 30);
      expect(fn.identifier.span.end.offset, 33);

      expect(fn.parameters, isEmpty);
    });

    test(
      'should parse service with function arguments and throws without fieldId',
      () {
        const source =
            'service S { i32 foo(1: i32 x, 3: string y) throws (i32 err); }';
        final doc = parseAst(source);

        expect(doc.definitions, hasLength(1));
        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.text, source);
        expect(def.span.start.offset, 0);
        expect(def.span.end.offset, 62);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.text, 'S');
        expect(def.identifier.span.start.offset, 8);
        expect(def.identifier.span.end.offset, 9);

        expect(def.extendsService, isNull);

        expect(def.functions, hasLength(1));

        final fn = def.functions[0];
        expect((fn.returnType as BaseTypeNode).value, 'i32');
        expect(fn.returnType.span.text, 'i32');
        expect(fn.returnType.span.start.offset, 12);
        expect(fn.returnType.span.end.offset, 15);

        expect(fn.identifier.value, 'foo');
        expect(fn.identifier.span.text, 'foo');
        expect(fn.identifier.span.start.offset, 16);
        expect(fn.identifier.span.end.offset, 19);

        expect(fn.parameters, hasLength(2));

        expect(fn.parameters[0].fieldId!.value, '1');
        expect(fn.parameters[0].fieldId!.span.text, '1');
        expect(fn.parameters[0].fieldId!.span.start.offset, 20);
        expect(fn.parameters[0].fieldId!.span.end.offset, 21);

        expect((fn.parameters[0].type as BaseTypeNode).value, 'i32');
        expect(fn.parameters[0].type.span.text, 'i32');
        expect(fn.parameters[0].type.span.start.offset, 23);
        expect(fn.parameters[0].type.span.end.offset, 26);

        expect(fn.parameters[0].identifier.value, 'x');
        expect(fn.parameters[0].identifier.span.text, 'x');
        expect(fn.parameters[0].identifier.span.start.offset, 27);
        expect(fn.parameters[0].identifier.span.end.offset, 28);

        expect(fn.parameters[1].fieldId!.value, '3');
        expect(fn.parameters[1].fieldId!.span.text, '3');
        expect(fn.parameters[1].fieldId!.span.start.offset, 30);
        expect(fn.parameters[1].fieldId!.span.end.offset, 31);

        expect((fn.parameters[1].type as BaseTypeNode).value, 'string');
        expect(fn.parameters[1].type.span.text, 'string');
        expect(fn.parameters[1].type.span.start.offset, 33);
        expect(fn.parameters[1].type.span.end.offset, 39);

        expect(fn.parameters[1].identifier.value, 'y');
        expect(fn.parameters[1].identifier.span.text, 'y');
        expect(fn.parameters[1].identifier.span.start.offset, 40);
        expect(fn.parameters[1].identifier.span.end.offset, 41);

        expect((fn.throws[0].type as BaseTypeNode).value, 'i32');
        expect(fn.throws[0].type.span.text, 'i32');
        expect(fn.throws[0].type.span.start.offset, 51);
        expect(fn.throws[0].type.span.end.offset, 54);

        expect(fn.throws[0].identifier, isNotNull);
        expect(fn.throws[0].identifier.value, 'err');
        expect(fn.throws[0].identifier.span.text, 'err');
        expect(fn.throws[0].identifier.span.start.offset, 55);
        expect(fn.throws[0].identifier.span.end.offset, 58);

        expect(fn.throws[0].span.text, 'i32 err');
        expect(fn.throws[0].span.start.offset, 51);
        expect(fn.throws[0].span.end.offset, 58);
      },
    );

    test(
      'should parse service with function arguments and throws with fieldId',
      () {
        const source =
            'service S { i32 foo(1: i32 x, 3: string y) throws (1: i32 err); }';
        final doc = parseAst(source);

        expect(doc.definitions, hasLength(1));
        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.text, source);
        expect(def.span.start.offset, 0);
        expect(def.span.end.offset, 65);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.text, 'S');
        expect(def.identifier.span.start.offset, 8);
        expect(def.identifier.span.end.offset, 9);

        expect(def.extendsService, isNull);

        expect(def.functions, hasLength(1));

        final fn = def.functions[0];
        expect((fn.returnType as BaseTypeNode).value, 'i32');
        expect(fn.returnType.span.text, 'i32');
        expect(fn.returnType.span.start.offset, 12);
        expect(fn.returnType.span.end.offset, 15);

        expect(fn.identifier.value, 'foo');
        expect(fn.identifier.span.text, 'foo');
        expect(fn.identifier.span.start.offset, 16);
        expect(fn.identifier.span.end.offset, 19);

        expect(fn.parameters, hasLength(2));

        expect(fn.parameters[0].fieldId!.value, '1');
        expect(fn.parameters[0].fieldId!.span.text, '1');
        expect(fn.parameters[0].fieldId!.span.start.offset, 20);
        expect(fn.parameters[0].fieldId!.span.end.offset, 21);

        expect((fn.parameters[0].type as BaseTypeNode).value, 'i32');
        expect(fn.parameters[0].type.span.text, 'i32');
        expect(fn.parameters[0].type.span.start.offset, 23);
        expect(fn.parameters[0].type.span.end.offset, 26);

        expect(fn.parameters[0].identifier.value, 'x');
        expect(fn.parameters[0].identifier.span.text, 'x');
        expect(fn.parameters[0].identifier.span.start.offset, 27);
        expect(fn.parameters[0].identifier.span.end.offset, 28);

        expect(fn.parameters[1].fieldId!.value, '3');
        expect(fn.parameters[1].fieldId!.span.text, '3');
        expect(fn.parameters[1].fieldId!.span.start.offset, 30);
        expect(fn.parameters[1].fieldId!.span.end.offset, 31);

        expect((fn.parameters[1].type as BaseTypeNode).value, 'string');
        expect(fn.parameters[1].type.span.text, 'string');
        expect(fn.parameters[1].type.span.start.offset, 33);
        expect(fn.parameters[1].type.span.end.offset, 39);

        expect(fn.parameters[1].identifier.value, 'y');
        expect(fn.parameters[1].identifier.span.text, 'y');
        expect(fn.parameters[1].identifier.span.start.offset, 40);
        expect(fn.parameters[1].identifier.span.end.offset, 41);

        expect(fn.throws, hasLength(1));
        expect(fn.throws[0].fieldId!.value, '1');
        expect(fn.throws[0].fieldId!.span.text, '1');
        expect(fn.throws[0].fieldId!.span.start.offset, 51);
        expect(fn.throws[0].fieldId!.span.end.offset, 52);

        expect((fn.throws[0].type as BaseTypeNode).value, 'i32');
        expect(fn.throws[0].type.span.text, 'i32');
        expect(fn.throws[0].type.span.start.offset, 54);
        expect(fn.throws[0].type.span.end.offset, 57);

        expect(fn.throws[0].identifier.value, 'err');
        expect(fn.throws[0].identifier.span.text, 'err');
        expect(fn.throws[0].identifier.span.start.offset, 58);
        expect(fn.throws[0].identifier.span.end.offset, 61);

        expect(fn.throws[0].span.text, '1: i32 err');
        expect(fn.throws[0].span.start.offset, 51);
        expect(fn.throws[0].span.end.offset, 61);
      },
    );

    test(
      'should parse service with multiple functions separated by semicolon',
      () {
        const source =
            'service S { void func1(); string func2(); i32 func3(); }';
        final doc = parseAst(source);

        expect(doc.definitions, hasLength(1));

        final def = doc.definitions.first as ServiceDefinitionNode;
        expect(def.span.text, source);
        expect(def.span.start.offset, 0);
        expect(def.span.end.offset, 56);

        expect(def.identifier.value, 'S');
        expect(def.identifier.span.text, 'S');
        expect(def.identifier.span.start.offset, 8);
        expect(def.identifier.span.end.offset, 9);

        expect(def.extendsService, isNull);
        expect(def.functions, hasLength(3));

        final func1 = def.functions[0];
        expect(func1.returnType, isA<VoidTypeNode>());
        expect(func1.returnType.span.text, 'void');
        expect(func1.returnType.span.start.offset, 12);
        expect(func1.returnType.span.end.offset, 16);

        expect(func1.identifier.value, 'func1');
        expect(func1.identifier.span.text, 'func1');
        expect(func1.identifier.span.start.offset, 17);
        expect(func1.identifier.span.end.offset, 22);

        final func2 = def.functions[1];
        expect((func2.returnType as BaseTypeNode).value, 'string');
        expect(func2.returnType.span.text, 'string');
        expect(func2.returnType.span.start.offset, 26);
        expect(func2.returnType.span.end.offset, 32);

        expect(func2.identifier.value, 'func2');
        expect(func2.identifier.span.text, 'func2');
        expect(func2.identifier.span.start.offset, 33);
        expect(func2.identifier.span.end.offset, 38);

        final func3 = def.functions[2];
        expect((func3.returnType as BaseTypeNode).value, 'i32');
        expect(func3.returnType.span.text, 'i32');
        expect(func3.returnType.span.start.offset, 42);
        expect(func3.returnType.span.end.offset, 45);

        expect(func3.identifier.value, 'func3');
        expect(func3.identifier.span.text, 'func3');
        expect(func3.identifier.span.start.offset, 46);
        expect(func3.identifier.span.end.offset, 51);
        expect(func3.parameters, isEmpty);
      },
    );
  });
}
