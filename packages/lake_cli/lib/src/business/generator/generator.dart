import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:protoc_plugin/protoc.dart';

/// Generates project.
void generate(Logger logger) {
  logger.info('Generating project...');

  CodeGenerator(stdin, stdout).generate();

  logger.info('Project generated');
}
