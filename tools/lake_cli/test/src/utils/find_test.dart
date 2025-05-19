import 'package:lake_cli/src/utils/find.dart';
import 'package:test/test.dart';

import '../helpers/test_fs_helper.dart';

void main() {
  group('findFiles', () {
    late TestFsHelper fsHelper;

    setUp(() {
      fsHelper =
          TestFsHelper()..createTree({
            'main.dart': '',
            'models': {
              'user.yml': '',
              'user_profile.yaml': '',
              'requests': {'user_create_request.yaml': ''},
              'responses': {'user_create_response.yaml': ''},
              'enums': {'scope.yaml': '', 'user_type.yaml': ''},
            },
            'services': {
              'users_service.yaml': '',
              'auth_with_email_service.yaml': '',
              'auth_with_google_service.yaml': '',
            },
          });
    });

    tearDown(() {
      fsHelper.cleanUp();
    });

    test('finds files matching the pattern', () {
      final filter = FindFiltersBuilder()..extensions(['.yaml', '.yml']);

      final yamlFiles = findFilesSync(
        workingDirectory: fsHelper.root.path,
        filter: filter(),
      );

      expect(yamlFiles, isNotEmpty);
      expect(yamlFiles.length, 9);
    });
  });
}
