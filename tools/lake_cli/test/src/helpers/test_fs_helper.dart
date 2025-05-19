import 'dart:io';

import 'package:path/path.dart' as p;

class TestFsHelper {
  TestFsHelper() {
    root = Directory.systemTemp.createTempSync('test_fs_');
  }
  
  late final Directory root;

  String path(String relativePath) => p.join(root.path, relativePath);

  File createFile(String relativePath, {String? content}) {
    final file = File(path(relativePath))..createSync(recursive: true);

    if (content != null) {
      file.writeAsStringSync(content);
    }

    return file;
  }

  void createDir(String relativePath) =>
      Directory(path(relativePath)).createSync(recursive: true);

  void createTree(Map<String, dynamic> structure, [String basePath = '']) {
    for (final entry in structure.entries) {
      final name = entry.key;
      final value = entry.value;
      final fullPath = p.join(basePath, name);

      if (value is String? || value == null) {
        createFile(fullPath, content: value);
      } else if (value is Map<String, dynamic>) {
        createDir(fullPath);
        createTree(value, fullPath);
      } else {
        throw ArgumentError('Invalid value for "$name": $value');
      }
    }
  }

  void cleanUp() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  }
}
