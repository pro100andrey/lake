// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:lake_lang/lake_lang.dart';
import 'package:source_span/source_span.dart';

void main(List<String> args) {
  final argParser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false)
    ..addFlag('ast', abbr: 'a', help: 'Print the AST', negatable: false)
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

  print(inputs);

  final isPrintingAst = argResults['ast'] as bool;
  final isRunningSemantic = argResults['semantic'] as bool;

  final filePath = inputs.first;
  final sourceCode = loadLakeFile(filePath);
  final sourceFile = SourceFile.fromString(sourceCode, url: filePath);

  final astGrammar = LakeAstGrammarDefinition(sourceFile);
  final parser = astGrammar.build();
  final result = parser.parse(sourceCode);
  final ast = result.value as DocumentNode;

  if (isPrintingAst) {
    print('AST printing is enabled.');
  }

  if (isRunningSemantic) {
    print('Semantic analysis is enabled.');

    final reporter = ErrorReporter();
    SemanticAnalyzer(reporter).analyze(ast);

    reporter.hasErrors
        ? reporter.printErrors()
        : print('No semantic errors found.');
  }
}

String loadLakeFile(String filePath) {
  final file = File(filePath);
  if (file.existsSync()) {
    return file.readAsStringSync();
  } else {
    throw Exception('File not found: $filePath');
  }
}
