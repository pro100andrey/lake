import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/rules/utils.dart';
import 'package:lake_lang/src/analyzer/semantic_types.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_table.dart';
import 'package:lake_lang/src/analyzer/utils.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

/// Parse a Lake snippet and return the document.
DocumentNode _parse(String source) {
  final reporter = ErrorReporter();
  final parser = LakeParser(source, reporter);
  return parser.parseDocument();
}

void main() {
  group('getSemanticType()', () {
    late ErrorReporter reporter;
    late SymbolTable symbolTable;

    setUp(() {
      reporter = ErrorReporter();
      symbolTable = SymbolTable(reporter);
    });

    group('base types', () {
      final baseTypeNames = [
        'i8',
        'i16',
        'i32',
        'i64',
        'double',
        'string',
        'bool',
        'byte',
        'binary',
      ];

      for (final typeName in baseTypeNames) {
        test('resolves $typeName', () {
          final doc = _parse(
            'const $typeName x = ${_defaultValueFor(typeName)};',
          );
          final constNode = doc.definitions.first as ConstDefinitionNode;
          final result = getSemanticType(
            constNode.type,
            reporter,
            symbolTable,
          );

          expect(result, isNotNull);
          expect(result, isA<BaseType>());
          expect(result!.name, equals(typeName));
          expect(reporter.hasErrors, isFalse);
        });
      }

      test('resolves uuid', () {
        // uuid may not appear as a const type easily, but we can test
        // the BaseTypeNode directly
        const typeNode = BaseTypeNode(
          name: 'uuid',
          startOffset: 0,
          endOffset: 4,
        );
        final result = getSemanticType(typeNode, reporter, symbolTable);
        expect(result, isNotNull);
        expect(result!.name, equals('uuid'));
      });

      test('reports error for unknown base type', () {
        const typeNode = BaseTypeNode(
          name: 'int128',
          startOffset: 0,
          endOffset: 6,
        );
        final result = getSemanticType(typeNode, reporter, symbolTable);
        expect(result, isNull);
        expect(reporter.hasErrors, isTrue);
        expect(
          reporter.diagnostics.first.message,
          contains('Unknown base type'),
        );
      });
    });

    group('container types', () {
      test('resolves ListTypeNode', () {
        final doc = _parse('struct Foo { list<i32> items; }');
        final structNode = doc.definitions.first as StructDefinitionNode;
        final fieldType = structNode.fields.first.type;

        final result = getSemanticType(fieldType, reporter, symbolTable);
        expect(result, isNotNull);
        expect(result, isA<ListType>());
        expect(result!.name, equals('List<i32>'));
      });

      test('resolves MapTypeNode', () {
        final doc = _parse('struct Foo { map<string, i32> data; }');
        final structNode = doc.definitions.first as StructDefinitionNode;
        final fieldType = structNode.fields.first.type;

        final result = getSemanticType(fieldType, reporter, symbolTable);
        expect(result, isNotNull);
        expect(result, isA<MapType>());
        expect(result!.name, equals('Map<string, i32>'));
      });

      test('resolves SetTypeNode', () {
        final doc = _parse('struct Foo { set<string> tags; }');
        final structNode = doc.definitions.first as StructDefinitionNode;
        final fieldType = structNode.fields.first.type;

        final result = getSemanticType(fieldType, reporter, symbolTable);
        expect(result, isNotNull);
        expect(result, isA<SetType>());
        expect(result!.name, equals('Set<string>'));
      });

      test('resolves VoidTypeNode', () {
        // Void appears as a return type in service methods
        final doc = _parse('''
service MyService {
  void doSomething();
}
''');
        final serviceNode = doc.definitions.first as ServiceDefinitionNode;
        final methodReturnType = serviceNode.methods.first.returnType;

        final result = getSemanticType(
          methodReturnType,
          reporter,
          symbolTable,
        );
        expect(result, isNotNull);
        expect(result, isA<VoidType>());
        expect(result!.name, equals('void'));
      });

      test('resolves nested list type', () {
        final doc = _parse('struct Foo { list<list<i32>> matrix; }');
        final structNode = doc.definitions.first as StructDefinitionNode;
        final fieldType = structNode.fields.first.type;

        final result = getSemanticType(fieldType, reporter, symbolTable);
        expect(result, isNotNull);
        expect(result, isA<ListType>());
        final listType = result! as ListType;
        expect(listType.elementType, isA<ListType>());
        expect(
          (listType.elementType as ListType).elementType,
          equals(BaseType.i32T),
        );
      });
    });
  });

  group('getTypeName()', () {
    test('BaseTypeNode', () {
      const typeNode = BaseTypeNode(
        name: 'i32',
        startOffset: 0,
        endOffset: 3,
      );
      expect(getTypeName(typeNode), equals('i32'));
    });

    test('ListTypeNode', () {
      const elementType = BaseTypeNode(
        name: 'string',
        startOffset: 5,
        endOffset: 11,
      );
      const listType = ListTypeNode(
        elementType: elementType,
        startOffset: 0,
        endOffset: 12,
      );
      expect(getTypeName(listType), equals('list<string>'));
    });

    test('MapTypeNode', () {
      const keyType = BaseTypeNode(
        name: 'string',
        startOffset: 4,
        endOffset: 10,
      );
      const valueType = BaseTypeNode(
        name: 'i32',
        startOffset: 12,
        endOffset: 15,
      );
      const mapType = MapTypeNode(
        keyType: keyType,
        valueType: valueType,
        startOffset: 0,
        endOffset: 16,
      );
      expect(getTypeName(mapType), equals('map<string, i32>'));
    });

    test('SetTypeNode returns "unknown"', () {
      // SetTypeNode falls into the wildcard case
      const elementType = BaseTypeNode(
        name: 'i32',
        startOffset: 4,
        endOffset: 7,
      );
      const setType = SetTypeNode(
        elementType: elementType,
        startOffset: 0,
        endOffset: 8,
      );
      expect(getTypeName(setType), equals('unknown'));
    });

    test('VoidTypeNode returns "unknown"', () {
      const voidType = VoidTypeNode(startOffset: 0, endOffset: 4);
      expect(getTypeName(voidType), equals('unknown'));
    });

    test('nested list type', () {
      const inner = BaseTypeNode(name: 'i32', startOffset: 10, endOffset: 13);
      const innerList = ListTypeNode(
        elementType: inner,
        startOffset: 5,
        endOffset: 14,
      );
      const outerList = ListTypeNode(
        elementType: innerList,
        startOffset: 0,
        endOffset: 15,
      );
      expect(getTypeName(outerList), equals('list<list<i32>>'));
    });
  });

  group('isLiteralValueCompatibleWithBaseType()', () {
    group('valid combinations', () {
      test('i32 + IntLiteral', () {
        const lit = IntLiteralNode(value: 42, startOffset: 0, endOffset: 2);
        expect(isLiteralValueCompatibleWithBaseType('i32', lit), isTrue);
      });

      test('i8 + IntLiteral', () {
        const lit = IntLiteralNode(value: 1, startOffset: 0, endOffset: 1);
        expect(isLiteralValueCompatibleWithBaseType('i8', lit), isTrue);
      });

      test('i16 + IntLiteral', () {
        const lit = IntLiteralNode(value: 100, startOffset: 0, endOffset: 3);
        expect(isLiteralValueCompatibleWithBaseType('i16', lit), isTrue);
      });

      test('i64 + IntLiteral', () {
        const lit = IntLiteralNode(value: 99999, startOffset: 0, endOffset: 5);
        expect(isLiteralValueCompatibleWithBaseType('i64', lit), isTrue);
      });

      test('byte + IntLiteral', () {
        const lit = IntLiteralNode(value: 255, startOffset: 0, endOffset: 3);
        expect(isLiteralValueCompatibleWithBaseType('byte', lit), isTrue);
      });

      test('string + StringLiteral', () {
        const lit = StringLiteralNode(
          value: 'hello',
          startOffset: 0,
          endOffset: 7,
        );
        expect(isLiteralValueCompatibleWithBaseType('string', lit), isTrue);
      });

      test('bool + BoolLiteral', () {
        const lit = BoolLiteralNode(
          value: true,
          startOffset: 0,
          endOffset: 4,
        );
        expect(isLiteralValueCompatibleWithBaseType('bool', lit), isTrue);
      });

      test('double + DoubleLiteral', () {
        const lit = DoubleLiteralNode(
          value: 3.14,
          startOffset: 0,
          endOffset: 4,
        );
        expect(isLiteralValueCompatibleWithBaseType('double', lit), isTrue);
      });
    });

    group('invalid combinations', () {
      test('i32 + StringLiteral', () {
        const lit = StringLiteralNode(
          value: 'hello',
          startOffset: 0,
          endOffset: 7,
        );
        expect(isLiteralValueCompatibleWithBaseType('i32', lit), isFalse);
      });

      test('i32 + BoolLiteral', () {
        const lit = BoolLiteralNode(
          value: true,
          startOffset: 0,
          endOffset: 4,
        );
        expect(isLiteralValueCompatibleWithBaseType('i32', lit), isFalse);
      });

      test('string + IntLiteral', () {
        const lit = IntLiteralNode(value: 42, startOffset: 0, endOffset: 2);
        expect(isLiteralValueCompatibleWithBaseType('string', lit), isFalse);
      });

      test('bool + IntLiteral', () {
        const lit = IntLiteralNode(value: 1, startOffset: 0, endOffset: 1);
        expect(isLiteralValueCompatibleWithBaseType('bool', lit), isFalse);
      });

      test('double + IntLiteral', () {
        const lit = IntLiteralNode(value: 1, startOffset: 0, endOffset: 1);
        expect(isLiteralValueCompatibleWithBaseType('double', lit), isFalse);
      });

      test('bool + StringLiteral', () {
        const lit = StringLiteralNode(
          value: 'true',
          startOffset: 0,
          endOffset: 6,
        );
        expect(isLiteralValueCompatibleWithBaseType('bool', lit), isFalse);
      });

      test('string + DoubleLiteral', () {
        const lit = DoubleLiteralNode(
          value: 1,
          startOffset: 0,
          endOffset: 3,
        );
        expect(isLiteralValueCompatibleWithBaseType('string', lit), isFalse);
      });
    });

    group('types without explicit checks', () {
      test('binary + any literal returns true (no check defined)', () {
        const lit = IntLiteralNode(value: 0, startOffset: 0, endOffset: 1);
        expect(isLiteralValueCompatibleWithBaseType('binary', lit), isTrue);
      });

      test('uuid + any literal returns true (no check defined)', () {
        const lit = StringLiteralNode(
          value: 'abc',
          startOffset: 0,
          endOffset: 5,
        );
        expect(isLiteralValueCompatibleWithBaseType('uuid', lit), isTrue);
      });

      test('unknown type returns true (no check defined)', () {
        const lit = IntLiteralNode(value: 0, startOffset: 0, endOffset: 1);
        expect(
          isLiteralValueCompatibleWithBaseType('CustomType', lit),
          isTrue,
        );
      });
    });
  });
}

/// Helper to provide a default literal value string for each base type
/// so that the parser produces a valid const definition.
String _defaultValueFor(String typeName) => switch (typeName) {
  'bool' => 'true',
  'string' => '"hello"',
  'double' => '3.14',
  _ => '1',
};
