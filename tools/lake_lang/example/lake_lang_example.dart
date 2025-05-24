// ignore_for_file: avoid_print

import 'dart:io';

import 'package:lake_lang/lake_lang.dart';

void main() {
  final currentDir = Directory.current.path;
  final schemaDir = '$currentDir/schema';
  final exampleLakeFilePath = '$schemaDir/example.lake';
  final exampleInput = loadLakeFile(exampleLakeFilePath);

  final grammar = LakeGrammarDefinition();
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
