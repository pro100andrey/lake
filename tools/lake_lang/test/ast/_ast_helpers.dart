import 'package:lake_lang/src/ast/lake_ast_grammar_definition.dart';
import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';
import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

/// Helper function to parse a given source string and return the root
/// [DocumentNode] of the AST.
DocumentNode parseAst(String source) {
  final sourceFile = SourceFile.fromString(source);
  final astGrammar = LakeAstGrammarDefinition(sourceFile);
  final parser = astGrammar.build();

  final result = parser.parse(source);

  if (result case Failure(position: final position, message: final message)) {
    fail(
      'Failed to parse AST at position $position: $message\n'
      '${sourceFile.span(position, source.length).highlight()}',
    );
  }

  return result.value;
}
