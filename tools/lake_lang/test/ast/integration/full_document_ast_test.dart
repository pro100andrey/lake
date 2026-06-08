import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Full Document AST', () {
    final ast = parseAstFromFile(
      'test/ast/integration/test_data/full_document_ast_test.lake',
    );

    test(
      'should parse the document successfully and check root properties',
      () {
        expect(ast.headers.length, 3);
        expect(ast.definitions.length, 22);
      },
    );

    test('should correctly parse import header', () {
      final importHeader = ast.headers[0].cast<ImportNode>();
      expect(importHeader.path.value, 'common/types.lake');
    });

    test('should correctly parse first namespace header (dart core_utils)', () {
      final namespace = ast.headers[1].cast<NamespaceNode>();
      expect(namespace.scope.name, 'dart');
      expect(namespace.identifier.name, 'core_utils');
    });

    test(
      'should correctly parse second namespace header (js web_components)',
      () {
        final namespace = ast.headers[2].cast<NamespaceNode>();
        expect(namespace.scope.name, 'js');
        expect(namespace.identifier.name, 'web_components');
      },
    );

    test('should parse i32 MAX_USERS constant', () {
      final constant = ast.definitions[0].cast<ConstDefinitionNode>();
      final type = constant.type.cast<BaseTypeNode>();
      expect(type.name, 'i32');

      expect(constant.identifier.name, 'MAX_USERS');

      final literal = constant.value.cast<IntLiteralNode>();
      expect(literal.value, 1000);
    });

    test('should parse string ADMIN_EMAIL constant', () {
      final constant = ast.definitions[1].cast<ConstDefinitionNode>();
      final type = constant.type.cast<BaseTypeNode>();
      expect(type.name, 'string');

      expect(constant.identifier.name, 'ADMIN_EMAIL');

      final literal = constant.value.cast<StringLiteralNode>();
      expect(literal.value, 'admin@example.com');
    });

    test('should parse bool DEBUG_MODE constant', () {
      final constant = ast.definitions[2].cast<ConstDefinitionNode>();
      final type = constant.type.cast<BaseTypeNode>();
      expect(type.name, 'bool');

      expect(constant.identifier.name, 'DEBUG_MODE');

      final literal = constant.value.cast<BoolLiteralNode>();
      expect(literal.value, true);
    });

    test('should parse double PI constant', () {
      final constant = ast.definitions[3].cast<ConstDefinitionNode>();
      final type = constant.type.cast<BaseTypeNode>();
      expect(type.name, 'double');

      expect(constant.identifier.name, 'PI');

      final literal = constant.value.cast<DoubleLiteralNode>();
      expect(literal.value, 3.14159);
    });

    test('should parse binary EMPTY_BINARY constant', () {
      final constant = ast.definitions[4].cast<ConstDefinitionNode>();
      final type = constant.type.cast<BaseTypeNode>();
      expect(type.name, 'binary');

      expect(constant.identifier.name, 'EMPTY_BINARY');

      final literal = constant.value.cast<StringLiteralNode>();
      expect(literal.value, '');
    });

    test('should parse uuid API_KEY_UUID constant', () {
      final constant = ast.definitions[5].cast<ConstDefinitionNode>();
      final type = constant.type.cast<BaseTypeNode>();
      expect(type.name, 'uuid');

      expect(constant.identifier.name, 'API_KEY_UUID');

      final literal = constant.value.cast<StringLiteralNode>();
      expect(literal.value, 'a1b2c3d4-e5f6-7890-1234-567890abcdef');
    });

    test('should parse list<i32> PRIME_NUMBERS constant', () {
      final constant = ast.definitions[6].cast<ConstDefinitionNode>();
      final type = constant.type.cast<ListTypeNode>();

      final elementType = type.elementType.cast<BaseTypeNode>();
      expect(elementType.name, 'i32');

      expect(constant.identifier.name, 'PRIME_NUMBERS');

      final value = constant.value.cast<ListLiteralNode>();
      final elements = value.elements.cast<IntLiteralNode>();
      expect(elements.length, 5);

      final [
        IntLiteralNode e0,
        IntLiteralNode e1,
        IntLiteralNode e2,
        IntLiteralNode e3,
        IntLiteralNode e4,
      ] = elements;

      expect(e0.value, 2);
      expect(e1.value, 3);
      expect(e2.value, 5);
      expect(e3.value, 7);
      expect(e4.value, 11);
    });

    test('should parse list<string> GREETINGS constant', () {
      final constant = ast.definitions[7].cast<ConstDefinitionNode>();
      final type = constant.type.cast<ListTypeNode>();

      final elementType = type.elementType.cast<BaseTypeNode>();
      expect(elementType.name, 'string');

      expect(constant.identifier.name, 'GREETINGS');

      final value = constant.value.cast<ListLiteralNode>();
      final elements = value.elements.cast<StringLiteralNode>();
      expect(elements.length, 3);

      final [StringLiteralNode e0, StringLiteralNode e1, StringLiteralNode e2] =
          elements;

      expect(e0.value, 'Hello');
      expect(e1.value, 'Hi');
      expect(e2.value, 'Greetings');
    });

    test('should parse list<bool> BOOLEAN_FLAGS constant', () {
      final constant = ast.definitions[8].cast<ConstDefinitionNode>();
      final type = constant.type.cast<ListTypeNode>();

      final elementType = type.elementType.cast<BaseTypeNode>();
      expect(elementType.name, 'bool');

      expect(constant.identifier.name, 'BOOLEAN_FLAGS');

      final value = constant.value.cast<ListLiteralNode>();
      final elements = value.elements.cast<BoolLiteralNode>();
      expect(elements.length, 2);

      final [BoolLiteralNode e0, BoolLiteralNode e1] = elements;

      expect(e0.value, true);
      expect(e1.value, false);
    });

    test('should parse list<list<i32>> NESTED_LIST constant', () {
      final constant = ast.definitions[9].cast<ConstDefinitionNode>();
      final type = constant.type.cast<ListTypeNode>();

      final innerListType = type.elementType.cast<ListTypeNode>();
      expect(innerListType.elementType.cast<BaseTypeNode>().name, 'i32');

      expect(constant.identifier.name, 'NESTED_LIST');

      final value = constant.value.cast<ListLiteralNode>();
      final elements = value.elements.cast<ListLiteralNode>();

      expect(elements.length, 2);

      final [ListLiteralNode nestedList1, ListLiteralNode nestedList2] =
          elements;
      expect(nestedList1.elements.length, 2);
      expect(nestedList2.elements.length, 1);

      final [IntLiteralNode e11, IntLiteralNode e12] = nestedList1.elements
          .cast<IntLiteralNode>();

      expect(e11.value, 1);
      expect(e12.value, 2);

      final [IntLiteralNode e21] = nestedList2.elements.cast<IntLiteralNode>();
      expect(e21.value, 3);
    });

    test('should parse map<string, i32> HTTP_STATUS_CODES constant', () {
      final constant = ast.definitions[10].cast<ConstDefinitionNode>();
      final type = constant.type.cast<MapTypeNode>();

      expect(type.keyType.cast<BaseTypeNode>().name, 'string');
      expect(type.valueType.cast<BaseTypeNode>().name, 'i32');

      expect(constant.identifier.name, 'HTTP_STATUS_CODES');

      final value = constant.value.cast<MapLiteralNode>();

      final entries = value.entries
          .cast<({StringLiteralNode key, IntLiteralNode value})>();

      expect(entries.length, 2);

      final [entry1, entry2] = entries;

      expect(entry1.key.value, 'OK');
      expect(entry1.value.value, 200);

      expect(entry2.key.value, 'NOT_FOUND');
      expect(entry2.value.value, 404);
    });

    test('should parse map<i32, string> ERROR_MESSAGES constant', () {
      final constant = ast.definitions[11].cast<ConstDefinitionNode>();
      final type = constant.type.cast<MapTypeNode>();

      expect(type.keyType.cast<BaseTypeNode>().name, 'i32');
      expect(type.valueType.cast<BaseTypeNode>().name, 'string');

      expect(constant.identifier.name, 'ERROR_MESSAGES');

      final value = constant.value.cast<MapLiteralNode>();
      final entries = value.entries
          .cast<({IntLiteralNode key, StringLiteralNode value})>();

      final [entry1, entry2] = entries;

      expect(entry1.key.value, 100);
      expect(entry1.value.value, 'Invalid Input');

      expect(entry2.key.value, 200);
      expect(entry2.value.value, 'Service Unavailable');
    });

    test('should parse map<string, list<string>> USER_ROLES constant', () {
      final constant = ast.definitions[12].cast<ConstDefinitionNode>();
      final type = constant.type.cast<MapTypeNode>();

      expect(type.keyType.cast<BaseTypeNode>().name, 'string');

      final listType = type.valueType.cast<ListTypeNode>();
      final elementType = listType.elementType.cast<BaseTypeNode>();
      expect(elementType.name, 'string');

      expect(constant.identifier.name, 'USER_ROLES');

      final value = constant.value.cast<MapLiteralNode>();
      final entries = value.entries
          .cast<({StringLiteralNode key, ListLiteralNode value})>();

      expect(entries.length, 2);

      final entry1 = entries[0];
      expect(entry1.key.value, 'admin');

      final listValue1 = entry1.value;
      final [StringLiteralNode e11, StringLiteralNode e12] = listValue1.elements
          .cast<StringLiteralNode>();

      expect(e11.value, 'create');
      expect(e12.value, 'delete');

      final entry2 = entries[1];
      expect(entry2.key.value, 'guest');

      final listValue2 = entry2.value;
      expect(listValue2.elements.length, 1);

      final [StringLiteralNode e21] = listValue2.elements
          .cast<StringLiteralNode>();
      expect(e21.value, 'read');
    });

    test('should parse Timestamp typedef', () {
      final typedefDef = ast.definitions[13].cast<TypedefDefinitionNode>();
      expect(typedefDef.identifier.name, 'Timestamp');

      final type = typedefDef.type.cast<BaseTypeNode>();
      expect(type.name, 'i64');
    });

    test('should parse StringMap typedef', () {
      final typedefDef = ast.definitions[14].cast<TypedefDefinitionNode>();
      expect(typedefDef.identifier.name, 'StringMap');

      final mapType = typedefDef.type.cast<MapTypeNode>();
      final keyType = mapType.keyType.cast<BaseTypeNode>();
      final valueType = mapType.valueType.cast<BaseTypeNode>();
      expect(keyType.name, 'string');
      expect(valueType.name, 'string');
    });

    test('should parse LogLevel enum definition', () {
      final enumDef = ast.definitions[15].cast<EnumDefinitionNode>();
      expect(enumDef.identifier.name, 'LogLevel');

      final [
        EnumValueNode member1,
        EnumValueNode member2,
        EnumValueNode member3,
      ] = enumDef.members;

      expect(member1.identifier.name, 'INFO');
      expect(member1.value, isNull);

      expect(member2.identifier.name, 'WARNING');
      expect(member2.value!.value, 1);

      expect(member3.identifier.name, 'ERROR');
      expect(member3.value, isNull);
    });

    test('should parse Point struct definition', () {
      final structDef = ast.definitions[16].cast<StructDefinitionNode>();
      expect(structDef.identifier.name, 'Point');

      final [FieldNode field1, FieldNode field2] = structDef.fields;

      expect(field1.fieldId!.value, 1);
      expect(field1.type.cast<BaseTypeNode>().name, 'i32');
      expect(field1.identifier.name, 'x');

      expect(field2.type.cast<BaseTypeNode>().name, 'i32');
      expect(field2.identifier.name, 'y');
    });

    test('should parse UserProfile struct definition', () {
      final structDef = ast.definitions[17].cast<StructDefinitionNode>();
      expect(structDef.identifier.name, 'UserProfile');

      final [
        FieldNode f1,
        FieldNode f2,
        FieldNode f3,
        FieldNode f4,
        FieldNode f5,
        FieldNode f6,
        FieldNode f7,
      ] = structDef.fields;

      // 1: required string username;
      expect(f1.fieldId!.value, 1);
      expect(f1.isRequired, isTrue);
      expect(f1.type.cast<BaseTypeNode>().name, 'string');
      expect(f1.identifier.name, 'username');

      // 2: optional string email = "user@example.com";
      expect(f2.fieldId!.value, 2);
      expect(f2.isRequired, isFalse);
      expect(f2.isRequired ? 'required' : 'optional', 'optional');
      expect(f2.type.cast<BaseTypeNode>().name, 'string');
      expect(f2.identifier.name, 'email');
      expect(
        f2.defaultValue!.cast<StringLiteralNode>().value,
        'user@example.com',
      );

      // 3: Timestamp lastLogin;
      expect(f3.fieldId!.value, 3);
      expect(f3.isRequired, isFalse);
      expect(f3.type.cast<CustomTypeNode>().name, 'Timestamp');
      expect(f3.identifier.name, 'lastLogin');

      // 4: LogLevel currentLogLevel;
      expect(f4.fieldId!.value, 4);
      expect(f4.type.cast<CustomTypeNode>().name, 'LogLevel');
      expect(f4.identifier.name, 'currentLogLevel');

      // 5: Point location;
      expect(f5.fieldId!.value, 5);
      expect(f5.type.cast<CustomTypeNode>().name, 'Point');
      expect(f5.identifier.name, 'location');

      // 6: list<string> interests = ["coding", "reading"];
      expect(f6.fieldId!.value, 6);
      expect(
        f6.type.cast<ListTypeNode>().elementType.cast<BaseTypeNode>().name,
        'string',
      );
      expect(f6.identifier.name, 'interests');

      final [StringLiteralNode f6e1, StringLiteralNode f6e2] = f6.defaultValue!
          .cast<ListLiteralNode>()
          .elements
          .cast<StringLiteralNode>();

      expect(f6e1.value, 'coding');
      expect(f6e2.value, 'reading');

      // 7: map<string, string> metadata;
      expect(f7.fieldId!.value, 7);
      final mapType = f7.type.cast<MapTypeNode>();
      expect(mapType.keyType, isA<BaseTypeNode>());
      expect(mapType.valueType, isA<BaseTypeNode>());
      expect(f7.identifier.name, 'metadata');
    });

    test('should parse AnyValue union definition', () {
      final unionDef = ast.definitions[18].cast<UnionDefinitionNode>();
      expect(unionDef.identifier.name, 'AnyValue');
      expect(unionDef.fields.length, 3);

      final [FieldNode f1, FieldNode f2, FieldNode f3] = unionDef.fields;

      // 1: i32 intValue;
      expect(f1.fieldId!.value, 1);
      expect(f1.type.cast<BaseTypeNode>().name, 'i32');
      expect(f1.identifier.name, 'intValue');

      // 2: string stringValue;
      expect(f2.fieldId!.value, 2);
      expect(f2.type.cast<BaseTypeNode>().name, 'string');
      expect(f2.identifier.name, 'stringValue');

      // 3: bool boolValue;
      expect(f3.fieldId!.value, 3);
      expect(f3.type.cast<BaseTypeNode>().name, 'bool');
      expect(f3.identifier.name, 'boolValue');
    });

    test('should parse InvalidArgumentException exception definition', () {
      final exceptionDef = ast.definitions[19].cast<ExceptionDefinitionNode>();
      expect(exceptionDef.identifier.name, 'InvalidArgumentException');
      expect(exceptionDef.fields.length, 2);

      final [FieldNode f1, FieldNode f2] = exceptionDef.fields;

      // 1: string argumentName;
      expect(f1.fieldId!.value, 1);
      expect(f1.type.cast<BaseTypeNode>().name, 'string');
      expect(f1.identifier.name, 'argumentName');

      // 2: string details;
      expect(f2.fieldId!.value, 2);
      expect(f2.type.cast<BaseTypeNode>().name, 'string');
      expect(f2.identifier.name, 'details');
    });

    test('should parse CalculatorService definition', () {
      final serviceDef = ast.definitions[20].cast<ServiceDefinitionNode>();
      expect(serviceDef.identifier.name, 'CalculatorService');
      expect(serviceDef.extendsService, isNull);
      expect(serviceDef.methods.length, 6);

      final [
        MethodNode m1,
        MethodNode m2,
        MethodNode m3,
        MethodNode m4,
        MethodNode m5,
        MethodNode m6,
      ] = serviceDef.methods;

      // i32 add(1: i32 a, 2: i32 b);

      expect(m1.returnType.cast<BaseTypeNode>().name, 'i32');
      expect(m1.identifier.name, 'add');

      final [FieldNode m1p1, FieldNode m1p2] = m1.parameters;

      expect(m1p1.fieldId!.value, 1);
      expect(m1p1.type.cast<BaseTypeNode>().name, 'i32');
      expect(m1p1.identifier.name, 'a');

      expect(m1p2.fieldId!.value, 2);
      expect(m1p2.type.cast<BaseTypeNode>().name, 'i32');
      expect(m1p2.identifier.name, 'b');

      expect(m1.throws, isEmpty);

      // double divide(...) throws (...)

      expect(m2.returnType.cast<BaseTypeNode>().name, 'double');
      expect(m2.identifier.name, 'divide');
      expect(m2.parameters.length, 2);

      final [FieldNode m2p1, FieldNode m2p2] = m2.parameters;
      expect(m2p1.fieldId!.value, 1);
      expect(m2p1.type.cast<BaseTypeNode>().name, 'double');
      expect(m2p1.identifier.name, 'numerator');

      expect(m2p2.fieldId!.value, 2);
      expect(m2p2.type.cast<BaseTypeNode>().name, 'double');
      expect(m2p2.identifier.name, 'denominator');

      final [FieldNode m2t1] = m2.throws;
      expect(m2t1.fieldId!.value, 1);
      expect(
        m2t1.type.cast<CustomTypeNode>().name,
        'InvalidArgumentException',
      );
      expect(m2t1.identifier.name, 'divideByZero');

      // void sendMessage(1: string message, 2: optional string recipient);
      expect(m3.returnType, isA<VoidTypeNode>());
      expect(m3.identifier.name, 'sendMessage');

      final [FieldNode m3p1, FieldNode m3p2] = m3.parameters;

      expect(m3p1.fieldId!.value, 1);
      expect(m3p1.type.cast<BaseTypeNode>().name, 'string');
      expect(m3p1.identifier.name, 'message');

      expect(m3p2.fieldId!.value, 2);
      expect(m3p2.isRequired, isFalse);
      expect(m3p2.isRequired ? 'required' : 'optional', 'optional');
      expect(m3p2.type.cast<BaseTypeNode>().name, 'string');
      expect(m3p2.identifier.name, 'recipient');
      expect(m3.throws, isEmpty);

      // stream<string> getLogs(1: LogLevel level);
      final stream = m4.returnType.cast<StreamTypeNode>();
      expect(stream.elementType.cast<BaseTypeNode>().name, 'string');
      expect(m4.identifier.name, 'getLogs');

      final [FieldNode m4p1] = m4.parameters;

      expect(m4p1.fieldId!.value, 1);
      expect(m4p1.type.cast<CustomTypeNode>().name, 'LogLevel');
      expect(m4p1.identifier.name, 'level');
      expect(m4.throws, isEmpty);

      // Point getPoint(1: i32 id);
      expect(m5.returnType.cast<CustomTypeNode>().name, 'Point');
      expect(m5.identifier.name, 'getPoint');

      final [FieldNode m5p1] = m5.parameters;

      expect(m5p1.fieldId!.value, 1);
      expect(m5p1.type.cast<BaseTypeNode>().name, 'i32');
      expect(m5p1.identifier.name, 'id');
      expect(m5.throws, isEmpty);

      // list<i32> getPrimes(...);
      final listType = m6.returnType.cast<ListTypeNode>();
      expect(listType.elementType.cast<BaseTypeNode>().name, 'i32');
      expect(m6.identifier.name, 'getPrimes');

      final [FieldNode m6p1] = m6.parameters;
      expect(m6p1.fieldId!.value, 1);
      expect(m6p1.type.cast<BaseTypeNode>().name, 'i32');
      expect(m6p1.identifier.name, 'count');
      expect(m6.throws, isEmpty);
    });

    test('should parse AdminService definition', () {
      final serviceDef = ast.definitions[21].cast<ServiceDefinitionNode>();
      expect(serviceDef.identifier.name, 'AdminService');
      expect(serviceDef.extendsService, isNotNull);
      expect(serviceDef.extendsService!.name, 'CalculatorService');
      expect(serviceDef.methods.length, 3);

      final [
        MethodNode m1,
        MethodNode m2,
        MethodNode m3,
      ] = serviceDef.methods;

      // bool createUser(...) throws (...);
      expect(m1.returnType.cast<BaseTypeNode>().name, 'bool');
      expect(m1.identifier.name, 'createUser');
      expect(m1.parameters.length, 1);

      final [FieldNode m1p1] = m1.parameters;
      expect(m1p1.fieldId!.value, 1);
      expect(m1p1.type.cast<CustomTypeNode>().name, 'UserProfile');
      expect(m1p1.identifier.name, 'profile');

      final [FieldNode m1t1] = m1.throws;
      expect(m1t1.fieldId!.value, 1);
      expect(
        m1t1.type.cast<CustomTypeNode>().name,
        'InvalidArgumentException',
      );
      expect(m1t1.identifier.name, 'invalidProfile');

      // void deleteUser(1: i32 userId);
      expect(m2.returnType, isA<VoidTypeNode>());
      expect(m2.identifier.name, 'deleteUser');
      expect(m2.parameters.length, 1);

      final [FieldNode m2p1] = m2.parameters;
      expect(m2p1.fieldId!.value, 1);
      expect(m2p1.type.cast<BaseTypeNode>().name, 'i32');
      expect(m2p1.identifier.name, 'userId');
      expect(m2.throws, isEmpty);

      // void shutdown();
      expect(m3.returnType, isA<VoidTypeNode>());
      expect(m3.identifier.name, 'shutdown');
      expect(m3.parameters, isEmpty);
      expect(m3.throws, isEmpty);
    });
  });
}
