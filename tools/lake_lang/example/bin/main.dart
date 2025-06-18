// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:lake_lang/lake_lang.dart';

void main(List<String> args) {
  final argParser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show help',
      negatable: false,
    )
    ..addFlag(
      'ast',
      abbr: 'a',
      help: 'Print the AST',
      negatable: false,
    )
    ..addFlag(
      'semantic',
      abbr: 's',
      help: 'Run semantic analysis',
      negatable: false,
    )
    ..addMultiOption(
      'input',
      abbr: 'i',
      help: 'Input file(s) to process',
      valueHelp: 'file',
      defaultsTo: [],
    );

  final argResults = argParser.parse(args);

  if (argResults['help'] as bool) {
    print(argParser.usage);
    return;
  }

  final inputs = argResults['input'] as List<String>;
  if (inputs.isEmpty) {
    print('No input files provided. Use --help for usage information.');
    print(argParser.usage);
    return;
  }

  final isPrintingAst = argResults['ast'] as bool;
  final isRunningSemantic = argResults['semantic'] as bool;

  if (isPrintingAst) {}

  if (isRunningSemantic) {
    final watch = Stopwatch()..start();
    final reporter = ErrorReporter();
    final analyzer = SemanticAnalyzerNew(reporter);

    final sourceFiles = <String, String>{};
    for (final input in inputs) {
      final currentDir = Directory.current.path;
      final file = loadLakeFile('$currentDir/$input');
      sourceFiles[input] = file;
    }

    final success = analyzer.analyze(sourceFiles);

    if (!success) {
      print('Semantic analysis failed with errors:');
      // reporter.hasErrors
      //     ? reporter.printDiagnostics(sourceFile)
      //     : print('No semantic errors found.');
      return;
    }

    watch.stop();
  }
}
