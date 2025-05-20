import 'package:lake_cli/src/utils/find.dart';
import 'package:test/test.dart';

import '../helpers/test_fs_helper.dart';

void main() {
  group('findFiles - async', () {
    late TestFsHelper fs;

    setUp(() {
      fs =
          TestFsHelper()..createTree({
            'main.dart': '',
            'models': {
              'user.yml': '',
              'user_profile.yaml': '',
              'requests': {'user_create_request.yaml': ''},
              'responses': {'user_create_response.yaml': ''},
              'enums': {'scope.yaml': '', 'user_type.yaml': ''},
              'exceptions': {'user_exception.yaml': ''},
            },
            'services': {
              'users_service.yaml': '',
              'auth_with_email_service.yaml': '',
              'auth_with_google_service.yaml': '',
            },
            'tmp': {'file.tmp': '', 'nested_dir': {}},
            'docs': {'README.md': '', 'CHANGELOG.md': ''},
            'misc': {'some_file.json': '', 'another_file.txt': ''},
          });
    });

    tearDown(() {
      fs.cleanUp();
    });

    test('find all .yaml and .yml files using extensions filter', () async {
      final expectedRelativePaths = [
        'models/user.yml',
        'models/user_profile.yaml',
        'models/requests/user_create_request.yaml',
        'models/responses/user_create_response.yaml',
        'models/enums/scope.yaml',
        'models/enums/user_type.yaml',
        'models/exceptions/user_exception.yaml',
        'services/users_service.yaml',
        'services/auth_with_email_service.yaml',
        'services/auth_with_google_service.yaml',
      ];

      final expectedFullPaths = expectedRelativePaths
          .map(fs.path)
          .toList(growable: false);

      final filter = FindFiltersBuilder()..extensions(['.yaml', '.yml']);
      final streamResult = findFiles(
        workingDirectory: fs.root.path,
        filter: filter(),
      );

      final foundFiles = await streamResult.toList();
      expect(foundFiles, unorderedEquals(expectedFullPaths));
      expect(foundFiles.length, expectedFullPaths.length);
    });

    test('Find only regular files (no directories)', () async {
      final expectedRelativePaths = [
        'main.dart',
        'models/user.yml',
        'models/user_profile.yaml',
        'models/requests/user_create_request.yaml',
        'models/responses/user_create_response.yaml',
        'models/enums/scope.yaml',
        'models/enums/user_type.yaml',
        'models/exceptions/user_exception.yaml',
        'services/users_service.yaml',
        'services/auth_with_email_service.yaml',
        'services/auth_with_google_service.yaml',
        'tmp/file.tmp',
        'docs/README.md',
        'docs/CHANGELOG.md',
        'misc/some_file.json',
        'misc/another_file.txt',
      ];

      final expectedFullPaths = expectedRelativePaths
          .map(fs.path)
          .toList(growable: false);

      final filter = FindFiltersBuilder()..isFile();
      final streamResult = findFiles(
        workingDirectory: fs.root.path,
        filter: filter(),
      );

      final foundFiles = await streamResult.toList();
      expect(foundFiles, unorderedEquals(expectedFullPaths));
      expect(foundFiles.length, expectedFullPaths.length);
    });

    test(
      'finds files matching "main.dart" OR ".yaml" extension (groupOr)',
      () async {
        final expectedRelativePaths = [
          'main.dart',
          'models/user_profile.yaml',
          'models/requests/user_create_request.yaml',
          'models/responses/user_create_response.yaml',
          'models/enums/scope.yaml',
          'models/enums/user_type.yaml',
          'models/exceptions/user_exception.yaml',
          'services/users_service.yaml',
          'services/auth_with_email_service.yaml',
          'services/auth_with_google_service.yaml',
        ];

        final expectedFullPaths = expectedRelativePaths
            .map(fs.path)
            .toList(growable: false);

        final filter =
            FindFiltersBuilder()..groupOr((b) {
              b
                ..nameContains('main')
                ..extensions(['.yaml']);
            });
        final streamResult = findFiles(
          workingDirectory: fs.root.path,
          filter: filter(),
        );

        final foundFiles = await streamResult.toList();
        expect(foundFiles, unorderedEquals(expectedFullPaths));
        expect(foundFiles.length, expectedFullPaths.length);
      },
    );
  });
}
