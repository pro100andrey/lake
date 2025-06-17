import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

import '../_ast_helpers.dart';
import 'visitors/recording_visitor.dart';

void main() {
  group('AST Visitor Smoke Tests', () {
    test('should visit all node types in a complex document', () {
      final ast = parseAstFromFile(
        'test/ast/integration/test_data/ast_visitor_smoke_test.lake',
      );

      final visitedTypes = <Type>[];
      final recordingVisitor = RecordingVisitor(visitedTypes);
      ast.accept(recordingVisitor);

      final expectedTypes = <Type>[
        DocumentNode,

        // Import `../visitors/data/my_lib`
        ImportNode,
        StringLiteralNode,

        // Namespace `my_app`
        NamespaceNode,
        IdentifierNode,
        IdentifierNode,

        // Enum `Status`
        EnumDefinitionNode,
        IdentifierNode,
        EnumValueNode,
        IdentifierNode,
        IntLiteralNode,
        EnumValueNode,
        IdentifierNode,

        //  Typedef `StringList`
        TypedefDefinitionNode,
        ListTypeNode,
        IdentifierNode,

        // Struct `Address`
        StructDefinitionNode,
        IdentifierNode,
        FieldNode,
        IntLiteralNode,
        BaseTypeNode,
        IdentifierNode,

        // Struct `User`
        StructDefinitionNode,
        IdentifierNode,
        // 1: required string name;
        FieldNode,
        IntLiteralNode,
        FieldRequirementNode,
        BaseTypeNode,
        IdentifierNode,
        // 2: optional int age = 30;
        FieldNode,
        IntLiteralNode,
        FieldRequirementNode,
        BaseTypeNode,
        IdentifierNode,
        IntLiteralNode,
        // 3: Address homeAddress;
        FieldNode,
        IntLiteralNode,
        CustomTypeNode,
        IdentifierNode,
        // 4: map<string, string> attributes;
        FieldNode,
        IntLiteralNode,
        MapTypeNode,
        IdentifierNode,
        //  5: list<i32> favoriteNumbers;
        FieldNode,
        IntLiteralNode,
        ListTypeNode,
        IdentifierNode,

        // Exception `UserNotFoundException`
        ExceptionDefinitionNode,
        IdentifierNode,
        // 1: string message;
        FieldNode,
        IntLiteralNode,
        BaseTypeNode,
        IdentifierNode,

        // Service `UserService`
        ServiceDefinitionNode,
        IdentifierNode,
        IdentifierNode,
        // getUserById
        MethodNode,
        CustomTypeNode,
        IdentifierNode,
        FieldNode,
        IntLiteralNode,
        BaseTypeNode,
        IdentifierNode,
        FieldNode,
        IntLiteralNode,
        CustomTypeNode,
        IdentifierNode,
        // createUser
        MethodNode,
        VoidTypeNode,
        IdentifierNode,
        FieldNode,
        IntLiteralNode,
        CustomTypeNode,
        IdentifierNode,
        // subscribeToUpdates
        MethodNode,
        StreamTypeNode,
        IdentifierNode,

        // Const `APP_NAME`
        ConstDefinitionNode,
        BaseTypeNode,
        IdentifierNode,
        StringLiteralNode,
      ];

      expect(visitedTypes, containsAllInOrder(expectedTypes));
      expect(visitedTypes, equals(expectedTypes));
    });
  });
}
