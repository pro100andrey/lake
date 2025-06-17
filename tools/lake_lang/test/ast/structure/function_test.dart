import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('Function AST', () {
    test('should parse function with no parameters', () {
      const source = 'void foo();';
      final doc = parseAstFromString('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(14, 25));

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span, hasSpan(14, 18));

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span, hasSpan(19, 22));

      expect(fn.parameters, isEmpty);
    });

    test('should parse function with parameters without field identifiers', () {
      const source = 'AddResponse add(i32 a, i32 b)';
      final doc = parseAstFromString('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(14, 43));

      expect((fn.returnType as CustomTypeNode).value, 'AddResponse');
      expect(fn.returnType.span, hasSpan(14, 25));

      expect(fn.identifier.value, 'add');
      expect(fn.identifier.span, hasSpan(26, 29));

      expect(fn.parameters.length, 2);

      final field1 = fn.parameters[0];
      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span, hasSpan(30, 33));

      expect(field1.identifier.value, 'a');
      expect(field1.identifier.span, hasSpan(34, 35));

      expect(field1.defaultValue, isNull);
      expect(field1.requirement, isNull);

      final field2 = fn.parameters[1];
      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span, hasSpan(37, 40));

      expect(field2.identifier.value, 'b');
      expect(field2.identifier.span, hasSpan(41, 42));

      expect(field2.defaultValue, isNull);
      expect(field2.requirement, isNull);
    });

    test('should parse function with parameters with field identifiers', () {
      const source = 'UsersListResponse usersList(1:i32 a, 2:i32 b)';
      final doc = parseAstFromString('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(14, 59));

      expect((fn.returnType as CustomTypeNode).value, 'UsersListResponse');
      expect(fn.returnType.span, hasSpan(14, 31));

      expect(fn.identifier.value, 'usersList');
      expect(fn.identifier.span, hasSpan(32, 41));

      expect(fn.parameters.length, 2);

      final field1 = fn.parameters[0];

      expect(field1.fieldId, isNotNull);
      expect(field1.fieldId!.rawValue, '1');
      expect(field1.fieldId!.value, 1);
      expect(field1.fieldId!.span, hasSpan(42, 43));

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span, hasSpan(44, 47));

      expect(field1.identifier.value, 'a');
      expect(field1.identifier.span, hasSpan(48, 49));

      expect(field1.defaultValue, isNull);
      expect(field1.requirement, isNull);

      final field2 = fn.parameters[1];

      expect(field2.fieldId, isNotNull);
      expect(field2.fieldId!.rawValue, '2');
      expect(field2.fieldId!.value, 2);
      expect(field2.fieldId!.span, hasSpan(51, 52));

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span, hasSpan(53, 56));

      expect(field2.identifier.value, 'b');
      expect(field2.identifier.span, hasSpan(57, 58));

      expect(field2.defaultValue, isNull);
      expect(field2.requirement, isNull);
    });

    test('should parse function with throws (no fieldId)', () {
      const source = 'void foo() throws (CustomException err)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(12, 51));

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span, hasSpan(12, 16));

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span, hasSpan(17, 20));

      expect(fn.parameters, isEmpty);

      expect(fn.throws, hasLength(1));

      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNull);

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span, hasSpan(31, 46));

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span, hasSpan(47, 50));

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with throws (with fieldId)', () {
      const source = 'void foo() throws (1: CustomException err)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(12, 54));

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span, hasSpan(12, 16));

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span, hasSpan(17, 20));

      expect(fn.parameters, isEmpty);

      expect(fn.throws, hasLength(1));

      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNotNull);
      expect(throwField.fieldId!.rawValue, '1');
      expect(throwField.fieldId!.value, 1);
      expect(throwField.fieldId!.span, hasSpan(31, 32));

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span, hasSpan(34, 49));

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span, hasSpan(50, 53));

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with multiple parameters and throws', () {
      const source =
          'i32 sum(1: i32 a, 2: i32 b) throws (1: CustomException err)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(12, 71));

      expect((fn.returnType as BaseTypeNode).value, 'i32');
      expect(fn.returnType.span, hasSpan(12, 15));

      expect(fn.identifier.value, 'sum');
      expect(fn.identifier.span, hasSpan(16, 19));

      expect(fn.parameters, hasLength(2));
      final param1 = fn.parameters[0];
      expect(param1.fieldId, isNotNull);
      expect(param1.fieldId!.rawValue, '1');
      expect(param1.fieldId!.value, 1);
      expect(param1.fieldId!.span, hasSpan(20, 21));

      expect((param1.type as BaseTypeNode).value, 'i32');
      expect(param1.type.span, hasSpan(23, 26));

      expect(param1.identifier.value, 'a');
      expect(param1.identifier.span, hasSpan(27, 28));

      final param2 = fn.parameters[1];
      expect(param2.fieldId, isNotNull);
      expect(param2.fieldId!.rawValue, '2');
      expect(param2.fieldId!.value, 2);
      expect(param2.fieldId!.span, hasSpan(30, 31));

      expect((param2.type as BaseTypeNode).value, 'i32');
      expect(param2.type.span, hasSpan(33, 36));

      expect(param2.identifier.value, 'b');
      expect(param2.identifier.span, hasSpan(37, 38));

      expect(param2.defaultValue, isNull);
      expect(param2.requirement, isNull);

      expect(fn.throws, hasLength(1));
      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNotNull);
      expect(throwField.fieldId!.rawValue, '1');
      expect(throwField.fieldId!.value, 1);
      expect(throwField.fieldId!.span, hasSpan(48, 49));

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span, hasSpan(51, 66));

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span, hasSpan(67, 70));

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with stream parameter', () {
      const source = 'void streamFunc(stream<i32> s)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(12, 42));

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span, hasSpan(12, 16));

      expect(fn.identifier.value, 'streamFunc');
      expect(fn.identifier.span, hasSpan(17, 27));

      expect(fn.parameters, hasLength(1));
      final param = fn.parameters.first;
      expect(param.fieldId, isNull);

      expect(param.type is StreamTypeNode, isTrue);
      expect(param.type.span, hasSpan(28, 39));

      final streamType = param.type as StreamTypeNode;
      final elementType = streamType.elementType as BaseTypeNode;
      expect(elementType.value, 'i32');
      expect(elementType.span, hasSpan(35, 38));

      expect(param.identifier.value, 's');
      expect(param.identifier.span, hasSpan(40, 41));

      expect(param.defaultValue, isNull);
      expect(param.requirement, isNull);
    });

    test('should parse unidirectional function', () {
      const source = 'stream<ChatMessage> streamFunc(1: stream<ChatMessage> s)';
      final doc = parseAstFromString('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      expect(fn.span, hasSpan(12, 68));

      expect(fn.returnType is StreamTypeNode, isTrue);
      expect(fn.returnType.span, hasSpan(12, 31));

      final returnStreamType = fn.returnType as StreamTypeNode;
      final returnElementType = returnStreamType.elementType as CustomTypeNode;
      expect(returnElementType.value, 'ChatMessage');
      expect(returnElementType.span, hasSpan(19, 30));

      expect(fn.identifier.value, 'streamFunc');
      expect(fn.identifier.span, hasSpan(32, 42));

      expect(fn.parameters, hasLength(1));
      final param = fn.parameters.first;

      expect(param.fieldId, isNotNull);
      expect(param.fieldId!.rawValue, '1');
      expect(param.fieldId!.value, 1);
      expect(param.fieldId!.span, hasSpan(43, 44));

      expect(param.type is StreamTypeNode, isTrue);
      expect(param.type.span, hasSpan(46, 65));

      final paramStreamType = param.type as StreamTypeNode;
      final paramElementType = paramStreamType.elementType as CustomTypeNode;
      expect(paramElementType.value, 'ChatMessage');
      expect(paramElementType.span, hasSpan(53, 64));

      expect(param.identifier.value, 's');
      expect(param.identifier.span, hasSpan(66, 67));

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

      expect(service1.methods, equals(service2.methods));

      final parameters1 = service1.methods.first.parameters;
      final parameters2 = service2.methods.first.parameters;

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

      expect(service1.methods, isNot(equals(service2.methods)));

      final parameters1 = service1.methods.first.parameters;
      final parameters2 = service2.methods.first.parameters;

      expect(parameters1, isNot(equals(parameters2)));
    });
  });
}
