import 'package:lake_lang/src/ast/nodes/ast_nodes.dart' as old_ast;
import 'package:lake_lang/src/parser/ast/ast_base.dart' as new_ast;
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

import '../ast/_ast_helpers.dart';

Map<String, dynamic> oldAstToJson(old_ast.AstNode node) => switch (node) {
  final old_ast.DocumentNode n => {
    'type': 'Document',
    'headers': n.headers.map(oldAstToJson).toList(),
    'definitions': n.definitions.map(oldAstToJson).toList(),
  },
  final old_ast.ImportNode n => {
    'type': 'Import',
    'path': oldAstToJson(n.path),
  },
  final old_ast.NamespaceNode n => {
    'type': 'Namespace',
    'scope': oldAstToJson(n.scope),
    'identifier': oldAstToJson(n.identifier),
  },
  final old_ast.ConstDefinitionNode n => {
    'type': 'Const',
    'typeNode': oldAstToJson(n.type),
    'identifier': oldAstToJson(n.identifier),
    'value': oldAstToJson(n.value),
  },
  final old_ast.TypedefDefinitionNode n => {
    'type': 'Typedef',
    'typeNode': oldAstToJson(n.type),
    'identifier': oldAstToJson(n.identifier),
  },
  final old_ast.EnumDefinitionNode n => {
    'type': 'Enum',
    'identifier': oldAstToJson(n.identifier),
    'members': n.members.map(oldAstToJson).toList(),
  },
  final old_ast.EnumValueNode n => {
    'type': 'EnumValue',
    'identifier': oldAstToJson(n.identifier),
    'value': n.value != null ? oldAstToJson(n.value!) : null,
  },
  final old_ast.StructDefinitionNode n => {
    'type': 'Struct',
    'identifier': oldAstToJson(n.identifier),
    'fields': n.fields.map(oldAstToJson).toList(),
  },
  final old_ast.UnionDefinitionNode n => {
    'type': 'Union',
    'identifier': oldAstToJson(n.identifier),
    'fields': n.fields.map(oldAstToJson).toList(),
  },
  final old_ast.ExceptionDefinitionNode n => {
    'type': 'Exception',
    'identifier': oldAstToJson(n.identifier),
    'fields': n.fields.map(oldAstToJson).toList(),
  },
  final old_ast.ServiceDefinitionNode n => {
    'type': 'Service',
    'identifier': oldAstToJson(n.identifier),
    'extends': n.extendsService != null
        ? oldAstToJson(n.extendsService!)
        : null,
    'methods': n.methods.map(oldAstToJson).toList(),
  },
  final old_ast.FieldNode n => {
    'type': 'Field',
    'id': n.fieldId != null ? oldAstToJson(n.fieldId!) : null,
    'required': n.isRequired,
    'typeNode': oldAstToJson(n.type),
    'identifier': oldAstToJson(n.identifier),
    'default': n.defaultValue != null ? oldAstToJson(n.defaultValue!) : null,
  },
  final old_ast.MethodNode n => {
    'type': 'Method',
    'return': oldAstToJson(n.returnType),
    'identifier': oldAstToJson(n.identifier),
    'params': n.parameters.map(oldAstToJson).toList(),
    'throws': n.throws.map(oldAstToJson).toList(),
  },
  final old_ast.BaseTypeNode n => {'type': 'BaseType', 'name': n.value},
  final old_ast.MapTypeNode n => {
    'type': 'MapType',
    'key': oldAstToJson(n.keyType),
    'value': oldAstToJson(n.valueType),
  },
  final old_ast.SetTypeNode n => {
    'type': 'SetType',
    'element': oldAstToJson(n.elementType),
  },
  final old_ast.ListTypeNode n => {
    'type': 'ListType',
    'element': oldAstToJson(n.elementType),
  },
  final old_ast.StreamTypeNode n => {
    'type': 'StreamType',
    'element': oldAstToJson(n.elementType),
  },
  final old_ast.CustomTypeNode n => {'type': 'CustomType', 'name': n.value},
  final old_ast.VoidTypeNode _ => {'type': 'VoidType'},
  final old_ast.IntLiteralNode n => {'type': 'Int', 'value': n.value},
  final old_ast.DoubleLiteralNode n => {'type': 'Double', 'value': n.value},
  final old_ast.BoolLiteralNode n => {'type': 'Bool', 'value': n.value},
  final old_ast.StringLiteralNode n => {'type': 'String', 'value': n.value},
  final old_ast.ListLiteralNode n => {
    'type': 'List',
    'elements': n.elements.map(oldAstToJson).toList(),
  },
  final old_ast.MapLiteralNode n => {
    'type': 'Map',
    'entries': n.entries
        .map(
          (e) => {'key': oldAstToJson(e.key), 'value': oldAstToJson(e.value)},
        )
        .toList(),
  },
  final old_ast.IdentifierNode n => {'type': 'Identifier', 'name': n.value},
  _ => {'type': 'Unknown'},
};

Map<String, dynamic> newAstToJson(new_ast.AstNode node) => switch (node) {
  final new_ast.DocumentNode n => {
    'type': 'Document',
    'headers': n.headers.map(newAstToJson).toList(),
    'definitions': n.definitions.map(newAstToJson).toList(),
  },
  final new_ast.ImportNode n => {
    'type': 'Import',
    'path': newAstToJson(n.path),
  },
  final new_ast.NamespaceNode n => {
    'type': 'Namespace',
    'scope': newAstToJson(n.scope),
    'identifier': newAstToJson(n.identifier),
  },
  final new_ast.ConstDefinitionNode n => {
    'type': 'Const',
    'typeNode': newAstToJson(n.type),
    'identifier': newAstToJson(n.identifier),
    'value': newAstToJson(n.value),
  },
  final new_ast.TypedefDefinitionNode n => {
    'type': 'Typedef',
    'typeNode': newAstToJson(n.type),
    'identifier': newAstToJson(n.identifier),
  },
  final new_ast.EnumDefinitionNode n => {
    'type': 'Enum',
    'identifier': newAstToJson(n.identifier),
    'members': n.members.map(newAstToJson).toList(),
  },
  final new_ast.EnumValueNode n => {
    'type': 'EnumValue',
    'identifier': newAstToJson(n.identifier),
    'value': n.value != null ? newAstToJson(n.value!) : null,
  },
  final new_ast.StructDefinitionNode n => {
    'type': 'Struct',
    'identifier': newAstToJson(n.identifier),
    'fields': n.fields.map(newAstToJson).toList(),
  },
  final new_ast.UnionDefinitionNode n => {
    'type': 'Union',
    'identifier': newAstToJson(n.identifier),
    'fields': n.fields.map(newAstToJson).toList(),
  },
  final new_ast.ExceptionDefinitionNode n => {
    'type': 'Exception',
    'identifier': newAstToJson(n.identifier),
    'fields': n.fields.map(newAstToJson).toList(),
  },
  final new_ast.ServiceDefinitionNode n => {
    'type': 'Service',
    'identifier': newAstToJson(n.identifier),
    'extends': n.extendsService != null
        ? newAstToJson(n.extendsService!)
        : null,
    'methods': n.methods.map(newAstToJson).toList(),
  },
  final new_ast.FieldNode n => {
    'type': 'Field',
    'id': n.fieldId != null ? newAstToJson(n.fieldId!) : null,
    'required': n.isRequired,
    'typeNode': newAstToJson(n.type),
    'identifier': newAstToJson(n.identifier),
    'default': n.defaultValue != null ? newAstToJson(n.defaultValue!) : null,
  },
  final new_ast.MethodNode n => {
    'type': 'Method',
    'return': newAstToJson(n.returnType),
    'identifier': newAstToJson(n.identifier),
    'params': n.parameters.map(newAstToJson).toList(),
    'throws': n.throws.map(newAstToJson).toList(),
  },
  final new_ast.BaseTypeNode n => {'type': 'BaseType', 'name': n.name},
  final new_ast.MapTypeNode n => {
    'type': 'MapType',
    'key': newAstToJson(n.keyType),
    'value': newAstToJson(n.valueType),
  },
  final new_ast.SetTypeNode n => {
    'type': 'SetType',
    'element': newAstToJson(n.elementType),
  },
  final new_ast.ListTypeNode n => {
    'type': 'ListType',
    'element': newAstToJson(n.elementType),
  },
  final new_ast.StreamTypeNode n => {
    'type': 'StreamType',
    'element': newAstToJson(n.elementType),
  },
  final new_ast.CustomTypeNode n => {'type': 'CustomType', 'name': n.name},
  final new_ast.VoidTypeNode _ => {'type': 'VoidType'},
  final new_ast.IntLiteralNode n => {'type': 'Int', 'value': n.value},
  final new_ast.DoubleLiteralNode n => {'type': 'Double', 'value': n.value},
  final new_ast.BoolLiteralNode n => {'type': 'Bool', 'value': n.value},
  final new_ast.StringLiteralNode n => {'type': 'String', 'value': n.value},
  final new_ast.ListLiteralNode n => {
    'type': 'List',
    'elements': n.elements.map(newAstToJson).toList(),
  },
  final new_ast.MapLiteralNode n => {
    'type': 'Map',
    'entries': n.entries
        .map(
          (e) => {'key': newAstToJson(e.key), 'value': newAstToJson(e.value)},
        )
        .toList(),
  },
  final new_ast.IdentifierNode n => {'type': 'Identifier', 'name': n.name},
};

void main() {
  test('Differential Parsing Test', () {
    const input = '''
      import "package/file.lake";
      namespace js App.Auth;

      struct User {
        1: required string id;
        2: optional i32 age = 30;
      }

      enum Status { ACTIVE = 1, INACTIVE = 2, }

      service UserService extends BaseService {
        string getUser(1: i32 id) throws (1: ExceptionType e);
      }
    ''';

    final oldAst = parseAstFromString(input);
    final oldJson = oldAstToJson(oldAst);

    final parser = LakeParser(input);
    final newAst = parser.parseDocument();
    final newJson = newAstToJson(newAst);

    expect(newJson, equals(oldJson));
  });
}
