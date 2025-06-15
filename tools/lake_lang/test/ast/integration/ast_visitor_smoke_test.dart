import 'package:test/test.dart';

import '../_ast_helpers.dart';
import 'ast_visitor_test.dart'; // Import the specific visitor

// Main test group for AST Visitor functionality
void main() {
  group('AST Visitor Smoke Tests', () {
    test('should visit all node types in a complex document', () {
      const source = '''
        import "my_lib";
        namespace js my_app;

        enum Status {
          ACTIVE = 1,
          INACTIVE;
        }

        typedef list<string> StringList;

        struct Address {
          1: string street;
        }

        struct User {
          1: required string name;
          2: optional i32 age = 30;
          3: Address homeAddress; // Custom type
          4: map<string, string> attributes;
          5: list<i32> favoriteNumbers;
        }

        exception UserNotFoundException {
          1: string message;
        }

        service UserService extends BaseService {
          User getUserById(1: i32 id) throws (1: UserNotFoundException);
          void createUser(1: User newUser);
          stream<string> subscribeToUpdates();
        }

        const string APP_NAME = "MyLakeApp";
      ''';

      final ast = parseAndGetAst(source);
      final visitedTypes = <String>{};

      final recordingVisitor = RecordingVisitor();
      ast.accept(recordingVisitor);

      visitedTypes.addAll(recordingVisitor.calls);
    });
  });
}
