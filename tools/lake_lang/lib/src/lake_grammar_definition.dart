// ignore_for_file: avoid_print, lines_longer_than_80_chars

/*
[1] Document ::= Header* Definition*
[2] Header ::= Import | Namespace
[3] Import  ::= 'import' Literal
[4] Namespace ::= ( 'namespace' ( NamespaceScope Identifier ) )
[5] NamespaceScope ::= '*' | 'js' | 'dart'
[6] Definition ::=  Const | Typedef | Enum | Struct | Exception | Service
[7] Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
[8] Typedef ::= 'typedef' DefinitionType Identifier
[9] Enum ::= 'enum' Identifier '{' (Identifier ('=' IntConstant)? ListSeparator?)* '}'
[10] Struct ::= 'struct' Identifier '{' Field* '}'
[11] Exception ::= 'exception' Identifier '{' Field* '}'
[12] Service ::= 'service' Identifier ( 'extends' Identifier )? '{' Function* '}'
[13] Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)? XsdFieldOptions ListSeparator?
[14] FieldID ::= IntConstant ':'
[15] FieldReq ::= 'required' | 'optional'
[16] Function ::= FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
[17] FunctionType ::= FieldType | 'void'
[18] Throws ::= 'throws' '(' Field* ')'
[19] FieldType ::= Identifier | BaseType | ContainerType
[20] DefinitionType ::= BaseType | ContainerType
[21] BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' | 'double' | 'string' | 'binary' | 'uuid'
[22] ContainerType ::= MapType | SetType | ListType
[23] MapType ::= 'map' '<' FieldType ',' FieldType '>'
[24] SetType ::= 'set' CppType? '<' FieldType '>'
[25] ListType ::= 'list' '<' FieldType '>'
[26] ConstValue ::= IntConstant | DoubleConstant | Literal | Identifier | ConstList | ConstMap
IntConstant ::= ('+' | '-')? Digit+
DoubleConstant ::= ('+' | '-')? Digit* ('.' Digit+)? ( ('E' | 'e') IntConstant )?
[27] ConstList ::= '[' (ConstValue ListSeparator?)* ']'
[28] ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
[29] Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
[30] Identifier ::= ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*
[31] ListSeparator ::= ',' | ';'
[32] Letter ::= ['A'-'Z'] | ['a'-'z']
[33] Digit ::=  ['0'-'9']
*/

import 'package:petitparser/petitparser.dart';

/// Defines the grammar for the lake language using the PetitParser library.
/// This approach helps in parsing the lake files by defining the structure and
/// rules of the language.
class LakeGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(document).end();

  // [1] Document ::= Header* Definition*
  Parser document() => ref0(header).star() & ref0(definition).star();

  // [2] Header ::= Import | Namespace
  Parser header() => ref0(import) | ref0(namespace);

  // [3] Import ::= 'import' Literal
  Parser import() => ref0(importToken) & ref0(literal);

  // [5] NamespaceScope ::= '*' | 'js' | 'dart'
  Parser namespaceScope() => undefined();

  // [4] Namespace ::= ( 'namespace' ( NamespaceScope Identifier ) )
  Parser namespace() =>
      namespaceToken() & (ref0(namespaceScope) & ref0(identifier));

  // [6] Definition ::=  Const | Typedef | Enum | Struct | Exception | Service
  Parser definition() => undefined();

  // [7] Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
  Parser constDefinition() => undefined();

  // [29] Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
  Parser literal() =>
      (char('"') & pattern('^"').star() & char('"') |
              char("'") & pattern("^'").star() & char("'"))
          .flatten('" or \' expected');

  // [30] Identifier ::= ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*

  Parser identifier() =>
      (letter() | char('_')) &
      (letter() | digit() | char('.') | char('_')).star().flatten();

  // Keywords
  Parser importToken() => ref1(token, 'import');
  Parser namespaceToken() => ref1(token, 'namespace');
}

Parser token(Object input) => switch (input) {
  Parser() => input.token().trim(),
  String() => token(input.toParser()),
  _ => throw ArgumentError.value(input, 'Invalid token parser'),
};
