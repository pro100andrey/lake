import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('UnionDefinition AST', () {
    test('should parse empty union', () {
      const source = 'union U {}';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<UnionDefinitionNode>();

      expect(def.span, hasSpan(0, 10));

      expect(def.identifier.value, 'U');
      expect(def.identifier.span, hasSpan(6, 7));

      expect(def.fields, isEmpty);
    });

    test('should parse union with one field', () {
      const source = 'union U { i32 x }';
      final doc = parseAstFromString(source);
      final def = doc.definitions.first.cast<UnionDefinitionNode>();

      expect(def.span, hasSpan(0, 17));

      expect(def.identifier.value, 'U');
      expect(def.identifier.span, hasSpan(6, 7));

      final [FieldNode field] = def.fields;

      expect(field.type.cast<BaseTypeNode>().value, 'i32');
      expect(field.type.span, hasSpan(10, 13));

      expect(field.identifier.value, 'x');
      expect(field.identifier.span, hasSpan(14, 15));
    });

    test('should parse union with multiple fields', () {
      const source = 'union U { i32 x, string y }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<UnionDefinitionNode>();
      expect(def.span, hasSpan(0, 27));

      expect(def.identifier.value, 'U');
      expect(def.identifier.span, hasSpan(6, 7));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.type.cast<BaseTypeNode>().value, 'i32');
      expect(field1.type.span, hasSpan(10, 13));

      expect(field1.identifier.value, 'x');
      expect(field1.identifier.span, hasSpan(14, 15));
      expect(field1.defaultValue, isNull);

      expect(field2.type.cast<BaseTypeNode>().value, 'string');
      expect(field2.identifier.value, 'y');
    });

    test('should parse union with fieldId and default value', () {
      const source = 'union U { 1: i32 x = 42 }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<UnionDefinitionNode>();
      expect(def.span, hasSpan(0, 25));

      expect(def.identifier.value, 'U');
      expect(def.identifier.span, hasSpan(6, 7));

      final [FieldNode field] = def.fields;

      expect(field.fieldId, isNotNull);
      expect(field.fieldId!.rawValue, '1');
      expect(field.fieldId!.value, 1);
      expect(field.fieldId!.span, hasSpan(10, 11));

      expect(field.type.cast<BaseTypeNode>().value, 'i32');
      expect(field.type.span, hasSpan(13, 16));

      expect(field.identifier.value, 'x');
      expect(field.identifier.span, hasSpan(17, 18));

      final defaultValue = field.defaultValue!.cast<IntConstantNode>();

      expect(defaultValue.rawValue, '42');
      expect(defaultValue.value, 42);
      expect(defaultValue.span, hasSpan(21, 23));
    });

    test('should parse union with required fields', () {
      const source = 'union User { required i32 id; required string name; }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<UnionDefinitionNode>();
      expect(def.span, hasSpan(0, 53));

      expect(def.identifier.value, 'User');
      expect(def.identifier.span, hasSpan(6, 10));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'required');
      expect(field1.requirement!.span, hasSpan(13, 21));

      expect(field1.type.cast<BaseTypeNode>().value, 'i32');
      expect(field1.type.span, hasSpan(22, 25));

      expect(field1.identifier.value, 'id');
      expect(field1.identifier.span, hasSpan(26, 28));

      expect(field1.defaultValue, isNull);

      expect(field2.requirement!.value, 'required');
      expect(field2.requirement!.span, hasSpan(30, 38));

      expect(field2.type.cast<BaseTypeNode>().value, 'string');
      expect(field2.type.span, hasSpan(39, 45));

      expect(field2.identifier.value, 'name');
      expect(field2.identifier.span, hasSpan(46, 50));

      expect(field2.defaultValue, isNull);
    });

    test('should parse union with optional fields', () {
      const source =
          'union Config { optional string host; optional i32 port; }';
      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<UnionDefinitionNode>();
      expect(def.span.start, 0);
      expect(def.span.end, 57);

      expect(def.identifier.value, 'Config');
      expect(def.identifier.span, hasSpan(6, 12));

      final [FieldNode field1, FieldNode field2] = def.fields;

      expect(field1.requirement!.value, 'optional');
      expect(field1.requirement!.span, hasSpan(15, 23));

      expect(field1.type.cast<BaseTypeNode>().value, 'string');
      expect(field1.type.span, hasSpan(24, 30));

      expect(field1.identifier.value, 'host');
      expect(field1.identifier.span, hasSpan(31, 35));

      expect(field2.requirement!.value, 'optional');
      expect(field2.requirement!.span, hasSpan(37, 45));

      expect(field2.type.cast<BaseTypeNode>().value, 'i32');
      expect(field2.type.span, hasSpan(46, 49));

      expect(field2.identifier.value, 'port');
      expect(field2.identifier.span, hasSpan(50, 54));

      expect(field2.defaultValue, isNull);
    });

    test('should parse union with container types as fields', () {
      const source =
          'union Data '
          '{ '
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';

      final doc = parseAstFromString(source);

      final def = doc.definitions.first.cast<UnionDefinitionNode>();
      expect(def.span, hasSpan(0, 79));

      expect(def.identifier.value, 'Data');
      expect(def.identifier.span, hasSpan(6, 10));

      final [FieldNode field1, FieldNode field2, FieldNode field3] = def.fields;

      expect(field1.type.span, hasSpan(13, 25));

      final field1Type = field1.type.cast<ListTypeNode>();
      expect(field1Type.elementType, isA<BaseTypeNode>());
      expect(field1Type.elementType.span, hasSpan(18, 24));

      expect(field1.identifier.value, 'tags');
      expect(field1.identifier.span, hasSpan(26, 30));
      expect(field1.defaultValue, isNull);
      expect(field2.type.span, hasSpan(32, 48));

      final field2Type = field2.type.cast<MapTypeNode>();
      expect(field2Type.keyType, isA<BaseTypeNode>());
      expect(field2Type.keyType.span, hasSpan(36, 42));

      expect(field2Type.valueType, isA<BaseTypeNode>());
      expect(field2Type.valueType.span, hasSpan(44, 47));

      expect(field2.identifier.value, 'scores');
      expect(field2.identifier.span, hasSpan(49, 55));
      expect(field2.defaultValue, isNull);

      expect(field3.type.span, hasSpan(57, 66));

      final field3Type = field3.type.cast<SetTypeNode>();
      expect(field3Type.elementType, isA<BaseTypeNode>());
      expect(field3Type.elementType.span, hasSpan(61, 65));

      expect(field3.identifier.value, 'uniqueIds');
      expect(field3.identifier.span, hasSpan(67, 76));

      expect(field3.defaultValue, isNull);
    });
  });

  group('UnionDefinition AST (equable):', () {
    test('should be equal for identical definitions', () {
      const source =
          'union Data '
          '{'
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';

      const source2 =
          'union Data '
          '{'
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';
      final doc1 = parseAstFromString(source);
      final doc2 = parseAstFromString(source2);

      expect(doc1, equals(doc2));

      final def1 = doc1.definitions.first.cast<UnionDefinitionNode>();
      final def2 = doc2.definitions.first.cast<UnionDefinitionNode>();
      expect(def1, equals(def2));
      expect(def1.fields, equals(def2.fields));
    });

    test('should not be equal for different definitions', () {
      const source1 =
          'union Data '
          '{ '
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<uuid> uniqueIds; '
          '}';
      const source2 =
          'union Data '
          '{ '
          'list<string> tags; '
          'map<string, i32> scores; '
          'set<string> uniqueIds; '
          '}';
      final doc1 = parseAstFromString(source1);
      final doc2 = parseAstFromString(source2);

      expect(doc1, isNot(equals(doc2)));

      final def1 = doc1.definitions.first.cast<UnionDefinitionNode>();
      final def2 = doc2.definitions.first.cast<UnionDefinitionNode>();

      expect(def1, isNot(equals(def2)));
      expect(def1.fields, isNot(equals(def2.fields)));
    });
  });
}
