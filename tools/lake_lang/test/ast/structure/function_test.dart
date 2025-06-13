import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Function AST', () {
    test('should parse function with no parameters', () {
      const source = 'void foo();';
      final doc = parseAst('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 14);
      expect(fn.span.end.offset, 25);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.text, 'void');
      expect(fn.returnType.span.start.offset, 14);
      expect(fn.returnType.span.end.offset, 18);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.text, 'foo');
      expect(fn.identifier.span.start.offset, 19);
      expect(fn.identifier.span.end.offset, 22);

      expect(fn.parameters, isEmpty);
    });

    test('should parse function with parameters without field identifiers', () {
      const source = 'AddResponse add(i32 a, i32 b)';
      final doc = parseAst('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 14);
      expect(fn.span.end.offset, 43);

      expect((fn.returnType as CustomTypeNode).value, 'AddResponse');
      expect(fn.returnType.span.text, 'AddResponse');
      expect(fn.returnType.span.start.offset, 14);
      expect(fn.returnType.span.end.offset, 25);

      expect(fn.identifier.value, 'add');
      expect(fn.identifier.span.text, 'add');
      expect(fn.identifier.span.start.offset, 26);
      expect(fn.identifier.span.end.offset, 29);

      expect(fn.parameters.length, 2);

      final field1 = fn.parameters[0];
      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.text, 'i32');
      expect(field1.type.span.start.offset, 30);
      expect(field1.type.span.end.offset, 33);

      expect(field1.identifier.value, 'a');
      expect(field1.identifier.span.text, 'a');
      expect(field1.identifier.span.start.offset, 34);
      expect(field1.identifier.span.end.offset, 35);
      expect(field1.defaultValue, isNull);
      expect(field1.requirement, isNull);

      final field2 = fn.parameters[1];
      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.text, 'i32');
      expect(field2.type.span.start.offset, 37);
      expect(field2.type.span.end.offset, 40);

      expect(field2.identifier.value, 'b');
      expect(field2.identifier.span.text, 'b');
      expect(field2.identifier.span.start.offset, 41);
      expect(field2.identifier.span.end.offset, 42);
      expect(field2.defaultValue, isNull);
      expect(field2.requirement, isNull);
    });

    test('should parse function with parameters with field identifiers', () {
      const source = 'UsersListResponse usersList(1:i32 a, 2:i32 b)';
      final doc = parseAst('service Foo { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 14);
      expect(fn.span.end.offset, 59);

      expect((fn.returnType as CustomTypeNode).value, 'UsersListResponse');
      expect(fn.returnType.span.text, 'UsersListResponse');
      expect(fn.returnType.span.start.offset, 14);
      expect(fn.returnType.span.end.offset, 31);

      expect(fn.identifier.value, 'usersList');
      expect(fn.identifier.span.text, 'usersList');
      expect(fn.identifier.span.start.offset, 32);
      expect(fn.identifier.span.end.offset, 41);

      expect(fn.parameters.length, 2);

      final field1 = fn.parameters[0];

      expect(field1.fieldId, isNotNull);
      expect(field1.fieldId!.value, '1');
      expect(field1.fieldId!.span.text, '1');
      expect(field1.fieldId!.span.start.offset, 42);
      expect(field1.fieldId!.span.end.offset, 43);

      expect((field1.type as BaseTypeNode).value, 'i32');
      expect(field1.type.span.text, 'i32');
      expect(field1.type.span.start.offset, 44);
      expect(field1.type.span.end.offset, 47);

      expect(field1.identifier.value, 'a');
      expect(field1.identifier.span.text, 'a');
      expect(field1.identifier.span.start.offset, 48);
      expect(field1.identifier.span.end.offset, 49);

      expect(field1.defaultValue, isNull);
      expect(field1.requirement, isNull);

      final field2 = fn.parameters[1];

      expect(field2.fieldId, isNotNull);
      expect(field2.fieldId!.value, '2');
      expect(field2.fieldId!.span.text, '2');
      expect(field2.fieldId!.span.start.offset, 51);
      expect(field2.fieldId!.span.end.offset, 52);

      expect((field2.type as BaseTypeNode).value, 'i32');
      expect(field2.type.span.text, 'i32');
      expect(field2.type.span.start.offset, 53);
      expect(field2.type.span.end.offset, 56);

      expect(field2.identifier.value, 'b');
      expect(field2.identifier.span.text, 'b');
      expect(field2.identifier.span.start.offset, 57);
      expect(field2.identifier.span.end.offset, 58);

      expect(field2.defaultValue, isNull);
      expect(field2.requirement, isNull);
    });

    test('should parse function with throws (no fieldId)', () {
      const source = 'void foo() throws (CustomException err)';
      final doc = parseAst('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 12);
      expect(fn.span.end.offset, 51);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.text, 'void');
      expect(fn.returnType.span.start.offset, 12);
      expect(fn.returnType.span.end.offset, 16);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.text, 'foo');
      expect(fn.identifier.span.start.offset, 17);
      expect(fn.identifier.span.end.offset, 20);

      expect(fn.parameters, isEmpty);

      expect(fn.throws, hasLength(1));

      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNull);

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span.text, 'CustomException');
      expect(throwField.type.span.start.offset, 31);
      expect(throwField.type.span.end.offset, 46);

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span.text, 'err');
      expect(throwField.identifier.span.start.offset, 47);
      expect(throwField.identifier.span.end.offset, 50);

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with throws (with fieldId)', () {
      const source = 'void foo() throws (1: CustomException err)';
      final doc = parseAst('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 12);
      expect(fn.span.end.offset, 54);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.text, 'void');
      expect(fn.returnType.span.start.offset, 12);
      expect(fn.returnType.span.end.offset, 16);

      expect(fn.identifier.value, 'foo');
      expect(fn.identifier.span.text, 'foo');
      expect(fn.identifier.span.start.offset, 17);
      expect(fn.identifier.span.end.offset, 20);

      expect(fn.parameters, isEmpty);

      expect(fn.throws, hasLength(1));

      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNotNull);
      expect(throwField.fieldId!.value, '1');
      expect(throwField.fieldId!.span.text, '1');
      expect(throwField.fieldId!.span.start.offset, 31);

      expect(throwField.fieldId!.span.end.offset, 32);
      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span.text, 'CustomException');
      expect(throwField.type.span.start.offset, 34);
      expect(throwField.type.span.end.offset, 49);

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span.text, 'err');
      expect(throwField.identifier.span.start.offset, 50);
      expect(throwField.identifier.span.end.offset, 53);

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with multiple parameters and throws', () {
      const source =
          'i32 sum(1: i32 a, 2: i32 b) throws (1: CustomException err)';
      final doc = parseAst('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 12);
      expect(fn.span.end.offset, 71);

      expect((fn.returnType as BaseTypeNode).value, 'i32');
      expect(fn.returnType.span.text, 'i32');
      expect(fn.returnType.span.start.offset, 12);
      expect(fn.returnType.span.end.offset, 15);

      expect(fn.identifier.value, 'sum');
      expect(fn.identifier.span.text, 'sum');
      expect(fn.identifier.span.start.offset, 16);
      expect(fn.identifier.span.end.offset, 19);

      expect(fn.parameters, hasLength(2));
      final param1 = fn.parameters[0];
      expect(param1.fieldId, isNotNull);
      expect(param1.fieldId!.value, '1');
      expect(param1.fieldId!.span.text, '1');
      expect(param1.fieldId!.span.start.offset, 20);
      expect(param1.fieldId!.span.end.offset, 21);

      expect((param1.type as BaseTypeNode).value, 'i32');
      expect(param1.type.span.text, 'i32');
      expect(param1.type.span.start.offset, 23);
      expect(param1.type.span.end.offset, 26);

      expect(param1.identifier.value, 'a');
      expect(param1.identifier.span.text, 'a');
      expect(param1.identifier.span.start.offset, 27);
      expect(param1.identifier.span.end.offset, 28);

      final param2 = fn.parameters[1];
      expect(param2.fieldId, isNotNull);
      expect(param2.fieldId!.value, '2');
      expect(param2.fieldId!.span.text, '2');
      expect(param2.fieldId!.span.start.offset, 30);
      expect(param2.fieldId!.span.end.offset, 31);

      expect((param2.type as BaseTypeNode).value, 'i32');
      expect(param2.type.span.text, 'i32');
      expect(param2.type.span.start.offset, 33);
      expect(param2.type.span.end.offset, 36);

      expect(param2.identifier.value, 'b');
      expect(param2.identifier.span.text, 'b');
      expect(param2.identifier.span.start.offset, 37);
      expect(param2.identifier.span.end.offset, 38);

      expect(param2.defaultValue, isNull);
      expect(param2.requirement, isNull);

      expect(fn.throws, hasLength(1));
      final throwField = fn.throws.first;
      expect(throwField.fieldId, isNotNull);
      expect(throwField.fieldId!.value, '1');
      expect(throwField.fieldId!.span.text, '1');
      expect(throwField.fieldId!.span.start.offset, 48);
      expect(throwField.fieldId!.span.end.offset, 49);

      expect((throwField.type as CustomTypeNode).value, 'CustomException');
      expect(throwField.type.span.text, 'CustomException');
      expect(throwField.type.span.start.offset, 51);
      expect(throwField.type.span.end.offset, 66);

      expect(throwField.identifier.value, 'err');
      expect(throwField.identifier.span.text, 'err');
      expect(throwField.identifier.span.start.offset, 67);
      expect(throwField.identifier.span.end.offset, 70);

      expect(throwField.defaultValue, isNull);
      expect(throwField.requirement, isNull);
    });

    test('should parse function with stream parameter', () {
      const source = 'void streamFunc(stream<i32> s)';
      final doc = parseAst('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 12);
      expect(fn.span.end.offset, 42);

      expect(fn.returnType, isA<VoidTypeNode>());
      expect(fn.returnType.span.text, 'void');
      expect(fn.returnType.span.start.offset, 12);
      expect(fn.returnType.span.end.offset, 16);

      expect(fn.identifier.value, 'streamFunc');
      expect(fn.identifier.span.text, 'streamFunc');
      expect(fn.identifier.span.start.offset, 17);
      expect(fn.identifier.span.end.offset, 27);

      expect(fn.parameters, hasLength(1));
      final param = fn.parameters.first;
      expect(param.fieldId, isNull);

      expect(param.type is StreamTypeNode, isTrue);
      expect(param.type.span.text, 'stream<i32>');
      expect(param.type.span.start.offset, 28);
      expect(param.type.span.end.offset, 39);

      final streamType = param.type as StreamTypeNode;
      final elementType = streamType.elementType as BaseTypeNode;
      expect(elementType.value, 'i32');
      expect(elementType.span.text, 'i32');
      expect(elementType.span.start.offset, 35);
      expect(elementType.span.end.offset, 38);

      expect(param.identifier.value, 's');
      expect(param.identifier.span.text, 's');
      expect(param.identifier.span.start.offset, 40);
      expect(param.identifier.span.end.offset, 41);

      expect(param.defaultValue, isNull);
      expect(param.requirement, isNull);
    });

    test('should parse unidirectional function', () {
      const source = 'stream<ChatMessage> streamFunc(1: stream<ChatMessage> s)';
      final doc = parseAst('service S { $source }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      expect(fn.span.text, source);
      expect(fn.span.start.offset, 12);
      expect(fn.span.end.offset, 68);

      expect(fn.returnType is StreamTypeNode, isTrue);
      expect(fn.returnType.span.text, 'stream<ChatMessage>');
      expect(fn.returnType.span.start.offset, 12);
      expect(fn.returnType.span.end.offset, 31);

      final returnStreamType = fn.returnType as StreamTypeNode;
      final returnElementType = returnStreamType.elementType as CustomTypeNode;
      expect(returnElementType.value, 'ChatMessage');
      expect(returnElementType.span.text, 'ChatMessage');
      expect(returnElementType.span.start.offset, 19);
      expect(returnElementType.span.end.offset, 30);

      expect(fn.identifier.value, 'streamFunc');
      expect(fn.identifier.span.text, 'streamFunc');
      expect(fn.identifier.span.start.offset, 32);
      expect(fn.identifier.span.end.offset, 42);

      expect(fn.parameters, hasLength(1));
      final param = fn.parameters.first;

      expect(param.fieldId, isNotNull);
      expect(param.fieldId!.value, '1');
      expect(param.fieldId!.span.text, '1');
      expect(param.fieldId!.span.start.offset, 43);
      expect(param.fieldId!.span.end.offset, 44);

      expect(param.type is StreamTypeNode, isTrue);
      expect(param.type.span.text, 'stream<ChatMessage>');
      expect(param.type.span.start.offset, 46);
      expect(param.type.span.end.offset, 65);

      final paramStreamType = param.type as StreamTypeNode;
      final paramElementType = paramStreamType.elementType as CustomTypeNode;
      expect(paramElementType.value, 'ChatMessage');
      expect(paramElementType.span.text, 'ChatMessage');
      expect(paramElementType.span.start.offset, 53);
      expect(paramElementType.span.end.offset, 64);

      expect(param.identifier.value, 's');
      expect(param.identifier.span.text, 's');
      expect(param.identifier.span.start.offset, 66);
      expect(param.identifier.span.end.offset, 67);

      expect(param.defaultValue, isNull);
      expect(param.requirement, isNull);
    });
  });
}
