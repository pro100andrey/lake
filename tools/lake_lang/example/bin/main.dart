// ignore_for_file: avoid_print

import 'package:args/args.dart';
import 'package:lake_lang/lake_lang.dart';
import 'package:source_span/source_span.dart';

const analyzer = SemanticAnalyzer();
const astGrammar = LakeAstGrammarDefinition();

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

  final filePath = inputs.first;

  final sourceCode = loadLakeFile(filePath);
  final sourceFile = SourceFile.fromString(sourceCode, url: filePath);

  final parser = astGrammar.build();

  final result = parser.parse(sourceCode);
  final document = result.value as DocumentNode;

  print('Source File: $filePath \n');

  if (isPrintingAst) {
    final astVisiter = AstPrettyPrinterVisitor(sourceFile);
    document.accept(astVisiter);

    print('Abstract Syntax Tree:');
    print(astVisiter.output);
  }

  if (isRunningSemantic) {
    analyzer.analyze(document: document, sourceFile: sourceFile);

    print('Semantic Analysis:');
    // reporter.hasErrors
    //     ? reporter.printDiagnostics()
    //     : print('No semantic errors found.');
  }
}
