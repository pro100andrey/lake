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
[13] Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)? ListSeparator?
[14] FieldID ::= IntConstant ':'
[15] FieldReq ::= 'required' | 'optional'
[16] Function ::= FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
[17] FunctionType ::= FieldType | 'void'
[18] Throws ::= 'throws' '(' Field* ')'
[19] FieldType ::= Identifier | BaseType | ContainerType
[20] DefinitionType ::= BaseType | ContainerType
[21] BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' | 'double' | 'string' | 'binary' | 'uuid' 'uuid' | 'date' | 'duration'
[22] ContainerType ::= MapType | SetType | ListType | StreamType
[23] MapType ::= 'map' '<' FieldType ',' FieldType '>'
[24] SetType ::= 'set''<' FieldType '>'
[25] ListType ::= 'list' '<' FieldType '>'
[26] StreamType ::= 'stream' '<' FieldType '>'
[27] ConstValue ::= IntConstant | DoubleConstant | Literal | Identifier | ConstList | ConstMap
IntConstant ::= ('+' | '-')? Digit+
DoubleConstant ::= ('+' | '-')? Digit* ('.' Digit+)? ( ('E' | 'e') IntConstant )?
[28] ConstList ::= '[' (ConstValue ListSeparator?)* ']'
[29] ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
[30] Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
[31] Identifier ::= ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*
[32] ListSeparator ::= ',' | ';'
[33] Letter ::= ['A'-'Z'] | ['a'-'z']
[34] Digit ::=  ['0'-'9']
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

  // [4] Namespace ::= ( 'namespace' ( NamespaceScope Identifier ) )
  Parser namespace() =>
      ref0(namespaceToken) & (ref0(namespaceScope) & ref0(identifier));

  // [5] NamespaceScope ::= '*' | 'js' | 'dart'
  Parser namespaceScope() =>
      char('*') | ref1(token, 'js') | ref1(token, 'dart');

  // [6] Definition ::= Const | Typedef | Enum | Struct | Exception | Service
  Parser definition() =>
      ref0(constDefinition) |
      ref0(typedefDefinition) |
      ref0(enumDefinition) |
      ref0(structDefinition) |
      ref0(exceptionDefinition) |
      ref0(serviceDefinition);

  // [7] Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
  Parser constDefinition() =>
      ref0(constToken) &
      ref0(fieldType) &
      ref0(identifier) &
      char('=').trim() &
      ref0(constValue) &
      ref0(listSeparator).optional();

  // [8] Typedef ::= 'typedef' DefinitionType Identifier
  Parser typedefDefinition() =>
      ref0(typedefToken) & ref0(definitionType) & ref0(identifier);

  // [9] Enum ::= 'enum' Identifier '{' (Identifier ('=' IntConstant)? ListSeparator?)* '}'
  Parser enumDefinition() =>
      ref0(enumToken) &
      ref0(identifier) &
      char('{').trim() &
      (ref0(identifier) &
              (char('=').trim() & ref0(intConstant)).optional() &
              ref0(listSeparator).optional())
          .star() &
      char('}').trim();

  // [10] Struct ::= 'struct' Identifier '{' Field* '}'
  Parser structDefinition() =>
      ref0(structToken) &
      ref0(identifier) &
      char('{').trim() &
      ref0(field).star() &
      char('}').trim();

  // [11] Exception ::= 'exception' Identifier '{' Field* '}'
  Parser exceptionDefinition() =>
      ref0(exceptionToken) &
      ref0(identifier) &
      char('{').trim() &
      ref0(field).star() &
      char('}').trim();

  // [12] Service ::= 'service' Identifier ( 'extends' Identifier )? '{' Function* '}'
  Parser serviceDefinition() =>
      ref0(serviceToken) &
      ref0(identifier) &
      (ref0(extendsToken) & ref0(identifier)).optional() &
      char('{').trim() &
      ref0(function).star() &
      char('}').trim();

  // [13] Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)? ListSeparator?
  Parser field() =>
      ref0(fieldID).optional() &
      ref0(fieldReq).optional() &
      ref0(fieldType) &
      ref0(identifier) &
      (char('=').trim() & ref0(constValue)).optional() &
      ref0(listSeparator).optional();

  // [14] FieldID ::= IntConstant ':'
  Parser fieldID() => ref0(intConstant) & char(':').trim();

  // [15] FieldReq ::= 'required' | 'optional'
  Parser fieldReq() => ref0(requiredToken) | ref0(optionalToken);

  // [16] Function ::= FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
  Parser function() =>
      ref0(functionType) &
      ref0(identifier) &
      char('(').trim() &
      ref0(field).star() &
      char(')').trim() &
      ref0(throws).optional() &
      ref0(listSeparator).optional();

  // [17] FunctionType ::= FieldType | 'void'
  Parser functionType() => ref0(fieldType) | ref0(voidToken);

  // [18] Throws ::= 'throws' '(' Field* ')'
  Parser throws() =>
      ref0(throwsToken) &
      char('(').trim() &
      ref0(field).star() &
      char(')').trim();

  // [19] FieldType ::= Identifier | BaseType | ContainerType
  Parser fieldType() => ref0(identifier) | ref0(baseType) | ref0(containerType);

  // [20] DefinitionType ::= BaseType | ContainerType
  Parser definitionType() => ref0(baseType) | ref0(containerType);

  // [21] BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' | 'double' | 'string' | 'binary' | 'uuid' | 'date' | 'duration'
  Parser baseType() =>
      ref0(boolToken) |
      ref0(byteToken) |
      ref0(i8Token) |
      ref0(i16Token) |
      ref0(i32Token) |
      ref0(i64Token) |
      ref0(doubleToken) |
      ref0(stringToken) |
      ref0(binaryToken) |
      ref0(uuidToken) |
      ref0(dateToken) |
      ref0(durationToken);

  // [22] ContainerType ::= MapType | SetType | ListType | StreamType
  Parser containerType() =>
      ref0(mapType) | ref0(setType) | ref0(listType) | ref0(streamType);

  // [23] MapType ::= 'map' '<' FieldType ',' FieldType '>'
  Parser mapType() =>
      ref0(mapToken) &
      char('<').trim() &
      ref0(fieldType) &
      char(',').trim() &
      ref0(fieldType) &
      char('>').trim();

  // [24] SetType ::= 'set' '<' FieldType '>'
  Parser setType() =>
      ref0(setTypeToken) &
      char('<').trim() &
      ref0(fieldType) &
      char('>').trim();

  // [25] ListType ::= 'list' '<' FieldType '>'
  Parser listType() =>
      ref0(listToken) & char('<').trim() & ref0(fieldType) & char('>').trim();

  // [26] StreamType ::= 'stream' '<' FieldType '>'
  Parser streamType() =>
      ref0(streamToken) & char('<').trim() & ref0(fieldType) & char('>').trim();

  // [27] ConstValue ::= IntConstant | DoubleConstant | Literal | Identifier | ConstList | ConstMap
  Parser constValue() =>
      ref0(intConstant) |
      ref0(doubleConstant) |
      ref0(literal) |
      ref0(identifier) |
      ref0(constList) |
      ref0(constMap);

  // IntConstant ::= ('+' | '-')? Digit+
  Parser intConstant() =>
      (char('+') | char('-')).optional() & ref0(digit).plus().flatten();

  // DoubleConstant ::= ('+' | '-')? Digit* ('.' Digit+)? ( ('E' | 'e') IntConstant )?
  Parser doubleConstant() =>
      (char('+') | char('-')).optional() &
      ref0(digit).star() &
      (char('.') & ref0(digit).plus()).optional() &
      ((char('E') | char('e')) & ref0(intConstant)).optional().flatten();

  // [28] ConstList ::= '[' (ConstValue ListSeparator?)* ']'
  Parser constList() =>
      char('[').trim() &
      (ref0(constValue) & ref0(listSeparator).optional()).star() &
      char(']').trim();

  // [29] ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
  Parser constMap() =>
      char('{').trim() &
      (ref0(constValue) &
              char(':').trim() &
              ref0(constValue) &
              ref0(listSeparator).optional())
          .star() &
      char('}').trim();

  // [30] Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
  Parser literal() =>
      (char('"') & pattern('^"').star() & char('"') |
              char("'") & pattern("^'").star() & char("'"))
          .flatten();

  // [31] Identifier ::= ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*
  Parser identifier() =>
      ((letter() | char('_')) &
              (letter() | ref0(digit) | char('.') | char('_')).star())
          .flatten();

  // [32] ListSeparator ::= ',' | ';'
  Parser listSeparator() => (char(',') | char(';')).trim();

  // Keywords (Helper parsers)
  Parser importToken() => ref1(token, 'import');
  Parser namespaceToken() => ref1(token, 'namespace');
  Parser constToken() => ref1(token, 'const');
  Parser typedefToken() => ref1(token, 'typedef');
  Parser enumToken() => ref1(token, 'enum');
  Parser structToken() => ref1(token, 'struct');
  Parser exceptionToken() => ref1(token, 'exception');
  Parser serviceToken() => ref1(token, 'service');
  Parser extendsToken() => ref1(token, 'extends');
  Parser requiredToken() => ref1(token, 'required');
  Parser optionalToken() => ref1(token, 'optional');
  Parser voidToken() => ref1(token, 'void');
  Parser throwsToken() => ref1(token, 'throws');

  // BaseType tokens
  Parser boolToken() => ref1(token, 'bool');
  Parser byteToken() => ref1(token, 'byte');
  Parser i8Token() => ref1(token, 'i8');
  Parser i16Token() => ref1(token, 'i16');
  Parser i32Token() => ref1(token, 'i32');
  Parser i64Token() => ref1(token, 'i64');
  Parser doubleToken() => ref1(token, 'double');
  Parser stringToken() => ref1(token, 'string');
  Parser binaryToken() => ref1(token, 'binary');
  Parser uuidToken() => ref1(token, 'uuid');
  Parser dateToken() => ref1(token, 'date');
  Parser durationToken() => ref1(token, 'duration');

  // ContainerType tokens
  Parser mapToken() => ref1(token, 'map');
  Parser setTypeToken() => ref1(token, 'set');
  Parser listToken() => ref1(token, 'list');
  Parser streamToken() => ref1(token, 'stream');

  // Helper function to create a token parser
  Parser token(Object input) => switch (input) {
    Parser() => input.token().trim(),
    String() => token(input.toParser()),
    _ => throw ArgumentError.value(input, 'Invalid token parser'),
  };
}
