import 'package:dcli/dcli.dart' as dcli;
import 'package:mason_logger/mason_logger.dart';

import 'models/dependencies_info.dart';
import 'prisma/prisma.dart';

String? _getVersion(String full, Logger logger) {
  final cmd = full.split(' ').first;
  final which = dcli.which(cmd);

  if (which.found) {
    return full.toParagraph();
  }

  logger.err('$cmd is not installed');

  return null;
}

DependenciesInfo? checkAllRequiredDependencies(Logger logger) {
  final dartVersion = _getVersion('dart --version', logger);
  final npmVersion = _getVersion('npm --version', logger);
  final prismaVersion = getPrismaVersion(logger);

  if (dartVersion == null || npmVersion == null || prismaVersion == null) {
    return null;
  }

  final info = DependenciesInfo(
    dart: dartVersion,
    npm: npmVersion,
    prisma: prismaVersion,
  );

  logger.detail(info.toString());

  return info;
}
