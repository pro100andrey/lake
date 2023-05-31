import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../business/dependencies/dependencies.dart';
import '../business/generate/config.dart';

///
/// `lake sample`
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
    _logger.info('done.');

    checkIfAllDependenciesInstalled(_logger);

    final config = GenerateConfig();

    return ExitCode.success.code;
  }
}
