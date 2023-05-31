import 'package:dcli/dcli.dart';
import 'package:mason_logger/mason_logger.dart';

void checkIfAllDependenciesInstalled(Logger logger) {
  if (which('npm').notfound) {
    logger.err('npm is not installed');
  }

  if (which('npx').notfound) {
    logger.err('npx is not installed');
  }

  final npx = which('npx');

  if (npx.path == null) {
    logger.info('npx - is not installed');
  }

  dcliExit(0);
}
