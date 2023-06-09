import 'package:dcli/dcli.dart' as dcli;
import 'package:dotenv/dotenv.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:riverpod/riverpod.dart';

import 'generator/config/config.dart' as generator;

/// Lake user directory provider.
final lakeUserDirProvider = Provider<String>((ref) {
  final home = dcli.env['HOME'];

  return '$home/.lake';
});

/// Lake install directory provider.
final lakeInstallDirProvider =
    Provider<String>((ref) => '${ref.read(lakeUserDirProvider)}/install');

/// Logger provider.
final loggerProvider = Provider<Logger>((ref) => Logger());

/// Generator config provider.
final generatorConfigProvider = Provider<generator.Config>(
  (ref) {
    final env = DotEnv()..load();
    final generatePath = env['GENERATE_PATH'];

    if (generatePath == null) {
      throw Exception('GENERATE_PATH is not defined in .env');
    }

    return generator.Config(generatePath: generatePath);
  },
);
