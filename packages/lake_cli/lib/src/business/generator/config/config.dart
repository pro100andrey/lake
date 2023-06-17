import 'package:dcli/dcli.dart' as dcli;
import 'package:dotenv/dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mason_logger/mason_logger.dart';

part 'config.freezed.dart';

@freezed
class Config with _$Config {
  factory Config({
    required String lakeInstallDir,
    required String lakeUserDir,
    required String generatePath,
    required Logger logger,
  }) = _Config;

  factory Config.load(Logger logger) {
    final home = dcli.env['HOME'];

    final env = DotEnv()..load();
    final generatePath = env['GENERATE_PATH'];

    if (generatePath == null) {
      throw Exception('GENERATE_PATH is not defined in .env');
    }

    final lakeDir = '$home/.lake';
    final lakeInstallDir = '$lakeDir/install';

    return Config(
      generatePath: generatePath,
      lakeUserDir: lakeDir,
      lakeInstallDir: lakeInstallDir,
      logger: logger,
    );
  }
}
