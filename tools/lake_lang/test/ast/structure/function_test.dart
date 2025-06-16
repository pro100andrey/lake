import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Function AST', () {
    test('should parse function with no parameters', () {
      const source = 'void foo();';
      final doc = parseAstFromString('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 14);
      expect(fn.span.end, 25);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.start, 14);
      expect(fn.returnType.span.end, 18);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.start, 19);
      expect(fn.identifier.span.end, 22);

      expect(fn.parameters, isEmpty);
    });

    test('should parse function with parameters without field identifiers', () {
      const source = 'AddResponse add(i32 a, i32 b)';
      final doc = parseAstFromString('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 14);
      expect(fn.span.end, 43);

      expect((fn.returnType as CustomTypeNode).value, 'AddResponse');
      expect(fn.returnType.span.start, 14);
      expect(fn.returnType.span.end, 25);

      expect(fn.identifier.value, 'add');
      expect(fn.identifier.span.start, 26);
      expect(fn.identifier.span.end, 29);

      expect(fn.parameters.length, 2);

      final field1 = fn.parameters[0];
      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.start, 30);
      expect(field1.type.span.end, 33);

      expect(field1.identifier.value, 'a');
      expect(field1.identifier.span.start, 34);
      expect(field1.identifier.span.end, 35);
      expect(field1.defaultValue, isNull);
      expect(field1.requirement, isNull);

      final field2 = fn.parameters[1];
      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.start, 37);
      expect(field2.type.span.end, 40);

      expect(field2.identifier.value, 'b');
      expect(field2.identifier.span.start, 41);
      expect(field2.identifier.span.end, 42);
      expect(field2.defaultValue, isNull);
      expect(field2.requirement, isNull);
    });

    test('should parse function with parameters with field identifiers', () {
      const source = 'UsersListResponse usersList(1:i32 a, 2:i32 b)';
      final doc = parseAstFromString('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 14);
      expect(fn.span.end, 59);

      expect((fn.returnType as CustomTypeNode).value, 'UsersListResponse');
      expect(fn.returnType.span.start, 14);
      expect(fn.returnType.span.end, 31);

      expect(fn.identifier.value, 'usersList');
      expect(fn.identifier.span.start, 32);
      expect(fn.identifier.span.end, 41);

      expect(fn.parameters.length, 2);

      final field1 = fn.parameters[0];

      expect(field1.fieldId, isNotNull);
      expect(field1.fieldId!.rawValue, '1');
      expect(field1.fieldId!.value, 1);
      expect(field1.fieldId!.span.start, 42);
      expect(field1.fieldId!.span.end, 43);

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.start, 44);
      expect(field1.type.span.end, 47);

      expect(field1.identifier.value, 'a');
      expect(field1.identifier.span.start, 48);
      expect(field1.identifier.span.end, 49);

      expect(field1.defaultValue, isNull);
      expect(field1.requirement, isNull);

      final field2 = fn.parameters[1];

      expect(field2.fieldId, isNotNull);
      expect(field2.fieldId!.rawValue, '2');
      expect(field2.fieldId!.value, 2);
      expect(field2.fieldId!.span.start, 51);
      expect(field2.fieldId!.span.end, 52);

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.start, 53);
      expect(field2.type.span.end, 56);

      expect(field2.identifier.value, 'b');
      expect(field2.identifier.span.start, 57);
      expect(field2.identifier.span.end, 58);

      expect(field2.defaultValue, isNull);
      expect(field2.requirement, isNull);
    });

    test('should parse function with throws (no fieldId)', () {
      const source = 'void foo() throws (CustomException err)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 12);
      expect(fn.span.end, 51);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.start, 12);
      expect(fn.returnType.span.end, 16);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.start, 17);
      expect(fn.identifier.span.end, 20);

      expect(fn.parameters, isEmpty);

      expect(fn.throws, hasLength(1));

      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNull);

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span.start, 31);
      expect(throwField.type.span.end, 46);

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span.start, 47);
      expect(throwField.identifier.span.end, 50);

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with throws (with fieldId)', () {
      const source = 'void foo() throws (1: CustomException err)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 12);
      expect(fn.span.end, 54);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.start, 12);
      expect(fn.returnType.span.end, 16);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.start, 17);
      expect(fn.identifier.span.end, 20);

      expect(fn.parameters, isEmpty);

      expect(fn.throws, hasLength(1));

      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNotNull);
      expect(throwField.fieldId!.rawValue, '1');
      expect(throwField.fieldId!.value, 1);
      expect(throwField.fieldId!.span.start, 31);

      expect(throwField.fieldId!.span.end, 32);
      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span.start, 34);
      expect(throwField.type.span.end, 49);

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span.start, 50);
      expect(throwField.identifier.span.end, 53);

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with multiple parameters and throws', () {
      const source =
          'i32 sum(1: i32 a, 2: i32 b) throws (1: CustomException err)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 12);
      expect(fn.span.end, 71);

      expect((fn.returnType as BaseTypeNode).value, 'i32');
      expect(fn.returnType.span.start, 12);
      expect(fn.returnType.span.end, 15);

      expect(fn.identifier.value, 'sum');
      expect(fn.identifier.span.start, 16);
      expect(fn.identifier.span.end, 19);

      expect(fn.parameters, hasLength(2));
      final param1 = fn.parameters[0];
      expect(param1.fieldId, isNotNull);
      expect(param1.fieldId!.rawValue, '1');
      expect(param1.fieldId!.value, 1);
      expect(param1.fieldId!.span.start, 20);
      expect(param1.fieldId!.span.end, 21);

      expect((param1.type as BaseTypeNode).value, 'i32');
      expect(param1.type.span.start, 23);
      expect(param1.type.span.end, 26);

      expect(param1.identifier.value, 'a');
      expect(param1.identifier.span.start, 27);
      expect(param1.identifier.span.end, 28);

      final param2 = fn.parameters[1];
      expect(param2.fieldId, isNotNull);
      expect(param2.fieldId!.rawValue, '2');
      expect(param2.fieldId!.value, 2);
      expect(param2.fieldId!.span.start, 30);
      expect(param2.fieldId!.span.end, 31);

      expect((param2.type as BaseTypeNode).value, 'i32');
      expect(param2.type.span.start, 33);
      expect(param2.type.span.end, 36);

      expect(param2.identifier.value, 'b');
      expect(param2.identifier.span.start, 37);
      expect(param2.identifier.span.end, 38);

      expect(param2.defaultValue, isNull);
      expect(param2.requirement, isNull);

      expect(fn.throws, hasLength(1));
      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNotNull);
      expect(throwField.fieldId!.rawValue, '1');
      expect(throwField.fieldId!.value, 1);
      expect(throwField.fieldId!.span.start, 48);
      expect(throwField.fieldId!.span.end, 49);

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span.start, 51);
      expect(throwField.type.span.end, 66);

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span.start, 67);
      expect(throwField.identifier.span.end, 70);

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with stream parameter', () {
      const source = 'void streamFunc(stream<i32> s)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 12);
      expect(fn.span.end, 42);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.start, 12);
      expect(fn.returnType.span.end, 16);

      expect(fn.identifier.value, 'streamFunc');
      expect(fn.identifier.span.start, 17);
      expect(fn.identifier.span.end, 27);

      expect(fn.parameters, hasLength(1));
      final param = fn.parameters.first;
      expect(param.fieldId, isNull);

      expect(param.type is StreamTypeNode, isTrue);
      expect(param.type.span.start, 28);
      expect(param.type.span.end, 39);

      final streamType = param.type as StreamTypeNode;
      final elementType = streamType.elementType as BaseTypeNode;
      expect(elementType.value, 'i32');
      expect(elementType.span.start, 35);
      expect(elementType.span.end, 38);

      expect(param.identifier.value, 's');
      expect(param.identifier.span.start, 40);
      expect(param.identifier.span.end, 41);

      expect(param.defaultValue, isNull);
      expect(param.requirement, isNull);
    });

    test('should parse unidirectional function', () {
      const source = 'stream<ChatMessage> streamFunc(1: stream<ChatMessage> s)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.start, 12);
      expect(fn.span.end, 68);

      expect(fn.returnType is StreamTypeNode, isTrue);
      expect(fn.returnType.span.start, 12);
      expect(fn.returnType.span.end, 31);

      final returnStreamType = fn.returnType as StreamTypeNode;
      final returnElementType = returnStreamType.elementType as CustomTypeNode;
      expect(returnElementType.value, 'ChatMessage');
      expect(returnElementType.span.start, 19);
      expect(returnElementType.span.end, 30);

      expect(fn.identifier.value, 'streamFunc');
      expect(fn.identifier.span.start, 32);
      expect(fn.identifier.span.end, 42);

      expect(fn.parameters, hasLength(1));
      final param = fn.parameters.first;

      expect(param.fieldId, isNotNull);
      expect(param.fieldId!.rawValue, '1');
      expect(param.fieldId!.value, 1);
      expect(param.fieldId!.span.start, 43);
      expect(param.fieldId!.span.end, 44);

      expect(param.type is StreamTypeNode, isTrue);
      expect(param.type.span.start, 46);
      expect(param.type.span.end, 65);

      final paramStreamType = param.type as StreamTypeNode;
      final paramElementType = paramStreamType.elementType as CustomTypeNode;
      expect(paramElementType.value, 'ChatMessage');
      expect(paramElementType.span.start, 53);
      expect(paramElementType.span.end, 64);

      expect(param.identifier.value, 's');
      expect(param.identifier.span.start, 66);
      expect(param.identifier.span.end, 67);

      expect(param.defaultValue, isNull);
      expect(param.requirement, isNull);
    });
  });

  group('Function AST (equality)', () {
    test('should equal if they have the same name and parameters', () {
      const source1 =
          'stream<ChatMessage> streamFunc(1: stream<ChatMessage> s)';
      const source2 =
          'stream<ChatMessage> streamFunc(1: stream<ChatMessage> s)';
      final doc1 = parseAstFromString('service S { $source1 }');
      final doc2 = parseAstFromString('service S { $source2 }');
      final service1 = doc1.definitions.first as ServiceDefinitionNode;
      final service2 = doc2.definitions.first as ServiceDefinitionNode;

      expect(service1.functions, equals(service2.functions));

      final parameters1 = service1.functions.first.parameters;
      final parameters2 = service2.functions.first.parameters;

      expect(parameters1, equals(parameters2));
    });

    test('should consider functions unequal if they have different names', () {
      const source1 =
          'stream<ChatMessage> streamFunc(1: stream<ChatMessage> s)';
      const source2 =
          'stream<ChatMessage> streamFunc2(1: stream<ChatMessage> s)';
      final doc1 = parseAstFromString('service S { $source1 }');
      final doc2 = parseAstFromString('service S { $source2 }');
      final service1 = doc1.definitions.first as ServiceDefinitionNode;
      final service2 = doc2.definitions.first as ServiceDefinitionNode;

      expect(service1.functions, isNot(equals(service2.functions)));

      final parameters1 = service1.functions.first.parameters;
      final parameters2 = service2.functions.first.parameters;

      expect(parameters1, isNot(equals(parameters2)));
    });
  });
}
