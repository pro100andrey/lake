import 'dart:io';

import 'windows.dart';

Future<bool> existsCommand(String command) async {
  if (Platform.isWindows) {
    final commandPath = windowsCommandPath(command);

    return commandPath != null;
  } else {
    final result = await Process.run('which', [command]);

    return result.exitCode == 0;
  }
}
