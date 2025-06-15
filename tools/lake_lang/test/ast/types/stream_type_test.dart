import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('StreamType AST', () {
    test('should parse stream of base type', () {
      const source = 'stream<i32>';
      final doc = parseAndGetAst(
        'service S { stream<i32> processNumbers(stream<i32> input); }',
      );
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;

      // Test as return type
      final returnType = fn.returnType as StreamTypeNode;
      expect(returnType.span.text, source);
      expect(returnType.span.start.offset, 12);
      expect(returnType.span.end.offset, 23);

      final returnElementType = returnType.elementType as BaseTypeNode;
      expect(returnElementType.value, 'i32');
      expect(returnElementType.span.text, 'i32');
      expect(returnElementType.span.start.offset, 19);
      expect(returnElementType.span.end.offset, 22);

      // Test as parameter type
      final paramType = fn.parameters.first.type as StreamTypeNode;
      expect(paramType.span.text, source);
      expect(paramType.span.start.offset, 39);
      expect(paramType.span.end.offset, 50);

      final paramElementType = paramType.elementType as BaseTypeNode;
      expect(paramElementType.value, 'i32');
      expect(paramElementType.span.text, 'i32');
      expect(paramElementType.span.start.offset, 46);
      expect(paramElementType.span.end.offset, 49);
    });

    test('should parse stream of custom type', () {
      const source = 'stream<LogEntry>';
      final doc = parseAndGetAst('service S { $source getLogs(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;
      final streamType = fn.returnType as StreamTypeNode;

      expect(streamType.span.text, source);
      expect(streamType.span.start.offset, 12);
      expect(streamType.span.end.offset, 28);

      final elementType = streamType.elementType as CustomTypeNode;
      expect(elementType.value, 'LogEntry');
      expect(elementType.span.text, 'LogEntry');
      expect(elementType.span.start.offset, 19);
      expect(elementType.span.end.offset, 27);
    });

    test('should parse stream of nested container type (stream of lists)', () {
      const source = 'stream<list<string>>';
      final doc = parseAndGetAst('service S { $source getBatches(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;
      final streamType = fn.returnType as StreamTypeNode;

      expect(streamType.span.text, source);
      expect(streamType.span.start.offset, 12);
      expect(streamType.span.end.offset, 32);

      final elementType = streamType.elementType as ListTypeNode;
      expect(elementType.span.text, 'list<string>');
      expect(elementType.span.start.offset, 19);
      expect(elementType.span.end.offset, 31);

      final nestedElementType = elementType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'string');
      expect(nestedElementType.span.text, 'string');
      expect(nestedElementType.span.start.offset, 24);
      expect(nestedElementType.span.end.offset, 30);
    });

    test('should parse stream of map type', () {
      const source = 'stream<map<string, i32>>';
      final doc = parseAndGetAst('service S { $source getMappings(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.functions.first;
      final streamType = fn.returnType as StreamTypeNode;

      expect(streamType.span.text, source);
      expect(streamType.span.start.offset, 12);
      expect(streamType.span.end.offset, 36);

      final elementType = streamType.elementType as MapTypeNode;
      expect(elementType.span.text, 'map<string, i32>');
      expect(elementType.span.start.offset, 19);
      expect(elementType.span.end.offset, 35);

      expect(elementType.keyType, isA<BaseTypeNode>());
      expect(elementType.keyType.span.text, 'string');
      expect(elementType.keyType.span.start.offset, 23);
      expect(elementType.keyType.span.end.offset, 29);

      expect(elementType.valueType, isA<BaseTypeNode>());
      expect(elementType.valueType.span.text, 'i32');
      expect(elementType.valueType.span.start.offset, 31);
      expect(elementType.valueType.span.end.offset, 34);
    });
  });

  group('StreamType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'stream<CustomType>';
      final doc1 = parseAndGetAst('struct S { $source x; }');
      final doc2 = parseAndGetAst('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAndGetAst('struct S { stream<CustomType> x; }');
      final doc2 = parseAndGetAst('struct S { stream<AnotherType> x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
