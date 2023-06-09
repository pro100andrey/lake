import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:mason_logger/mason_logger.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';

/// Checks if all required dependencies are installed.
void checkAllRequiredDependencies(Logger logger) {
  logger.info('Checking dependencies...');
  _checkCmdVersion('dart --version', logger);
  _checkCmdVersion('npm --version', logger);
  _checkPrisma(logger);
}

/// Checks if a command is installed.
/// Returns the version of the command if installed throws an exception if not.
String _checkCmdVersion(String command, Logger logger) {
  // Split the command by spaces and take the first word.
  final cmd = command.split(' ').first;
  // Check if the command is installed.
  final which = dcli.which(cmd);

  switch (which.found) {
    case true:
      final version = command.toParagraph();
      logger.detail('$cmd: $version');
      return version;
    case false:
      throw Exception('$cmd is not installed');
  }
}

/// Check if prisma is installed and install it if needed.
/// Returns the version of prisma if installed or throws an exception if not.
String _checkPrisma(Logger logger) {
  final container = ProviderContainer();
  final installDir = container.read(lakeInstallDirProvider);
  final packageJsonDir = '$installDir/npm/package.json';

  if (_checkNpmPackage(package: 'prisma', path: packageJsonDir)
      case final version when version != null) {
    logger.detail('prisma: $version');
    return version;
  }

  final progress = logger.progress('installing prisma');
  final installing = 'npm install --prefix $installDir/npm/ prisma'.start(
    progress: dcli.Progress.printStdErr(),
    nothrow: true,
  );

  if (installing.exitCode == 0) {
    progress.cancel();
    logger.detail('prisma installed');
  } else {
    progress.fail();
    throw Exception(
      'prisma failed to install with exit code ${installing.exitCode}',
    );
  }

  if (_checkNpmPackage(package: 'prisma', path: packageJsonDir)
      case final version when version != null) {
    logger.detail('prisma: $version');

    return version;
  }

  throw Exception('prisma version not found');
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
