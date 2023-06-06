import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:mason_logger/mason_logger.dart';

/// Check if prism is installed
String? getPrismaVersion(Logger logger) {
  final dir = dcli.env['HOME'];

  final lakeDir = '$dir/.lake';

  final packageJsonFile = File.fromUri(
    Uri.parse('$lakeDir/install/npm/package.json'),
  );

  if (packageJsonFile.existsSync()) {
    final packageJson = packageJsonFile.readAsStringSync();
    final package = json.decode(packageJson) as Map<String, dynamic>;
    final dependencies = package['dependencies'] as Map<String, dynamic>;
    final version = dependencies['prisma'] as String;

    return version;
  }

  logger.warn('prisma is not installed');

  final allowed = dcli.confirm(
    'Do you want install prisma?',
    defaultValue: true,
  );

  if (!allowed) {
    logger.err('prisma is not installed');

    return null;
  }

  final progress = logger.progress('installing prisma');

  final installing = 'npm install --prefix $lakeDir/install/npm/ prisma'.start(
    progress: dcli.Progress.printStdErr(),
    nothrow: true,
  );

  if (installing.exitCode == 0) {
    progress.cancel();
    logger.success('prisma installed');
  } else {
    progress.fail();
  }

  if (packageJsonFile.existsSync()) {
    final packageJson = packageJsonFile.readAsStringSync();
    final package = json.decode(packageJson) as Map<String, dynamic>;
    final dependencies = package['dependencies'] as Map<String, dynamic>;
    final version = dependencies['prisma'] as String;

    return version;
  }

  return null;
}
