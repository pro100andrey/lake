import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../business/dependencies/dependencies.dart';

/// 'lake check-dependencies'
/// A [Command] to check all required dependencies

class CheckDependenciesCommand extends Command<int> {
  CheckDependenciesCommand({
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  @override
  String get description => 'Check all required dependencies';

  @override
  String get name => 'check-dependencies';

  @override
  Future<int> run() async {
    final stopwatch = Stopwatch()..start();

    final dependencies = checkAllRequiredDependencies(_logger);

    if (dependencies == null) {
      return ExitCode.unavailable.code;
    }

    _logger.success('Completed in ${stopwatch.elapsed}');

    return ExitCode.success.code;
  }
}
