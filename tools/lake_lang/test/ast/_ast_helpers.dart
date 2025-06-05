import 'package:lake_lang/src/ast/lake_ast_grammar_definition.dart';
import 'package:lake_lang/src/ast/nodes/ast_nodes.dart';
import 'package:source_span/source_span.dart';

/// Helper function to parse a given source string and return the root
/// [DocumentNode] of the AST.
DocumentNode parseAst(String source) {
  final sourceFile = SourceFile.fromString(source);
  final astGrammar = LakeAstGrammarDefinition(sourceFile);
  final parser = astGrammar.build();

  final result = parser.parse(source);

  return result.value;
}
