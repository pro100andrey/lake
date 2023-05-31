import 'package:dcli/dcli.dart';
import 'package:mason_logger/mason_logger.dart';

void checkIfAllDependenciesInstalled(Logger logger) {
  final npmFound = which('npm').found;
  final npxFound = which('npx').found;

  if (!npmFound) {
    logger.err('npm is not installed');
  }

  if (!npxFound) {
    logger.err('npx is not installed');
  }

  final result = 'npm -g -j ls prisma'.toParagraph();

  if (result.isNotEmpty) {
    logger.info(result);
  }

  if (!npxFound || !npxFound) {
    throw Exception('Dependencies is not installed');
  }
}
