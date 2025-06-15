import 'dart:io';

import 'package:source_span/source_span.dart';

import '../../lake_lang.dart';

String loadLakeFile(String filePath) {
  final file = File(filePath);
  if (file.existsSync()) {
    return file.readAsStringSync();
  } else {
    throw Exception('File not found: $filePath');
  }
}

LakeAstGrammarDefinition loadLakeAstGrammar(String filePath) {
  final sourceCode = loadLakeFile(filePath);
  final sourceFile = SourceFile.fromString(sourceCode, url: filePath);
  final astGrammar = LakeAstGrammarDefinition(sourceFile);

  final parser = astGrammar.buildParser();

  return astGrammar;
}
