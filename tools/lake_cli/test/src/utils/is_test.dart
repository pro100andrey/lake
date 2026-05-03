import 'package:lake_cli/src/utils/is.dart';
import 'package:test/test.dart';

import '../helpers/test_fs_helper.dart';

void main() {
  group('isFile', () {
    late TestFsHelper fs;

    setUp(() {
      fs = TestFsHelper()
        ..createTree({'test_file.txt': '', 'test_directory': {}});
    });

    tearDown(() {
      fs.cleanUp();
    });

    test('returns true for an existing file', () {
      expect(isFile(fs.path('test_file.txt')), isTrue);
    });

    test('returns false for a directory', () {
      expect(isFile(fs.path('test_directory')), isFalse);
    });

    test('throws ArgumentError for an empty path', () {
      expect(() => isFile(''), throwsArgumentError);
    });
  });
}
