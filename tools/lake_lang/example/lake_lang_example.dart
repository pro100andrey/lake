// ignore_for_file: avoid_print

import 'dart:io';

import 'package:lake_lang/lake_lang.dart';
import 'package:lake_lang/src/lake_ast_definition.dart';

void main(List<String> args) {
  final filePath = () {
    if (args.isNotEmpty) {
      return args[0];
    } else {
      final currentDir = Directory.current.path;
      final schemaDir = '$currentDir/schema';
      final exampleLakeFilePath = '$schemaDir/example.lake';
      return exampleLakeFilePath;
    }
  }();

  final exampleInput = loadLakeFile(filePath);

  final grammar = LakeAstGrammarDefinition();
  final parser = grammar.build();

  final watch = Stopwatch()..start();

  final result = parser.parse(exampleInput);

  print('Parsing took: ${watch.elapsedMicroseconds} microseconds');
  watch.stop();


  printParseResult(result);
}

String loadLakeFile(String filePath) {
  final file = File(filePath);
  if (file.existsSync()) {
    return file.readAsStringSync();
  } else {
    throw Exception('File not found: $filePath');
  }
}
