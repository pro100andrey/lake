import 'dart:io';

import 'package:lake_lang/src/ast/lake_ast_grammar_definition.dart';
import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';
import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

/// Helper function to parse a Lake AST from a string source.
DocumentNode parseAstFromString(String source) {
  final sourceFile = SourceFile.fromString(source);
  const astGrammar = LakeAstGrammarDefinition();
  final parser = astGrammar.build();

  final result = parser.parse(source);

  if (result case Failure(position: final position, :final message)) {
    final span = sourceFile.span(position);

    fail(
      'Failed to parse AST at position $position: $message\n'
      '${span.highlight()}',
    );
  }

  return result.value;
}

/// Helper function to parse a Lake AST from a file.
DocumentNode parseAstFromFile(String filePath) {
  final dir = Directory.current.path;

  final fullPath = '$dir/$filePath';
  final source = File(fullPath).readAsStringSync();

  return parseAstFromString(source);
}
