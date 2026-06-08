import 'dart:io';

import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';

/// Helper function to parse a Lake AST from a string source.
DocumentNode parseAstFromString(String source) {
  final parser = LakeParser(source);
  return parser.parseDocument();
}

/// Helper function to parse a Lake AST from a file.
DocumentNode parseAstFromFile(String filePath) {
  final dir = Directory.current.path;

  final fullPath = '$dir/$filePath';
  final source = File(fullPath).readAsStringSync();

  return parseAstFromString(source);
}
