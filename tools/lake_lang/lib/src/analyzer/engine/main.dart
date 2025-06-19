import 'dart:io';

import 'package:path/path.dart' as p;

import 'analysis_engine.dart';

Future<void> main(List<String> args) async {
  final projectRoot = p.join(Directory.current.path, 'test_project');
  final entryPoints = [
    p.join(projectRoot, 'common.lake'),
    p.join(projectRoot, 'services.lake'),
  ];

  // Ensure test files exist
  _createTestFiles(projectRoot);

  final engine = AnalysisEngine();

  // Subscribe to diagnostic changes
  engine.diagnosticsStream.listen((diagnostics) {
    print('\n>>> Diagnostics Updated! <<<');

    print('Total diagnostics: $diagnostics');
  });

  print('--- Initial Analysis ---');
  await engine.analyzeProject(entryPoints);

  final commonFilePath = p.join(projectRoot, 'common.lake');
  final commonAst = await engine.getAst(commonFilePath);

  if (commonAst != null) {
    print('AST for common.lake: Root node type: ${commonAst.runtimeType}');
    // You can traverse commonAst here to inspect it
  }

  final commonSemanticInfo = await engine.getSemanticInfo(commonFilePath);
  if (commonSemanticInfo != null) {
    print('Semantic Info for common.lake: Local symbols:');
    // commonSemanticInfo.localSymbolTable.getSymbolsInScope().forEach((s) {
    //   print('  - ${s.name} (${s.kind})');
    // });
  }
}

void _createTestFiles(String projectRoot) {
  Directory(projectRoot).createSync(recursive: true);

  File(p.join(projectRoot, 'common.lake')).writeAsStringSync('''
namespace * common

const string APP_NAME = "MyLakeApp"

typedef i32 MyId

enum Status {
    ACTIVE = 1,
    INACTIVE = 2,
    PENDING = 3
}

struct User {
    1: required i32 id;
    2: optional string name;
    3: required Status status;
}
''');

  File(p.join(projectRoot, 'services.lake')).writeAsStringSync('''
import "common.lake"

namespace * services

exception UserNotFoundException {
    1: required common.MyId userId;
}

service UserService {
    common.User getUserById(1: required common.MyId id) throws (UserNotFoundException exception);

    // Method with a syntax error (missing semicolon)
    void createUser(1: required common.User user)

    // Method with an undefined type (will cause a semantic error)
    void deleteUser(1: required UnknownType userId);

    AnotherService getAnotherService(); // Assuming AnotherService from another file
}
''');
}

// Helper to delete test files
void _deleteTestFiles(String projectRoot) {
  final dir = Directory(projectRoot);
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}
