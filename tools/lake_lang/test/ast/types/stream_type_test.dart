import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../../testing/matchers.dart';
import '../_ast_helpers.dart';

void main() {
  group('StreamType AST', () {
    test('should parse stream of base type', () {
      final doc = parseAstFromString(
        'service S { stream<i32> processNumbers(stream<i32> input); }',
      );
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      final returnType = fn.returnType as StreamTypeNode;
      expect(returnType.span, hasSpan(12, 23));

      final returnElementType = returnType.elementType as BaseTypeNode;
      expect(returnElementType.value, 'i32');
      expect(returnElementType.span, hasSpan(19, 22));

      final paramType = fn.parameters.first.type as StreamTypeNode;
      expect(paramType.span, hasSpan(39, 50));

      final paramElementType = paramType.elementType as BaseTypeNode;
      expect(paramElementType.value, 'i32');
      expect(paramElementType.span, hasSpan(46, 49));
    });

    test('should parse stream of custom type', () {
      const source = 'stream<LogEntry>';
      final doc = parseAstFromString('service S { $source getLogs(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      final streamType = fn.returnType as StreamTypeNode;
      expect(streamType.span, hasSpan(12, 28));

      final elementType = streamType.elementType as CustomTypeNode;
      expect(elementType.value, 'LogEntry');
      expect(elementType.span, hasSpan(19, 27));
    });

    test('should parse stream of nested container type (stream of lists)', () {
      const source = 'stream<list<string>>';
      final doc = parseAstFromString('service S { $source getBatches(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      final streamType = fn.returnType as StreamTypeNode;
      expect(streamType.span, hasSpan(12, 32));

      final elementType = streamType.elementType as ListTypeNode;
      expect(elementType.span, hasSpan(19, 31));

      final nestedElementType = elementType.elementType as BaseTypeNode;
      expect(nestedElementType.value, 'string');
      expect(nestedElementType.span, hasSpan(24, 30));
    });

    test('should parse stream of map type', () {
      const source = 'stream<map<string, i32>>';
      final doc = parseAstFromString('service S { $source getMappings(); }');
      final service = doc.definitions.first as ServiceDefinitionNode;
      final fn = service.methods.first;

      final streamType = fn.returnType as StreamTypeNode;
      expect(streamType.span, hasSpan(12, 36));

      final elementType = streamType.elementType as MapTypeNode;
      expect(elementType.span, hasSpan(19, 35));

      expect(elementType.keyType, isA<BaseTypeNode>());
      expect(elementType.keyType.span, hasSpan(23, 29));

      expect(elementType.valueType, isA<BaseTypeNode>());
      expect(elementType.valueType.span, hasSpan(31, 34));
    });
  });

  group('StreamType AST (equality)', () {
    test('should be equal for same type', () {
      const source = 'stream<CustomType>';
      final doc1 = parseAstFromString('struct S { $source x; }');
      final doc2 = parseAstFromString('struct S { $source x; }');

      expect(doc1, equals(doc2));

      final struct1 = doc1.definitions.first as StructDefinitionNode;
      final struct2 = doc2.definitions.first as StructDefinitionNode;

      expect(struct1, equals(struct2));

      final field1 = struct1.fields[0];
      final field2 = struct2.fields[0];

      expect(field1.type, equals(field2.type));
    });

    test('should not be equal for different types', () {
      final doc1 = parseAstFromString('struct S { stream<CustomType> x; }');
      final doc2 = parseAstFromString('struct S { stream<AnotherType> x; }');

      final def1 = doc1.definitions.first as StructDefinitionNode;
      final def2 = doc2.definitions.first as StructDefinitionNode;

      expect(def1, isNot(equals(def2)));

      final field1 = def1.fields[0];
      final field2 = def2.fields[0];

      expect(field1.type, isNot(equals(field2.type)));
    });
  });
}
