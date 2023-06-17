import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:mason_logger/mason_logger.dart';

import '../generator/config/config.dart';

/// No install exception.
class NoInstallException implements Exception {
  /// No install exception.
  const NoInstallException(this.message);

  /// Message.
  final String message;

  @override
  String toString() => message;
}

final class Dependencies {
  Dependencies({
    required this.config,
  });

  final Config config;

  /// Checks if all required dependencies are installed.
  void check() {
    config.logger.info('Checking dependencies...');
    _checkCmdVersion('dart --version');
    _checkProtoc(config);
  }

  /// Checks if a command is installed.
  /// Returns the version of the command if installed throws an exception if not.
  String _checkCmdVersion(String command) {
    // Split the command by spaces and take the first word.
    final cmd = command.split(' ').first;
    final cmdName = cmd.split('/').last;
    // Check if the command is installed.
    final which = dcli.which(cmd);

    switch (which.found) {
      case true:
        final version = command.toParagraph();
        config.logger.detail('$cmdName: $version');
        return version;
      case false:
        throw NoInstallException('$cmdName is not installed');
    }
  }

  String _checkProtoc(Config config) {
    final protoc = '${config.lakeInstallDir}/protoc/bin/protoc';

    try {
      return _checkCmdVersion('$protoc --version');
    } on NoInstallException {
      const releases = 'https://github.com/protocolbuffers/protobuf/releases';
      const version = '23.2';

      final os = switch (Platform.operatingSystem) {
        'macos' => 'osx',
        _ => throw Exception('unsupported operating system'),
      };

      final platform = switch (Platform.operatingSystem) {
        'macos' => 'universal_binary',
        _ => throw Exception('unsupported operating system'),
      };

      final fileName = 'protoc-$version-$os-$platform.zip';
      final url = '$releases/download/v$version/$fileName';
      final saveToPath = '${config.lakeInstallDir}/$fileName';

      try {
        dcli.fetch(url: url, saveToPath: saveToPath);
        final zip = File(saveToPath);

        if (zip.existsSync()) {
          config.logger.detail('protoc downloaded...');
        } else {
          throw Exception('protoc failed to download');
        }

        final unzip =
            'unzip -o $saveToPath -d ${config.lakeInstallDir}/protoc'.start(
          progress: dcli.Progress.printStdErr(),
          nothrow: true,
        );

        zip.deleteSync();

        if (unzip.exitCode == ExitCode.success.code) {
          config.logger.detail('protoc installed');
        } else {
          throw Exception(
            'protoc failed to install with exit code ${unzip.exitCode}',
          );
        }
      } on dcli.FetchException catch (e) {
        config.logger.err(e.message);
      }
    }

    return _checkCmdVersion('$protoc --version');
  }
}
