import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../business/dependencies/dependencies.dart';
import '../business/generator/config/config.dart';

/// `lake generate`
/// A [Command] to exemplify a sub command
class GenerateCommand extends Command<int> {
  GenerateCommand({
    required Logger logger,
  }) : _logger = logger;

  @override
  String get description =>
      'Generate code from yaml files for server and clients ';

  @override
  String get name => 'generate';

  final Logger _logger;

  @override
  Future<int> run() async {
    final stopwatch = Stopwatch()..start();
    final dependencies = checkAllRequiredDependencies(_logger);

    if (dependencies == null) {
      return ExitCode.unavailable.code;
    }

    final _ = GeneratorConfig();
    _logger.success('Completed in ${stopwatch.elapsed}');

    return ExitCode.success.code;
  }
}
