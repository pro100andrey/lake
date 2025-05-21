// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:petitparser/petitparser.dart';

class LakeGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(document).end();

  // Document ::= Header* Definition*
  Parser document() => ref0(header).star(); //& ref0(definition).star();

  // Header ::= Import | Namespace
  Parser header() => ref0(importHeader) | ref0(namespace);

  // Import ::= 'import' Literal
  Parser importHeader() => string('import') & ref0(literal).trim();

  // Namespace ::= 'namespace' ( NamespaceScope Identifier )
  Parser namespace() =>
      string('namespace') &
      ref0(namespaceScope).trim() &
      ref0(identifier).trim();

  // NamespaceScope ::= '*' | 'js' | 'dart'
  Parser namespaceScope() => string('*') | string('js') | string('dart');

  // Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
  Parser literal() =>
      char('"') & pattern('^"').star().flatten() & char('"') |
      char("'") & pattern("^'").star().flatten() & char("'");

  // Identifier ::= ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*
  Parser identifier() =>
      (letter() | char('_')).optional() &
      (letter() | digit() | char('.') | char('_')).star();

  // ListSeparator ::= ',' | ';'
  // Parser listSeparator() => char(',') | char(';');

  Parser token(Object input) => switch (input) {
    Parser() => input.token().trim(ref0(whitespace)),
    String() => token(input.toParser()),
    _ => throw ArgumentError.value(input, 'Invalid token parser'),
  };
  // Parser whitespaceOrComment() =>
  //     whitespace() |
  //     (string('//') & pattern('^\n').star() & char('\n')) |
  //     (string('/*') & pattern('^*/').star() & string('*/'));
}

void main(List<String> args) {
  final grammar = LakeGrammarDefinition();
  final parser = grammar.build();

  final current = Directory.current;
  final inputPath = current.path;
  final inputFile = File('$inputPath/example.lake');

  final source = inputFile.readAsStringSync();

  final result = parser.parse(source);

  print(result);
}
