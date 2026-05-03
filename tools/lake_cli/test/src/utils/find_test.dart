import 'package:lake_cli/src/utils/find.dart';
import 'package:test/test.dart';

import '../helpers/test_fs_helper.dart';

void main() {
  group('findFiles - async', () {
    late TestFsHelper fs;

    setUp(() {
      fs = TestFsHelper()
        ..createTree({
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

        final filter = FindFiltersBuilder()
          ..groupOr((b) {
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

    test(
      'finds files excluding .yaml and .yml extensions (not filter)',
      () async {
        final expectedRelativePaths = [
          'main.dart',
          'tmp/file.tmp',
          'docs/README.md',
          'docs/CHANGELOG.md',
          'misc/some_file.json',
          'misc/another_file.txt',
        ];

        final expectedFullPaths = expectedRelativePaths
            .map(fs.path)
            .toList(growable: false);

        final filter = FindFiltersBuilder()
          ..not((b) {
            b.groupOr((b2) {
              b2
                ..isDirectory()
                ..extensions(['.yaml', '.yml']);
            });
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

    test('finds all files and folders when no filter is provided', () async {
      final streamResult = findFiles(workingDirectory: fs.root.path);
      final foundFiles = await streamResult.toList();

      const allFilesCount = 26;
      expect(foundFiles.length, allFilesCount);
      expect(foundFiles, everyElement(isA<String>()));
    });
  });

  group('findFilesSync - sync', () {
    late TestFsHelper fs;

    setUp(() {
      fs = TestFsHelper()
        ..createTree({
          'main.dart': '',
          'models': {
            'notification.yml': '',
            'notification_config.yaml': '',
            'requests': {'notification_create_request.yaml': ''},
            'responses': {'notification_create_response.yaml': ''},
            'enums': {'notification_type.yaml': ''},
            'exceptions': {'notification_exception.yaml': ''},
          },
          'services': {
            'users_service.yaml': '',
            'auth_with_email_service.yaml': '',
            'auth_with_google_service.yaml': '',
          },
          'tmp': {'log.tmp': '', 'nested_dir': {}},
          'docs': {'README.md': '', 'guidelines.txt': ''},
          'misc': {'template.json': '', 'changelog.txt': ''},
        });
    });

    tearDown(() {
      fs.cleanUp();
    });

    test('finds files matching the pattern (extensions)', () {
      final expectedRelativePaths = [
        'models/notification.yml',
        'models/notification_config.yaml',
        'models/requests/notification_create_request.yaml',
        'models/responses/notification_create_response.yaml',
        'models/enums/notification_type.yaml',
        'models/exceptions/notification_exception.yaml',
        'services/users_service.yaml',
        'services/auth_with_email_service.yaml',
        'services/auth_with_google_service.yaml',
      ];

      final expectedFullPaths = expectedRelativePaths
          .map(fs.path)
          .toList(growable: false);

      final filter = FindFiltersBuilder()..extensions(['.yaml', '.yml']);
      final foundFiles = findFilesSync(
        workingDirectory: fs.root.path,
        filter: filter(),
      );

      expect(foundFiles, unorderedEquals(expectedFullPaths));
      expect(foundFiles.length, expectedFullPaths.length);
    });

    test('throws exception for non-existent working directory', () {
      expect(
        () => findFilesSync(workingDirectory: fs.path('non_existent_dir')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'description',
            contains('Directory does not exist'),
          ),
        ),
      );
    });
  });
}
