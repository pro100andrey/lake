import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('ServiceDefinition AST (positive):', () {
    test('should parse empty service', () {
      const source = 'service MyService {}';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ServiceDefinitionNode>();

      expect(def.span, hasSpan(0, 20));

      expect(def.identifier.value, 'MyService');
      expect(def.identifier.span, hasSpan(8, 17));

      expect(def.extendsService, isNull);
      expect(def.methods, isEmpty);
    });

    test('should parse service with one method', () {
      const source = 'service S { void foo(); }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ServiceDefinitionNode>();
      expect(def.span, hasSpan(0, 25));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(8, 9));

      expect(def.extendsService, isNull);

      expect(def.methods[0].returnType, isA<VoidTypeNode>());
      expect(def.methods[0].returnType.span, hasSpan(12, 16));

      expect(def.methods[0].parameters, isEmpty);

      expect(def.methods[0].identifier.value, 'foo');
      expect(def.methods[0].identifier.span, hasSpan(17, 20));
    });

    test(
      'should parse service with multiple functions without fieldID',
      () {
        const source = 'service S { void foo(); i32 bar(i32 x); }';
        final doc = parseAstFromString(source);

        final def = doc.definitions.first.cast<ServiceDefinitionNode>();
        expect(def.span, hasSpan(0, 41));

        expect(def.identifier.value, 'S');
        expect(def.identifier.span, hasSpan(8, 9));

        expect(def.extendsService, isNull);

        expect(def.methods, hasLength(2));

        final fn1 = def.methods[0];
        expect(fn1.returnType, isA<VoidTypeNode>());
        expect(fn1.returnType.span, hasSpan(12, 16));

        expect(fn1.parameters, isEmpty);

        expect(fn1.identifier.value, 'foo');
        expect(fn1.identifier.span, hasSpan(17, 20));

        final fn2 = def.methods[1];
        expect(fn2.returnType.cast<BaseTypeNode>().value, 'i32');
        expect(fn2.returnType.span, hasSpan(24, 27));

        expect(fn2.identifier.value, 'bar');
        expect(fn2.identifier.span, hasSpan(28, 31));

        expect(fn2.parameters, hasLength(1));

        final fn2Params = fn2.parameters[0];
        expect(fn2Params.type.cast<BaseTypeNode>().value, 'i32');
        expect(fn2Params.type.span, hasSpan(32, 35));

        expect(fn2Params.identifier.value, 'x');
        expect(fn2Params.identifier.span, hasSpan(36, 37));
      },
    );

    test('should parse service with method with fieldId', () {
      const source = 'service S { void foo(1: i32 x, 2: i32 y)}';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ServiceDefinitionNode>();
      expect(def.span, hasSpan(0, 41));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(8, 9));

      expect(def.extendsService, isNull);

      expect(def.methods, hasLength(1));

      final fn = def.methods[0];
      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span, hasSpan(12, 16));

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span, hasSpan(17, 20));

      expect(fn.parameters, hasLength(2));

      final [FieldNode parameter, FieldNode parameter1] = fn.parameters;

      expect(parameter.fieldId, isNotNull);
      expect(parameter.fieldId!.rawValue, '1');
      expect(parameter.fieldId!.value, 1);
      expect(parameter.fieldId!.span, hasSpan(21, 22));

      expect(parameter.type.cast<BaseTypeNode>().value, 'i32');
      expect(parameter.type.span, hasSpan(24, 27));

      expect(parameter.identifier.value, 'x');
      expect(parameter.identifier.span, hasSpan(28, 29));

      expect(parameter1.fieldId, isNotNull);
      expect(parameter1.fieldId!.rawValue, '2');
      expect(parameter1.fieldId!.value, 2);
      expect(parameter1.fieldId!.span, hasSpan(31, 32));

      expect(parameter1.type.cast<BaseTypeNode>().value, 'i32');
      expect(parameter1.type.span, hasSpan(34, 37));

      expect(parameter1.identifier.value, 'y');
      expect(parameter1.identifier.span, hasSpan(38, 39));
    });

    test('should parse service with extends', () {
      const source = 'service S extends Base { void foo(); }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<ServiceDefinitionNode>();
      expect(def.span, hasSpan(0, 38));

      expect(def.identifier.value, 'S');
      expect(def.identifier.span, hasSpan(8, 9));

      expect(def.extendsService, isNotNull);
      expect(def.extendsService!.value, 'Base');
      expect(def.extendsService!.span, hasSpan(18, 22));

      expect(def.methods, hasLength(1));

      final fn = def.methods[0];
      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span, hasSpan(25, 29));

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span, hasSpan(30, 33));

      expect(fn.parameters, isEmpty);
    });

    test(
      'should parse service with method arguments and throws without fieldId',
      () {
        const source =
            'service S { i32 foo(1: i32 x, 3: string y) throws (i32 err); }';
        final doc = parseAstFromString(source);

        final def = doc.definitions.first.cast<ServiceDefinitionNode>();
        expect(def.span, hasSpan(0, 62));

        expect(def.identifier.value, 'S');
        expect(def.identifier.span, hasSpan(8, 9));

        expect(def.extendsService, isNull);

        final [MethodNode fn] = def.methods;

        expect(fn.returnType.cast<BaseTypeNode>().value, 'i32');
        expect(fn.returnType.span, hasSpan(12, 15));

        expect(fn.identifier.value, 'foo');
        expect(fn.identifier.span, hasSpan(16, 19));

        final [FieldNode parameter, FieldNode parameter1] = fn.parameters;

        expect(parameter.fieldId!.rawValue, '1');
        expect(parameter.fieldId!.value, 1);
        expect(parameter.fieldId!.span, hasSpan(20, 21));

        expect(parameter.type.cast<BaseTypeNode>().value, 'i32');
        expect(parameter.type.span, hasSpan(23, 26));

        expect(parameter.identifier.value, 'x');
        expect(parameter.identifier.span, hasSpan(27, 28));

        expect(parameter1.fieldId!.rawValue, '3');
        expect(parameter1.fieldId!.value, 3);
        expect(parameter1.fieldId!.span, hasSpan(30, 31));

        expect(parameter1.type.cast<BaseTypeNode>().value, 'string');
        expect(parameter1.type.span, hasSpan(33, 39));

        expect(parameter1.identifier.value, 'y');
        expect(parameter1.identifier.span, hasSpan(40, 41));

        final [FieldNode throw0] = fn.throws;

        expect(throw0.span, hasSpan(51, 58));

        expect(throw0.type.cast<BaseTypeNode>().value, 'i32');
        expect(throw0.type.span, hasSpan(51, 54));

        expect(throw0.identifier, isNotNull);
        expect(throw0.identifier.value, 'err');
        expect(throw0.identifier.span, hasSpan(55, 58));
      },
    );

    test(
      'should parse service with method arguments and throws with fieldId',
      () {
        const source =
            'service S { i32 foo(1: i32 x, 3: string y) throws (1: i32 err); }';
        final doc = parseAstFromString(source);

        final def = doc.definitions.first.cast<ServiceDefinitionNode>();
        expect(def.span, hasSpan(0, 65));

        expect(def.identifier.value, 'S');
        expect(def.identifier.span, hasSpan(8, 9));

        expect(def.extendsService, isNull);

        final [MethodNode fn] = def.methods;

        expect(fn.returnType.cast<BaseTypeNode>().value, 'i32');
        expect(fn.returnType.span, hasSpan(12, 15));

        expect(fn.identifier.value, 'foo');
        expect(fn.identifier.span, hasSpan(16, 19));

        final [FieldNode p1, FieldNode p2] = fn.parameters;

        expect(p1.fieldId!.rawValue, '1');
        expect(p1.fieldId!.value, 1);
        expect(p1.fieldId!.span, hasSpan(20, 21));

        expect(p1.type.cast<BaseTypeNode>().value, 'i32');
        expect(p1.type.span, hasSpan(23, 26));

        expect(p1.identifier.value, 'x');
        expect(p1.identifier.span, hasSpan(27, 28));

        expect(p2.fieldId!.rawValue, '3');
        expect(p2.fieldId!.value, 3);
        expect(p2.fieldId!.span, hasSpan(30, 31));

        expect(p2.type.cast<BaseTypeNode>().value, 'string');
        expect(p2.type.span, hasSpan(33, 39));

        expect(p2.identifier.value, 'y');
        expect(p2.identifier.span, hasSpan(40, 41));

        final [FieldNode throwField] = fn.throws;

        expect(throwField.span, hasSpan(51, 61));

        expect(throwField.fieldId!.rawValue, '1');
        expect(throwField.fieldId!.value, 1);
        expect(throwField.fieldId!.span, hasSpan(51, 52));

        expect(throwField.type.cast<BaseTypeNode>().value, 'i32');
        expect(throwField.type.span, hasSpan(54, 57));

        expect(throwField.identifier.value, 'err');
        expect(throwField.identifier.span, hasSpan(58, 61));
      },
    );

    test(
      'should parse service with multiple functions separated by semicolon',
      () {
        const source =
            'service S { void func1(); string func2(); i32 func3(); }';
        final doc = parseAstFromString(source);

        final def = doc.definitions.first.cast<ServiceDefinitionNode>();
        expect(def.span, hasSpan(0, 56));

        expect(def.identifier.value, 'S');
        expect(def.identifier.span, hasSpan(8, 9));

        expect(def.extendsService, isNull);
        expect(def.methods, hasLength(3));

        final [MethodNode func1, MethodNode func2, MethodNode func3] =
            def.methods;

        expect(func1.returnType, isA<VoidTypeNode>());
        expect(func1.returnType.span, hasSpan(12, 16));

        expect(func1.identifier.value, 'func1');
        expect(func1.identifier.span, hasSpan(17, 22));

        expect(func2.returnType.cast<BaseTypeNode>().value, 'string');
        expect(func2.returnType.span, hasSpan(26, 32));

        expect(func2.identifier.value, 'func2');
        expect(func2.identifier.span, hasSpan(33, 38));

        expect(func3.returnType.cast<BaseTypeNode>().value, 'i32');
        expect(func3.returnType.span, hasSpan(42, 45));

        expect(func3.identifier.value, 'func3');
        expect(func3.identifier.span, hasSpan(46, 51));
        expect(func3.parameters, isEmpty);
      },
    );
  });

  group('ServiceDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source = 'service AuthService { void login(); }';
      const source2 = 'service AuthService { void login(); }';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final service1 = doc1.definitions.first.cast<ServiceDefinitionNode>();
      final service2 = doc2.definitions.first.cast<ServiceDefinitionNode>();

      expect(service1, equals(service2));
      expect(service1.methods, equals(service2.methods));
    });

    test('should not be equal for different definitions', () {
      const source1 = 'service AuthService { void login(); }';
      const source2 = 'service AuthService { void logout(); }';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final service1 = doc1.definitions.first.cast<ServiceDefinitionNode>();
      final service2 = doc2.definitions.first.cast<ServiceDefinitionNode>();

      expect(service1, isNot(equals(service2)));
      expect(service1.methods, isNot(equals(service2.methods)));
    });
  });
}
