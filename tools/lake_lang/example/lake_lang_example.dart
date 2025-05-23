// ignore_for_file: avoid_print

import 'dart:io';

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  final currentDir = Directory.current.path;
  final schemaDir = '$currentDir/example/schema';
  final exampleLakeFilePath = '$schemaDir/example.lake';
  final exampleInput = loadLakeFile(exampleLakeFilePath);

  final grammar = LakeGrammarDefinition();
  final parser = grammar.build();
  final result = parser.parse(exampleInput);

  switch (result) {
    case Success(message: final message):
      print('Parsing succeeded: $message');
    case Failure(message: final message, position: final position):
      print('Parsing failed at position $position: $message');
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
