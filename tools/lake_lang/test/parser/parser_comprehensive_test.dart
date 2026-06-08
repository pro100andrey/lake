import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

void main() {
  group('LakeParser comprehensive', () {
    group('Empty document', () {
      test('parses empty string to empty document', () {
        final doc = LakeParser('').parseDocument();
        expect(doc.headers, isEmpty);
        expect(doc.definitions, isEmpty);
      });

      test('parses whitespace-only to empty document', () {
        final doc = LakeParser('   \n\t  ').parseDocument();
        expect(doc.headers, isEmpty);
        expect(doc.definitions, isEmpty);
      });

      test('parses comment-only to empty document', () {
        final doc = LakeParser('// just comments\n/* block */').parseDocument();
        expect(doc.headers, isEmpty);
        expect(doc.definitions, isEmpty);
      });
    });

    group('set<T> type parsing', () {
      test('parses set<i32> field type', () {
        const src = '''
struct Foo {
  1: required set<i32> ids;
}
''';
        final doc = LakeParser(src).parseDocument();
        expect(doc.definitions, hasLength(1));
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.fields, hasLength(1));
        final fieldType = s.fields.first.type;
        expect(fieldType, isA<SetTypeNode>());
        final setType = fieldType as SetTypeNode;
        expect(setType.elementType, isA<BaseTypeNode>());
        expect((setType.elementType as BaseTypeNode).name, 'i32');
      });

      test('parses set<string> field type', () {
        const src = '''
struct Bar {
  1: optional set<string> tags;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        final fieldType = s.fields.first.type;
        expect(fieldType, isA<SetTypeNode>());
        expect(
          ((fieldType as SetTypeNode).elementType as BaseTypeNode).name,
          'string',
        );
      });
    });

    group('stream<T> type parsing', () {
      test('parses stream<i32> as return type in service method', () {
        const src = '''
service Svc {
  stream<i32> getNumbers();
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        expect(svc.methods, hasLength(1));
        final method = svc.methods.first;
        expect(method.returnType, isA<StreamTypeNode>());
        final streamType = method.returnType as StreamTypeNode;
        expect(streamType.elementType, isA<BaseTypeNode>());
        expect((streamType.elementType as BaseTypeNode).name, 'i32');
      });
    });

    group('Namespace with * scope', () {
      test('parses namespace * com.example', () {
        const src = 'namespace * com.example';
        final doc = LakeParser(src).parseDocument();
        expect(doc.headers, hasLength(1));
        final ns = doc.headers.first as NamespaceNode;
        expect(ns.scope.name, '*');
        expect(ns.identifier.name, 'com.example');
      });

      test('parses namespace with named scope', () {
        const src = 'namespace dart com.example.pkg';
        final doc = LakeParser(src).parseDocument();
        final ns = doc.headers.first as NamespaceNode;
        expect(ns.scope.name, 'dart');
        expect(ns.identifier.name, 'com.example.pkg');
      });
    });

    group('Typedef with container types', () {
      test('typedef list<i32> IntList', () {
        const src = 'typedef list<i32> IntList';
        final doc = LakeParser(src).parseDocument();
        expect(doc.definitions, hasLength(1));
        final td = doc.definitions.first as TypedefDefinitionNode;
        expect(td.identifier.name, 'IntList');
        expect(td.type, isA<ListTypeNode>());
        final listType = td.type as ListTypeNode;
        expect(listType.elementType, isA<BaseTypeNode>());
        expect((listType.elementType as BaseTypeNode).name, 'i32');
      });

      test('typedef map<string, i64> StringToLong', () {
        const src = 'typedef map<string, i64> StringToLong';
        final doc = LakeParser(src).parseDocument();
        final td = doc.definitions.first as TypedefDefinitionNode;
        expect(td.identifier.name, 'StringToLong');
        expect(td.type, isA<MapTypeNode>());
      });

      test('typedef set<string> StringSet', () {
        const src = 'typedef set<string> StringSet';
        final doc = LakeParser(src).parseDocument();
        final td = doc.definitions.first as TypedefDefinitionNode;
        expect(td.identifier.name, 'StringSet');
        expect(td.type, isA<SetTypeNode>());
      });

      test('typedef with base type: typedef i32 MyInt', () {
        const src = 'typedef i32 MyInt';
        final doc = LakeParser(src).parseDocument();
        final td = doc.definitions.first as TypedefDefinitionNode;
        expect(td.identifier.name, 'MyInt');
        expect(td.type, isA<BaseTypeNode>());
        expect((td.type as BaseTypeNode).name, 'i32');
      });
    });

    group('Typedef error path: custom type', () {
      test('typedef with custom type reports error', () {
        const src = 'typedef MyCustomType Alias';
        final reporter = ErrorReporter();
        LakeParser(src, reporter).parseDocument();
        // The parser should report an error for custom type in typedef
        expect(reporter.hasErrors, isTrue);
        // The definition is skipped due to error recovery
      });

      test('typedef with stream type reports error', () {
        const src = 'typedef stream<i32> StreamAlias';
        final reporter = ErrorReporter();
        LakeParser(src, reporter).parseDocument();
        expect(reporter.hasErrors, isTrue);
      });
    });

    group('Bool literal parsing', () {
      test('const bool val = true', () {
        const src = 'const bool val = true';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect(c.identifier.name, 'val');
        expect(c.value, isA<BoolLiteralNode>());
        expect((c.value as BoolLiteralNode).value, isTrue);
      });

      test('const bool val = false', () {
        const src = 'const bool val = false';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect((c.value as BoolLiteralNode).value, isFalse);
      });
    });

    group('Field with required modifier', () {
      test('required field is parsed correctly', () {
        const src = '''
struct S {
  1: required i32 count;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.fields, hasLength(1));
        expect(s.fields.first.isRequired, isTrue);
        expect(s.fields.first.fieldId, isNotNull);
        expect(s.fields.first.fieldId!.value, 1);
        expect(s.fields.first.identifier.name, 'count');
        expect(s.fields.first.type, isA<BaseTypeNode>());
        expect((s.fields.first.type as BaseTypeNode).name, 'i32');
      });
    });

    group('Field with optional modifier and default value', () {
      test('optional field with default int value', () {
        const src = '''
struct S {
  1: optional i32 count = 42;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        final f = s.fields.first;
        expect(f.isRequired, isFalse);
        expect(f.defaultValue, isA<IntLiteralNode>());
        expect((f.defaultValue! as IntLiteralNode).value, 42);
      });

      test('optional field with default string value', () {
        const src = '''
struct S {
  1: optional string name = "default";
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        final f = s.fields.first;
        expect(f.isRequired, isFalse);
        expect(f.defaultValue, isA<StringLiteralNode>());
        expect((f.defaultValue! as StringLiteralNode).value, 'default');
      });

      test('optional field with default bool value', () {
        const src = '''
struct S {
  1: optional bool active = true;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        final f = s.fields.first;
        expect(f.defaultValue, isA<BoolLiteralNode>());
        expect((f.defaultValue! as BoolLiteralNode).value, isTrue);
      });
    });

    group('Field without field ID number', () {
      test('field without explicit ID', () {
        const src = '''
struct S {
  required i32 x;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.fields, hasLength(1));
        final f = s.fields.first;
        expect(f.fieldId, isNull);
        expect(f.isRequired, isTrue);
        expect(f.identifier.name, 'x');
      });

      test('multiple fields without IDs', () {
        const src = '''
struct S {
  required string name;
  optional i64 age;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.fields, hasLength(2));
        expect(s.fields[0].fieldId, isNull);
        expect(s.fields[0].identifier.name, 'name');
        expect(s.fields[1].fieldId, isNull);
        expect(s.fields[1].identifier.name, 'age');
      });
    });

    group('Service method with throws clause', () {
      test('method with throws parsing single exception field', () {
        const src = '''
service Svc {
  string getData(1: required i32 id) throws (1: MyError err);
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        expect(svc.methods, hasLength(1));
        final method = svc.methods.first;
        expect(method.identifier.name, 'getData');
        expect(method.throws, hasLength(1));
        final throwField = method.throws.first;
        expect(throwField.fieldId!.value, 1);
        expect(throwField.type, isA<CustomTypeNode>());
        expect((throwField.type as CustomTypeNode).name, 'MyError');
        expect(throwField.identifier.name, 'err');
      });

      test('method with no throws clause', () {
        const src = '''
service Svc {
  void doStuff();
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        expect(svc.methods.first.throws, isEmpty);
      });
    });

    group('Service with extends clause', () {
      test('parses service extends BaseService', () {
        const src = '''
service ChildService extends BaseService {
  void doMore();
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        expect(svc.identifier.name, 'ChildService');
        expect(svc.extendsService, isNotNull);
        expect(svc.extendsService!.name, 'BaseService');
        expect(svc.methods, hasLength(1));
      });

      test('parses service without extends', () {
        const src = '''
service BasicService {
  void ping();
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        expect(svc.extendsService, isNull);
      });
    });

    group('Enum value with explicit integer assignment', () {
      test('enum with explicit values', () {
        const src = '''
enum Status {
  UNKNOWN = 0,
  ACTIVE = 1,
  INACTIVE = 2,
}
''';
        final doc = LakeParser(src).parseDocument();
        final e = doc.definitions.first as EnumDefinitionNode;
        expect(e.identifier.name, 'Status');
        expect(e.members, hasLength(3));
        expect(e.members[0].identifier.name, 'UNKNOWN');
        expect(e.members[0].value, isNotNull);
        expect(e.members[0].value!.value, 0);
        expect(e.members[1].identifier.name, 'ACTIVE');
        expect(e.members[1].value!.value, 1);
        expect(e.members[2].identifier.name, 'INACTIVE');
        expect(e.members[2].value!.value, 2);
      });

      test('enum values without explicit assignment', () {
        const src = '''
enum Color {
  RED,
  GREEN,
  BLUE,
}
''';
        final doc = LakeParser(src).parseDocument();
        final e = doc.definitions.first as EnumDefinitionNode;
        expect(e.members, hasLength(3));
        for (final m in e.members) {
          expect(m.value, isNull);
        }
      });

      test('enum with mix of explicit and implicit values', () {
        const src = '''
enum Priority {
  LOW,
  MEDIUM = 5,
  HIGH,
}
''';
        final doc = LakeParser(src).parseDocument();
        final e = doc.definitions.first as EnumDefinitionNode;
        expect(e.members[0].value, isNull);
        expect(e.members[1].value!.value, 5);
        expect(e.members[2].value, isNull);
      });
    });

    group('Doc comments propagation', () {
      test('doc comment on struct', () {
        const src = '''
/// My struct doc
struct S {
  1: required i32 x;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.docComment, 'My struct doc');
      });

      test('doc comment on enum', () {
        const src = '''
/// Status enum
enum Status {
  A,
}
''';
        final doc = LakeParser(src).parseDocument();
        final e = doc.definitions.first as EnumDefinitionNode;
        expect(e.docComment, 'Status enum');
      });

      test('doc comment on const', () {
        const src = '''
/// Max value
const i32 MAX = 100;
''';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect(c.docComment, 'Max value');
      });

      test('doc comment on service', () {
        const src = '''
/// My service
service MySvc {
  void ping();
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        expect(svc.docComment, 'My service');
      });

      test('doc comment on enum value', () {
        const src = '''
enum Status {
  /// The unknown state
  UNKNOWN = 0,
  /// The active state
  ACTIVE = 1,
}
''';
        final doc = LakeParser(src).parseDocument();
        final e = doc.definitions.first as EnumDefinitionNode;
        expect(e.members[0].docComment, 'The unknown state');
        expect(e.members[1].docComment, 'The active state');
      });

      test('multi-line doc comment', () {
        const src = '''
/// Line one
/// Line two
struct S {
  1: required i32 x;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.docComment, 'Line one\nLine two');
      });

      test('no doc comment results in null', () {
        const src = '''
struct S {
  1: required i32 x;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.docComment, isNull);
      });

      test('doc comment on field', () {
        const src = '''
struct S {
  /// X coordinate
  1: required i32 x;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.fields.first.docComment, 'X coordinate');
      });
    });

    group('Map literal parsing', () {
      test('const map with string keys and int values', () {
        const src = 'const map<string, i32> m = {"a": 1, "b": 2}';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect(c.value, isA<MapLiteralNode>());
        final mapLit = c.value as MapLiteralNode;
        expect(mapLit.entries, hasLength(2));
        expect((mapLit.entries[0].key as StringLiteralNode).value, 'a');
        expect((mapLit.entries[0].value as IntLiteralNode).value, 1);
        expect((mapLit.entries[1].key as StringLiteralNode).value, 'b');
        expect((mapLit.entries[1].value as IntLiteralNode).value, 2);
      });

      test('empty map literal', () {
        const src = 'const map<string, i32> m = {}';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        final mapLit = c.value as MapLiteralNode;
        expect(mapLit.entries, isEmpty);
      });
    });

    group('List literal parsing', () {
      test('const list with integers', () {
        const src = 'const list<i32> nums = [1, 2, 3]';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect(c.value, isA<ListLiteralNode>());
        final listLit = c.value as ListLiteralNode;
        expect(listLit.elements, hasLength(3));
        expect((listLit.elements[0] as IntLiteralNode).value, 1);
        expect((listLit.elements[1] as IntLiteralNode).value, 2);
        expect((listLit.elements[2] as IntLiteralNode).value, 3);
      });

      test('empty list literal', () {
        const src = 'const list<i32> nums = []';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        final listLit = c.value as ListLiteralNode;
        expect(listLit.elements, isEmpty);
      });

      test('list with string elements', () {
        const src = 'const list<string> items = ["x", "y"]';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        final listLit = c.value as ListLiteralNode;
        expect(listLit.elements, hasLength(2));
        expect((listLit.elements[0] as StringLiteralNode).value, 'x');
        expect((listLit.elements[1] as StringLiteralNode).value, 'y');
      });
    });

    group('Multiple imports', () {
      test('parses two imports', () {
        const src = '''
import "shared.lake"
import "common.lake"
''';
        final doc = LakeParser(src).parseDocument();
        expect(doc.headers, hasLength(2));
        expect(doc.headers[0], isA<ImportNode>());
        expect((doc.headers[0] as ImportNode).path.value, 'shared.lake');
        expect(doc.headers[1], isA<ImportNode>());
        expect((doc.headers[1] as ImportNode).path.value, 'common.lake');
      });

      test('parses imports mixed with namespace', () {
        const src = '''
import "base.lake"
namespace * com.example
import "extra.lake"
''';
        final doc = LakeParser(src).parseDocument();
        expect(doc.headers, hasLength(3));
        expect(doc.headers[0], isA<ImportNode>());
        expect(doc.headers[1], isA<NamespaceNode>());
        expect(doc.headers[2], isA<ImportNode>());
      });

      test('parses imports with semicolons', () {
        const src = '''
import "a.lake";
import "b.lake";
''';
        final doc = LakeParser(src).parseDocument();
        expect(doc.headers, hasLength(2));
      });
    });

    group('Parser with custom ErrorReporter', () {
      test('custom reporter collects errors', () {
        const src = 'typedef MyType Alias';
        final reporter = ErrorReporter();
        LakeParser(src, reporter).parseDocument();
        expect(reporter.hasErrors, isTrue);
        expect(reporter.diagnostics, isNotEmpty);
      });

      test('valid input produces no errors', () {
        const src = 'struct S { 1: required i32 x; }';
        final reporter = ErrorReporter();
        LakeParser(src, reporter).parseDocument();
        expect(reporter.hasErrors, isFalse);
        expect(reporter.diagnostics, isEmpty);
      });

      test('parser without explicit reporter still works', () {
        const src = 'struct S { 1: required i32 x; }';
        final doc = LakeParser(src).parseDocument();
        expect(doc.definitions, hasLength(1));
      });
    });

    group('Void return type on service methods', () {
      test('void return type', () {
        const src = '''
service Svc {
  void ping();
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        final method = svc.methods.first;
        expect(method.returnType, isA<VoidTypeNode>());
        expect(method.identifier.name, 'ping');
      });

      test('non-void return type', () {
        const src = '''
service Svc {
  string greet(1: required string name);
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        final method = svc.methods.first;
        expect(method.returnType, isA<BaseTypeNode>());
        expect((method.returnType as BaseTypeNode).name, 'string');
      });

      test('void method with parameters and throws', () {
        const src = '''
service Svc {
  void doWork(1: required i32 id) throws (1: MyError err);
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        final method = svc.methods.first;
        expect(method.returnType, isA<VoidTypeNode>());
        expect(method.parameters, hasLength(1));
        expect(method.throws, hasLength(1));
      });
    });

    group('Additional parser scenarios', () {
      test('union definition', () {
        const src = '''
union Value {
  1: required i32 intVal;
  2: required string strVal;
}
''';
        final doc = LakeParser(src).parseDocument();
        final u = doc.definitions.first as UnionDefinitionNode;
        expect(u.identifier.name, 'Value');
        expect(u.fields, hasLength(2));
      });

      test('exception definition', () {
        const src = '''
exception AppError {
  1: required i32 code;
  2: required string message;
}
''';
        final doc = LakeParser(src).parseDocument();
        final e = doc.definitions.first as ExceptionDefinitionNode;
        expect(e.identifier.name, 'AppError');
        expect(e.fields, hasLength(2));
      });

      test('const with double value', () {
        const src = 'const double PI = 3.14';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect(c.value, isA<DoubleLiteralNode>());
        expect((c.value as DoubleLiteralNode).value, 3.14);
      });

      test('const with string value', () {
        const src = 'const string greeting = "hello"';
        final doc = LakeParser(src).parseDocument();
        final c = doc.definitions.first as ConstDefinitionNode;
        expect(c.value, isA<StringLiteralNode>());
        expect((c.value as StringLiteralNode).value, 'hello');
      });

      test('nested container types: list of map', () {
        const src = '''
struct S {
  1: required list<map<string, i32>> data;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        final fieldType = s.fields.first.type;
        expect(fieldType, isA<ListTypeNode>());
        final inner = (fieldType as ListTypeNode).elementType;
        expect(inner, isA<MapTypeNode>());
      });

      test('field with custom type', () {
        const src = '''
struct S {
  1: required MyType field;
}
''';
        final doc = LakeParser(src).parseDocument();
        final s = doc.definitions.first as StructDefinitionNode;
        expect(s.fields.first.type, isA<CustomTypeNode>());
        expect((s.fields.first.type as CustomTypeNode).name, 'MyType');
      });

      test('full document with headers and definitions', () {
        const src = '''
import "shared.lake"
namespace * com.example

/// User struct
struct User {
  1: required i64 id;
  2: required string name;
  3: optional i32 age;
}

enum Role {
  ADMIN = 0,
  USER = 1,
}

service UserService {
  User getUser(1: required i64 id) throws (1: NotFoundError err);
  void deleteUser(1: required i64 id);
}
''';
        final reporter = ErrorReporter();
        final doc = LakeParser(src, reporter).parseDocument();
        expect(reporter.hasErrors, isFalse);
        expect(doc.headers, hasLength(2));
        expect(doc.definitions, hasLength(3));

        final userStruct = doc.definitions[0] as StructDefinitionNode;
        expect(userStruct.identifier.name, 'User');
        expect(userStruct.docComment, 'User struct');
        expect(userStruct.fields, hasLength(3));

        final roleEnum = doc.definitions[1] as EnumDefinitionNode;
        expect(roleEnum.identifier.name, 'Role');
        expect(roleEnum.members, hasLength(2));

        final svc = doc.definitions[2] as ServiceDefinitionNode;
        expect(svc.identifier.name, 'UserService');
        expect(svc.methods, hasLength(2));
      });

      test('service method with multiple parameters', () {
        const src = '''
service Svc {
  bool update(1: required i64 id, 2: required string name, 3: optional i32 age);
}
''';
        final doc = LakeParser(src).parseDocument();
        final svc = doc.definitions.first as ServiceDefinitionNode;
        final method = svc.methods.first;
        expect(method.parameters, hasLength(3));
        expect(method.parameters[0].identifier.name, 'id');
        expect(method.parameters[1].identifier.name, 'name');
        expect(method.parameters[2].identifier.name, 'age');
      });
    });
  });
}
