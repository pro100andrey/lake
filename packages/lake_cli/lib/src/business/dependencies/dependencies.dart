import 'dart:convert';
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

/// Checks if all required dependencies are installed.
void checkAllRequiredDependencies(Config config) {
  config.logger.info('Checking dependencies...');
  _checkCmdVersion('dart --version', config);
  _checkCmdVersion('npm --version', config);
  _checkPrisma(config);
  _checkProtoc(config);
}

/// Checks if a command is installed.
/// Returns the version of the command if installed throws an exception if not.
String _checkCmdVersion(String command, Config config) {
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
    return _checkCmdVersion('$protoc --version', config);
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

      final unzip = 'unzip -o $saveToPath -d ${config.lakeInstallDir}/protoc'.start(
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

  return _checkCmdVersion('$protoc --version', config);
}

/// Check if prisma is installed and install it if needed.
/// Returns the version of prisma if installed or throws an exception if not.
String _checkPrisma(Config config) {
  final packageJsonDir = '${config.lakeInstallDir}/npm/package.json';

  if (_checkNpmPackage(package: 'prisma', path: packageJsonDir)
      case final version when version != null) {
    config.logger.detail('prisma: $version');
    return version;
  }

  final progress = config.logger.progress('installing prisma');
  final installing = 'npm install --prefix ${config.lakeInstallDir}/npm/ prisma'.start(
    progress: dcli.Progress.printStdErr(),
    nothrow: true,
  );

  if (installing.exitCode == ExitCode.success.code) {
    progress.cancel();
    config.logger.detail('prisma installed');
  } else {
    progress.fail();
    throw Exception(
      'prisma failed to install with exit code ${installing.exitCode}',
    );
  }

  if (_checkNpmPackage(package: 'prisma', path: packageJsonDir)
      case final version when version != null) {
    config.logger.detail('prisma: $version');

    return version;
  }

  throw const NoInstallException('prisma version not found');
}

/// Checks if a npm package is installed.
/// Returns the version of the package if installed or null if not.
String? _checkNpmPackage({required String package, required String path}) {
  final uri = Uri.parse(path);
  final file = File.fromUri(uri);

  if (file.existsSync()) {
    final packageJson = file.readAsStringSync();
    final packageMap = json.decode(packageJson) as Map<String, dynamic>;
    final dependencies = packageMap['dependencies'] as Map<String, dynamic>;
    final version = dependencies[package] as String;

    return version;
  }

  return null;
}
