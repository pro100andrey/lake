import 'package:dcli/dcli.dart';
import 'package:mason_logger/mason_logger.dart';

import 'models/dependencies_info.dart';
import 'models/js_package_info.dart';

String _checkFound(String cmd, String versionArg, Logger logger) {
  final result = which(cmd);

  if (result.found) {
    return '$cmd $versionArg'.toParagraph();
  }

  logger.err('$cmd is not installed');
  throw Exception('$cmd is not installed');
}

String _checkPrismaFound(Logger logger) {
  final result = 'npm -g -j ls prisma'.toParagraph();

  if (result.isNotEmpty) {
    final prisma = JsPackageInfo.prisma(result);

    return prisma.version;
  }

  throw Exception('prisma is not installed');
}

DependenciesInfo checkAllRequiredDependencies(Logger logger) {
  final dartVersion = _checkFound('dart', '--version', logger);
  final npmVersion = _checkFound('npm', '--version', logger);
  final prismaVersion = _checkPrismaFound(logger);

  final info = DependenciesInfo(
    dart: dartVersion,
    prisma: prismaVersion,
    npm: npmVersion,
  );

  logger.detail(info.toString());

  return info;
}
