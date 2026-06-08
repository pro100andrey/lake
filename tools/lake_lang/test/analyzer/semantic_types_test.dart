import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/semantic_types.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

void main() {
  group('BaseType', () {
    group('identity – every type is assignable to itself', () {
      for (final t in BaseType.values) {
        test('${t.name} → ${t.name}', () {
          expect(t.isAssignableTo(t), isTrue);
        });
      }
    });

    group('integer widening (smaller → larger)', () {
      test('i8 → i16', () {
        expect(BaseType.i8T.isAssignableTo(BaseType.i16T), isTrue);
      });

      test('i8 → i32', () {
        expect(BaseType.i8T.isAssignableTo(BaseType.i32T), isTrue);
      });

      test('i8 → i64', () {
        expect(BaseType.i8T.isAssignableTo(BaseType.i64T), isTrue);
      });

      test('i16 → i32', () {
        expect(BaseType.i16T.isAssignableTo(BaseType.i32T), isTrue);
      });

      test('i16 → i64', () {
        expect(BaseType.i16T.isAssignableTo(BaseType.i64T), isTrue);
      });

      test('i32 → i64', () {
        expect(BaseType.i32T.isAssignableTo(BaseType.i64T), isTrue);
      });
    });

    group('integer narrowing NOT allowed (larger → smaller)', () {
      test('i16 → i8 fails', () {
        expect(BaseType.i16T.isAssignableTo(BaseType.i8T), isFalse);
      });

      test('i32 → i16 fails', () {
        expect(BaseType.i32T.isAssignableTo(BaseType.i16T), isFalse);
      });

      test('i32 → i8 fails', () {
        expect(BaseType.i32T.isAssignableTo(BaseType.i8T), isFalse);
      });

      test('i64 → i32 fails', () {
        expect(BaseType.i64T.isAssignableTo(BaseType.i32T), isFalse);
      });

      test('i64 → i16 fails', () {
        expect(BaseType.i64T.isAssignableTo(BaseType.i16T), isFalse);
      });

      test('i64 → i8 fails', () {
        expect(BaseType.i64T.isAssignableTo(BaseType.i8T), isFalse);
      });
    });

    group('special primitive assignability rules', () {
      test('bool → byte', () {
        expect(BaseType.boolT.isAssignableTo(BaseType.byteT), isTrue);
      });

      test('byte → bool fails', () {
        expect(BaseType.byteT.isAssignableTo(BaseType.boolT), isFalse);
      });

      test('byte → i8', () {
        expect(BaseType.byteT.isAssignableTo(BaseType.i8T), isTrue);
      });

      test('i8 → byte fails', () {
        expect(BaseType.i8T.isAssignableTo(BaseType.byteT), isFalse);
      });

      test('i64 → double', () {
        expect(BaseType.i64T.isAssignableTo(BaseType.doubleT), isTrue);
      });

      test('double → i64 fails', () {
        expect(BaseType.doubleT.isAssignableTo(BaseType.i64T), isFalse);
      });
    });

    group('cross-type failures', () {
      test('string NOT assignable to i32', () {
        expect(BaseType.stringT.isAssignableTo(BaseType.i32T), isFalse);
      });

      test('bool NOT assignable to i32', () {
        expect(BaseType.boolT.isAssignableTo(BaseType.i32T), isFalse);
      });

      test('i32 NOT assignable to string', () {
        expect(BaseType.i32T.isAssignableTo(BaseType.stringT), isFalse);
      });

      test('double NOT assignable to string', () {
        expect(BaseType.doubleT.isAssignableTo(BaseType.stringT), isFalse);
      });

      test('string NOT assignable to bool', () {
        expect(BaseType.stringT.isAssignableTo(BaseType.boolT), isFalse);
      });

      test('binary NOT assignable to string', () {
        expect(BaseType.binaryT.isAssignableTo(BaseType.stringT), isFalse);
      });

      test('uuid NOT assignable to string', () {
        expect(BaseType.uuidT.isAssignableTo(BaseType.stringT), isFalse);
      });

      test('i32 NOT assignable to double', () {
        expect(BaseType.i32T.isAssignableTo(BaseType.doubleT), isFalse);
      });
    });

    group('byName map lookup', () {
      final expectedNames = [
        'bool',
        'byte',
        'i8',
        'i16',
        'i32',
        'i64',
        'double',
        'string',
        'binary',
        'uuid',
      ];

      for (final name in expectedNames) {
        test('byName["$name"] returns BaseType with correct name', () {
          final type = BaseType.byName[name];
          expect(type, isNotNull);
          expect(type!.name, equals(name));
        });
      }

      test('byName returns null for unknown type', () {
        expect(BaseType.byName['int128'], isNull);
      });

      test('byName contains exactly 10 entries', () {
        expect(BaseType.byName.length, equals(10));
      });
    });
  });

  group('ListType', () {
    test('isAssignableTo – same element type', () {
      final a = ListType(BaseType.i32T);
      final b = ListType(BaseType.i32T);
      expect(a.isAssignableTo(b), isTrue);
    });

    test('isAssignableTo – covariant element (i8 → i32)', () {
      final listI8 = ListType(BaseType.i8T);
      final listI32 = ListType(BaseType.i32T);
      expect(listI8.isAssignableTo(listI32), isTrue);
    });

    test('isAssignableTo – contravariant element fails (i32 → i8)', () {
      final listI32 = ListType(BaseType.i32T);
      final listI8 = ListType(BaseType.i8T);
      expect(listI32.isAssignableTo(listI8), isFalse);
    });

    test('isAssignableTo – different element type fails', () {
      final listStr = ListType(BaseType.stringT);
      final listI32 = ListType(BaseType.i32T);
      expect(listStr.isAssignableTo(listI32), isFalse);
    });

    test('isAssignableTo – not assignable to MapType', () {
      final list = ListType(BaseType.i32T);
      final map = MapType(BaseType.stringT, BaseType.i32T);
      expect(list.isAssignableTo(map), isFalse);
    });

    test('isAssignableTo – identical instance returns true', () {
      final list = ListType(BaseType.i32T);
      expect(list.isAssignableTo(list), isTrue);
    });

    test('name getter', () {
      final list = ListType(BaseType.i32T);
      expect(list.name, equals('List<i32>'));
    });

    test('nested ListType name', () {
      final nested = ListType(ListType(BaseType.stringT));
      expect(nested.name, equals('List<List<string>>'));
    });
  });

  group('MapType', () {
    test('isAssignableTo – same key and value types', () {
      final a = MapType(BaseType.stringT, BaseType.i32T);
      final b = MapType(BaseType.stringT, BaseType.i32T);
      expect(a.isAssignableTo(b), isTrue);
    });

    test('isAssignableTo – covariant value type', () {
      final mapI8 = MapType(BaseType.stringT, BaseType.i8T);
      final mapI32 = MapType(BaseType.stringT, BaseType.i32T);
      expect(mapI8.isAssignableTo(mapI32), isTrue);
    });

    test('isAssignableTo – covariant key type', () {
      final mapI8 = MapType(BaseType.i8T, BaseType.stringT);
      final mapI32 = MapType(BaseType.i32T, BaseType.stringT);
      expect(mapI8.isAssignableTo(mapI32), isTrue);
    });

    test('isAssignableTo – mismatched key type fails', () {
      final a = MapType(BaseType.stringT, BaseType.i32T);
      final b = MapType(BaseType.i32T, BaseType.i32T);
      expect(a.isAssignableTo(b), isFalse);
    });

    test('isAssignableTo – mismatched value type fails', () {
      final a = MapType(BaseType.stringT, BaseType.i32T);
      final b = MapType(BaseType.stringT, BaseType.stringT);
      expect(a.isAssignableTo(b), isFalse);
    });

    test('isAssignableTo – not assignable to ListType', () {
      final map = MapType(BaseType.stringT, BaseType.i32T);
      final list = ListType(BaseType.i32T);
      expect(map.isAssignableTo(list), isFalse);
    });

    test('name getter', () {
      final map = MapType(BaseType.stringT, BaseType.i32T);
      expect(map.name, equals('Map<string, i32>'));
    });
  });

  group('SetType', () {
    test('isAssignableTo – same element type', () {
      final a = SetType(BaseType.i32T);
      final b = SetType(BaseType.i32T);
      expect(a.isAssignableTo(b), isTrue);
    });

    test('isAssignableTo – covariant element (i16 → i64)', () {
      final setI16 = SetType(BaseType.i16T);
      final setI64 = SetType(BaseType.i64T);
      expect(setI16.isAssignableTo(setI64), isTrue);
    });

    test('isAssignableTo – contravariant fails (i64 → i16)', () {
      final setI64 = SetType(BaseType.i64T);
      final setI16 = SetType(BaseType.i16T);
      expect(setI64.isAssignableTo(setI16), isFalse);
    });

    test('isAssignableTo – not assignable to ListType', () {
      final set = SetType(BaseType.i32T);
      final list = ListType(BaseType.i32T);
      expect(set.isAssignableTo(list), isFalse);
    });

    test('name getter', () {
      final s = SetType(BaseType.boolT);
      expect(s.name, equals('Set<bool>'));
    });
  });

  group('VoidType', () {
    test('void is assignable to void', () {
      const v1 = VoidType();
      const v2 = VoidType();
      expect(v1.isAssignableTo(v2), isTrue);
    });

    test('void NOT assignable to BaseType', () {
      const v = VoidType();
      expect(v.isAssignableTo(BaseType.i32T), isFalse);
    });

    test('void NOT assignable to ListType', () {
      const v = VoidType();
      expect(v.isAssignableTo(ListType(BaseType.i32T)), isFalse);
    });

    test('name is "void"', () {
      const v = VoidType();
      expect(v.name, equals('void'));
    });
  });

  group('StructType', () {
    StructDefinitionNode parseStruct(String source) {
      final reporter = ErrorReporter();
      final parser = LakeParser(source, reporter);
      final doc = parser.parseDocument();
      return doc.definitions.first as StructDefinitionNode;
    }

    test('is assignable to itself', () {
      final node = parseStruct('struct Foo { i32 x; }');
      final type = StructType(node);
      expect(type.isAssignableTo(type), isTrue);
    });

    test('same-name struct is assignable', () {
      final node1 = parseStruct('struct Foo { i32 x; }');
      final node2 = parseStruct('struct Foo { i32 y; }');
      final type1 = StructType(node1);
      final type2 = StructType(node2);
      expect(type1.isAssignableTo(type2), isTrue);
    });

    test('different-name struct NOT assignable', () {
      final node1 = parseStruct('struct Foo { i32 x; }');
      final node2 = parseStruct('struct Bar { i32 x; }');
      final type1 = StructType(node1);
      final type2 = StructType(node2);
      expect(type1.isAssignableTo(type2), isFalse);
    });

    test('struct NOT assignable to BaseType', () {
      final node = parseStruct('struct Foo { i32 x; }');
      final type = StructType(node);
      expect(type.isAssignableTo(BaseType.i32T), isFalse);
    });

    test('name getter returns struct identifier', () {
      final node = parseStruct('struct MyStruct { i32 x; }');
      final type = StructType(node);
      expect(type.name, equals('MyStruct'));
    });
  });

  group('EnumType', () {
    EnumDefinitionNode parseEnum(String source) {
      final reporter = ErrorReporter();
      final parser = LakeParser(source, reporter);
      final doc = parser.parseDocument();
      return doc.definitions.first as EnumDefinitionNode;
    }

    test('is assignable to itself', () {
      final node = parseEnum('enum Color { RED, GREEN, BLUE }');
      final type = EnumType(node);
      expect(type.isAssignableTo(type), isTrue);
    });

    test('same-name enum is assignable', () {
      final node1 = parseEnum('enum Color { RED, GREEN, BLUE }');
      final node2 = parseEnum('enum Color { CYAN, MAGENTA }');
      final type1 = EnumType(node1);
      final type2 = EnumType(node2);
      expect(type1.isAssignableTo(type2), isTrue);
    });

    test('different-name enum NOT assignable', () {
      final node1 = parseEnum('enum Color { RED }');
      final node2 = parseEnum('enum Shape { CIRCLE }');
      final type1 = EnumType(node1);
      final type2 = EnumType(node2);
      expect(type1.isAssignableTo(type2), isFalse);
    });

    test('enum NOT assignable to BaseType', () {
      final node = parseEnum('enum Color { RED }');
      final type = EnumType(node);
      expect(type.isAssignableTo(BaseType.i32T), isFalse);
    });
  });

  group('TypedefType', () {
    test('delegates isAssignableTo to target type', () {
      final reporter = ErrorReporter();
      final parser = LakeParser('typedef i32 UserId;', reporter);
      final doc = parser.parseDocument();
      final typedefNode = doc.definitions.first as TypedefDefinitionNode;

      final typedefType = TypedefType(typedefNode)
        ..targetType = BaseType.i32T;

      // i32 is assignable to i32
      expect(typedefType.isAssignableTo(BaseType.i32T), isTrue);
      // i32 is assignable to i64 (widening)
      expect(typedefType.isAssignableTo(BaseType.i64T), isTrue);
      // i32 is NOT assignable to string
      expect(typedefType.isAssignableTo(BaseType.stringT), isFalse);
    });

    test('name getter returns typedef identifier', () {
      final reporter = ErrorReporter();
      final parser = LakeParser('typedef i32 UserId;', reporter);
      final doc = parser.parseDocument();
      final typedefNode = doc.definitions.first as TypedefDefinitionNode;
      final typedefType = TypedefType(typedefNode);
      expect(typedefType.name, equals('UserId'));
    });
  });

  group('equality and hashCode', () {
    test('BaseType equality by name', () {
      const a = BaseType.i32T;
      const b = BaseType.i32T;
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('BaseType inequality', () {
      expect(BaseType.i32T, isNot(equals(BaseType.i64T)));
    });

    test('ListType equality', () {
      final a = ListType(BaseType.i32T);
      final b = ListType(BaseType.i32T);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('ListType inequality – different element type', () {
      final a = ListType(BaseType.i32T);
      final b = ListType(BaseType.stringT);
      expect(a, isNot(equals(b)));
    });

    test('MapType equality', () {
      final a = MapType(BaseType.stringT, BaseType.i32T);
      final b = MapType(BaseType.stringT, BaseType.i32T);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('MapType inequality – different value type', () {
      final a = MapType(BaseType.stringT, BaseType.i32T);
      final b = MapType(BaseType.stringT, BaseType.i64T);
      expect(a, isNot(equals(b)));
    });

    test('SetType equality', () {
      final a = SetType(BaseType.boolT);
      final b = SetType(BaseType.boolT);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('VoidType equality', () {
      const a = VoidType();
      const b = VoidType();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SemanticType.name getter', () {
    test('BaseType names', () {
      expect(BaseType.i32T.name, equals('i32'));
      expect(BaseType.stringT.name, equals('string'));
      expect(BaseType.boolT.name, equals('bool'));
      expect(BaseType.doubleT.name, equals('double'));
      expect(BaseType.byteT.name, equals('byte'));
      expect(BaseType.binaryT.name, equals('binary'));
      expect(BaseType.uuidT.name, equals('uuid'));
    });

    test('ListType name', () {
      expect(ListType(BaseType.i32T).name, equals('List<i32>'));
    });

    test('MapType name', () {
      expect(
        MapType(BaseType.stringT, BaseType.i32T).name,
        equals('Map<string, i32>'),
      );
    });

    test('SetType name', () {
      expect(SetType(BaseType.boolT).name, equals('Set<bool>'));
    });

    test('StreamType name', () {
      expect(StreamType(BaseType.i32T).name, equals('Stream<i32>'));
    });

    test('VoidType name', () {
      expect(const VoidType().name, equals('void'));
    });
  });

  group('cross-kind failures', () {
    test('BaseType NOT assignable to ListType', () {
      expect(BaseType.i32T.isAssignableTo(ListType(BaseType.i32T)), isFalse);
    });

    test('BaseType NOT assignable to MapType', () {
      expect(
        BaseType.i32T.isAssignableTo(MapType(BaseType.i32T, BaseType.i32T)),
        isFalse,
      );
    });

    test('BaseType NOT assignable to SetType', () {
      expect(BaseType.i32T.isAssignableTo(SetType(BaseType.i32T)), isFalse);
    });

    test('ListType NOT assignable to MapType', () {
      final list = ListType(BaseType.i32T);
      final map = MapType(BaseType.stringT, BaseType.i32T);
      expect(list.isAssignableTo(map), isFalse);
    });

    test('ListType NOT assignable to BaseType', () {
      final list = ListType(BaseType.i32T);
      expect(list.isAssignableTo(BaseType.i32T), isFalse);
    });

    test('MapType NOT assignable to SetType', () {
      final map = MapType(BaseType.stringT, BaseType.i32T);
      final set = SetType(BaseType.i32T);
      expect(map.isAssignableTo(set), isFalse);
    });

    test('SetType NOT assignable to BaseType', () {
      final set = SetType(BaseType.i32T);
      expect(set.isAssignableTo(BaseType.i32T), isFalse);
    });

    test('VoidType NOT assignable to BaseType', () {
      const v = VoidType();
      expect(v.isAssignableTo(BaseType.i32T), isFalse);
    });

    test('BaseType NOT assignable to VoidType', () {
      const v = VoidType();
      expect(BaseType.i32T.isAssignableTo(v), isFalse);
    });
  });

  group('StreamType', () {
    test('isAssignableTo – same element type', () {
      final a = StreamType(BaseType.i32T);
      final b = StreamType(BaseType.i32T);
      expect(a.isAssignableTo(b), isTrue);
    });

    test('isAssignableTo – covariant element (i8 → i32)', () {
      final streamI8 = StreamType(BaseType.i8T);
      final streamI32 = StreamType(BaseType.i32T);
      expect(streamI8.isAssignableTo(streamI32), isTrue);
    });

    test('isAssignableTo – not assignable to ListType', () {
      final stream = StreamType(BaseType.i32T);
      final list = ListType(BaseType.i32T);
      expect(stream.isAssignableTo(list), isFalse);
    });

    test('equality', () {
      final a = StreamType(BaseType.i32T);
      final b = StreamType(BaseType.i32T);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SemanticTypesCastExtension', () {
    test('cast to correct type succeeds', () {
      const SemanticType type = BaseType.i32T;
      expect(type.cast<BaseType>(), equals(BaseType.i32T));
    });

    test('cast to wrong type throws', () {
      const SemanticType type = BaseType.i32T;
      expect(() => type.cast<ListType>(), throwsA(isA<TypeError>()));
    });
  });
}
