import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Identifier AST', () {
    test('should parse a simple identifier', () {
      const source = 'myVariable';
      final doc = parseAstFromString('struct S { i32 $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final identifier = field.identifier;

      expect(identifier.value, 'myVariable');
      expect(identifier.span.start, 15);
      expect(identifier.span.end, 25);
    });

    test('should parse an identifier with underscores', () {
      const source = 'my_long_variable_name';
      final doc = parseAstFromString(
        'service MyService { void foo(string $source); }',
      );
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;
      final parameter = fn.parameters.first;
      final identifier = parameter.identifier;

      expect(identifier.value, 'my_long_variable_name');
      expect(identifier.span.start, 36);
      expect(identifier.span.end, 57);
    });

    test('should parse an identifier starting with an underscore', () {
      const source = '_privateField';
      final doc = parseAstFromString('struct S { bool $source; }');
      final struct = doc.definitions.first as StructDefinitionNode;
      final field = struct.fields.first;
      final identifier = field.identifier;

      expect(identifier.value, '_privateField');
      expect(identifier.span.start, 16);
      expect(identifier.span.end, 29);
    });

    test('should parse an identifier with numbers', () {
      const source = 'data2023';
      final doc = parseAstFromString('enum MyEnum { $source = 1; }');
      final enumDef = doc.definitions.first as EnumDefinitionNode;
      final enumField = enumDef.members.first;
      final identifier = enumField.identifier;

      expect(identifier.value, 'data2023');
      expect(identifier.span.start, 14);
      expect(identifier.span.end, 22);
    });

    test('should parse an identifier which is a keyword as part of a name', () {
      const source = 'structData';
      final doc = parseAstFromString('typedef i32 $source;');
      final typedefDef = doc.definitions.first as TypedefDefinitionNode;
      final identifier = typedefDef.identifier;

      expect(identifier.value, 'structData');
      expect(identifier.span.start, 12);
      expect(identifier.span.end, 22);
    });

    test('should parse an identifier as a service name', () {
      const source = 'PaymentService';
      final doc = parseAstFromString(
        'service $source { void processPayment(); }',
      );
      final service = doc.definitions.first as ServiceDefinitionNode;
      final identifier = service.identifier;

      expect(identifier.value, 'PaymentService');
      expect(identifier.span.start, 8);
      expect(identifier.span.end, 22);
    });

    // Test case for identifier used as enum name
    test('should parse an identifier as an enum name', () {
      const source = 'UserStatus';
      final doc = parseAstFromString('enum $source { ACTIVE, INACTIVE; }');
      final enumDef = doc.definitions.first as EnumDefinitionNode;
      final identifier = enumDef.identifier;

      expect(identifier.value, 'UserStatus');
      expect(identifier.span.start, 5);
      expect(identifier.span.end, 15);
    });
  });

  group('Identifier AST (equable):', () {
    test('should be equatable for same identifiers', () {
      const source = 'myVariable';
      const source2 = 'myVariable';
      final doc1 = parseAstFromString('struct S { i32 $source; }');
      final doc2 = parseAstFromString('struct S { i32 $source2; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1.identifier, equals(field2.identifier));
    });

    test('should not be equatable for different identifiers', () {
      const source1 = 'varOne';
      const source2 = 'varTwo';
      final doc1 = parseAstFromString('struct S { i32 $source1; }');
      final doc2 = parseAstFromString('struct S { i32 $source2; }');

      expect(doc1, isNot(equals(doc2)));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, isNot(equals(struct2)));

      final field1 = struct1.fields.first;
      final field2 = struct2.fields.first;

      expect(field1.identifier, isNot(equals(field2.identifier)));
    });
  });
}
