import 'dart:io';

import 'package:protoc_plugin/protoc.dart';

import 'config/config.dart';

/// Generates project.
void generate(Config config) {
  config.logger.info('Generating project...');

  CodeGenerator(stdin, stdout).generate();

  config.logger.info('Project generated');
}
