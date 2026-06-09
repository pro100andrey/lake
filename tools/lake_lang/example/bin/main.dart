import 'dart:io';

import 'package:args/args.dart';
import 'package:lake_lang/lake_lang.dart';
import 'package:source_span/source_span.dart';

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
    stdout.writeln(argParser.usage);
    return;
  }

  final inputs = argResults['input'] as List<String>;
  if (inputs.isEmpty) {
    stdout
      ..writeln(
        'No input files provided. Use --help for usage information.',
      )
      ..writeln(argParser.usage);
    return;
  }

  const analyzer = SemanticAnalyzer();

  final isPrintingAst = argResults['ast'] as bool;
  final isRunningSemantic = argResults['semantic'] as bool;

  final filePath = inputs.first;
  final sourceCode = loadLakeFile(filePath);
  final sourceFile = SourceFile.fromString(sourceCode, url: filePath);

  final parser = LakeParser(sourceCode);
  final document = parser.parseDocument();

  stdout.writeln('Source File: $filePath \n');

  if (isPrintingAst) {
    final astVisiter = AstPrettyPrinterVisitor(sourceFile);
    document.accept(astVisiter);

    stdout
      ..writeln('Abstract Syntax Tree:')
      ..writeln(astVisiter.output);
  }

  if (isRunningSemantic) {
    final watch = Stopwatch()..start();
    final reporter = ErrorReporter();
    analyzer.analyze(document: document, reporter: reporter);

    stdout.writeln('Semantic Analysis:');
    reporter.hasErrors
        ? reporter.printDiagnostics(sourceFile)
        : stdout.writeln('No semantic errors found.');

    watch.stop();
    stdout.writeln('Analysis completed in ${watch.elapsedMilliseconds} ms.');
  }
}
