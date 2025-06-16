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
        LiteralNode,

        // Namespace `my_app`
        NamespaceNode,
        IdentifierNode,
        IdentifierNode,

        // Enum `Status`
        EnumDefinitionNode,
        IdentifierNode,
        EnumValueNode,
        IdentifierNode,
        IntConstantNode,
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
        IntConstantNode,
        BaseTypeNode,
        IdentifierNode,

        // Struct `User`
        StructDefinitionNode,
        IdentifierNode,
        // 1: required string name;
        FieldNode,
        IntConstantNode,
        FieldRequirementNode,
        BaseTypeNode,
        IdentifierNode,
        // 2: optional int age = 30;
        FieldNode,
        IntConstantNode,
        FieldRequirementNode,
        BaseTypeNode,
        IdentifierNode,
        IntConstantNode,
        // 3: Address homeAddress;
        FieldNode,
        IntConstantNode,
        CustomTypeNode,
        IdentifierNode,
        // 4: map<string, string> attributes;
        FieldNode,
        IntConstantNode,
        MapTypeNode,
        IdentifierNode,
        //  5: list<i32> favoriteNumbers;
        FieldNode,
        IntConstantNode,
        ListTypeNode,
        IdentifierNode,

        // Exception `UserNotFoundException`
        ExceptionDefinitionNode,
        IdentifierNode,
        // 1: string message;
        FieldNode,
        IntConstantNode,
        BaseTypeNode,
        IdentifierNode,

        // Service `UserService`
        ServiceDefinitionNode,
        IdentifierNode,
        IdentifierNode,
        // getUserById
        FunctionNode,
        CustomTypeNode,
        IdentifierNode,
        FieldNode,
        IntConstantNode,
        BaseTypeNode,
        IdentifierNode,
        FieldNode,
        IntConstantNode,
        CustomTypeNode,
        IdentifierNode,
        // createUser
        FunctionNode,
        VoidTypeNode,
        IdentifierNode,
        FieldNode,
        IntConstantNode,
        CustomTypeNode,
        IdentifierNode,
        // subscribeToUpdates
        FunctionNode,
        StreamTypeNode,
        IdentifierNode,

        // Const `APP_NAME`
        ConstDefinitionNode,
        BaseTypeNode,
        IdentifierNode,
        LiteralNode,
      ];

      expect(visitedTypes, containsAllInOrder(expectedTypes));
      expect(visitedTypes, equals(expectedTypes));
    });
  });
}
