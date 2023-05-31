import 'dart:io';

import 'package:path/path.dart';

String? windowsCommandPath(String command) {
  final pathEnv = Platform.environment['Path'];

  if (pathEnv == null) {
    return null;
  }

  final paths = pathEnv.split(';');
  for (final path in paths) {
    if (path.isEmpty) {
      continue;
    }
    
    final possibleCommandPath = join(path, command);

    // Check name without extension.
    var possibleCommandFile = File(possibleCommandPath);
    if (possibleCommandFile.existsSync()) {
      return possibleCommandPath;
    }

    // Check name with bat extension.
    possibleCommandFile = File('$possibleCommandPath.bat');
    if (possibleCommandFile.existsSync()) {
      return possibleCommandPath;
    }
  }

  return null;
}
