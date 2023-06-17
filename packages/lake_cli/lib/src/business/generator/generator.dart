import 'config/config.dart';

final class Generator {
  Generator({
    required this.config,
  });

  final Config config;

  /// Generates project.
  void generate() {
    config.logger.info('Generating project...');

    config.logger.info('Project generated');
  }
}
