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
[21] BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' | 'double' | 'string' | 'binary' | 'uuid' | 'date' | 'duration'
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

import '../lake_lang.dart';

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
  Parser import() {
    final parser = ref1(token, 'import') & ref0(literal);

    return parser.map((t) {
      final stringLiteral = t[1] as StringLiteral;

      return Import(stringLiteral.value);
    });
  }

  // [4] Namespace ::= ( 'namespace' ( NamespaceScope Identifier ) )
  Parser namespace() {
    final parser =
        ref1(token, 'namespace') & (ref0(namespaceScope) & ref0(identifier));

    return parser.map((t) {
      final [_, [Token scope, Identifier identifier]] = t;
      
      return Namespace(scope.value, identifier);
    });
  }

  // [5] NamespaceScope ::= '*' | 'js' | 'dart'
  Parser namespaceScope() =>
      ref1(token, '*') | ref1(token, 'js') | ref1(token, 'dart');

  // [6] Definition ::= Const | Typedef | Enum | Struct | Exception | Service
  Parser definition() =>
      ref0(constDefinition) |
      ref0(typedefDefinition) |
      ref0(enumDefinition) |
      ref0(structDefinition) |
      ref0(exceptionDefinition) |
      ref0(serviceDefinition).map((value) => value);

  // [7] Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
  Parser constDefinition() =>
      ref1(token, 'const') &
      ref0(fieldType) &
      ref0(identifier) &
      ref1(token, '=') &
      ref0(constValue) &
      ref0(listSeparator).optional();

  // [8] Typedef ::= 'typedef' DefinitionType Identifier
  Parser typedefDefinition() =>
      ref1(token, 'typedef') & ref0(definitionType) & ref0(identifier);

  // [9] Enum ::= 'enum' Identifier '{' (Identifier ('=' IntConstant)? ListSeparator?)* '}'
  Parser enumDefinition() =>
      ref1(token, 'enum') &
      ref0(identifier) &
      ref1(token, '{') &
      (ref0(identifier) &
              (ref1(token, '=') & ref0(intConstant)).optional() &
              ref0(listSeparator).optional())
          .star() &
      ref1(token, '}');

  // [10] Struct ::= 'struct' Identifier '{' Field* '}'
  Parser structDefinition() =>
      ref1(token, 'struct') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(field).star() &
      ref1(token, '}');

  // [11] Exception ::= 'exception' Identifier '{' Field* '}'
  Parser exceptionDefinition() =>
      ref1(token, 'exception') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(field).star() &
      ref1(token, '}');

  // [12] Service ::= 'service' Identifier ( 'extends' Identifier )? '{' Function* '}'
  Parser serviceDefinition() =>
      ref1(token, 'service') &
      ref0(identifier) &
      (ref1(token, 'extends') & ref0(identifier)).optional() &
      ref1(token, '{') &
      ref0(function).star() &
      ref1(token, '}');

  // [13] Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)? ListSeparator?
  Parser field() =>
      ref0(fieldID).optional() &
      ref0(fieldReq).optional() &
      ref0(fieldType) &
      ref0(identifier) &
      (ref1(token, '=') & ref0(constValue)).optional() &
      ref0(listSeparator).optional();

  // [14] FieldID ::= IntConstant ':'
  Parser fieldID() => ref0(intConstant) & ref1(token, ':');

  // [15] FieldReq ::= 'required' | 'optional'
  Parser fieldReq() => ref1(token, 'required') | ref1(token, 'optional');

  // [16] Function ::= FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
  Parser function() =>
      ref0(functionType) &
      ref0(identifier) &
      ref1(token, '(') &
      ref0(field).star() &
      ref1(token, ')') &
      ref0(throws).optional() &
      ref0(listSeparator).optional();

  // [17] FunctionType ::= FieldType | 'void'
  Parser functionType() => ref0(fieldType) | ref1(token, 'void');

  // [18] Throws ::= 'throws' '(' Field* ')'
  Parser throws() =>
      ref1(token, 'throws') &
      ref1(token, '(') &
      ref0(field).star() &
      ref1(token, ')');

  // [19] FieldType ::= Identifier | BaseType | ContainerType
  Parser fieldType() => ref0(identifier) | ref0(baseType) | ref0(containerType);

  // [20] DefinitionType ::= BaseType | ContainerType
  Parser definitionType() => ref0(baseType) | ref0(containerType);

  // [21] BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' | 'double' | 'string' | 'binary' | 'uuid' | 'date' | 'duration'
  Parser baseType() =>
      ref1(token, 'bool') |
      ref1(token, 'byte') |
      ref1(token, 'i8') |
      ref1(token, 'i16') |
      ref1(token, 'i32') |
      ref1(token, 'i64') |
      ref1(token, 'double') |
      ref1(token, 'string') |
      ref1(token, 'binary') |
      ref1(token, 'uuid') |
      ref1(token, 'date') |
      ref1(token, 'duration');

  // [22] ContainerType ::= MapType | SetType | ListType | StreamType
  Parser containerType() =>
      ref0(mapType) | ref0(setType) | ref0(listType) | ref0(streamType);

  // [23] MapType ::= 'map' '<' FieldType ',' FieldType '>'
  Parser mapType() =>
      ref1(token, 'map') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, ',') &
      ref0(fieldType) &
      ref1(token, '>');

  // [24] SetType ::= 'set' '<' FieldType '>'
  Parser setType() =>
      ref1(token, 'set') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  // [25] ListType ::= 'list' '<' FieldType '>'
  Parser listType() =>
      ref1(token, 'list') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  // [26] StreamType ::= 'stream' '<' FieldType '>'
  Parser streamType() =>
      ref1(token, 'stream') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

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
      ((char('+') | char('-')).optional() &
              ref0(digit).star() &
              (char('.') & ref0(digit).plus()) &
              ((char('E') | char('e')) & ref0(intConstant)).optional())
          .flatten();

  // [28] ConstList ::= '[' (ConstValue ListSeparator?)* ']'
  Parser constList() =>
      ref1(token, '[') &
      (ref0(constValue) & ref0(listSeparator).optional()).star() &
      ref1(token, ']');

  // [29] ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
  Parser constMap() =>
      ref1(token, '{') &
      (ref0(constValue) &
              ref1(token, ':') &
              ref0(constValue) &
              ref0(listSeparator).optional())
          .star() &
      ref1(token, '}');

  // [30] Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
  Parser literal() {
    final parser = ref1(
      token,
      (char('"') & pattern('^"').star() & char('"') |
              char("'") & pattern("^'").star() & char("'"))
          .flatten(),
    );

    return parser.map((t) {
      final value = (t as Token<dynamic>).value;
      final strValue = value as String;
      final trimmed = strValue.substring(1, strValue.length - 1);
      return StringLiteral(trimmed);
    });
  }

  // [31] Identifier ::= ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*
  Parser identifier() {
    final parser = ref1(
      token,
      ((ref0(letter) | char('_')).flatten() &
              (ref0(letter) | ref0(digit) | char('.') | char('_')).star())
          .flatten(),
    );

    return parser.map((t) => Identifier((t as Token<dynamic>).value));
  }

  // [32] ListSeparator ::= ',' | ';'
  Parser listSeparator() => ref1(token, ',') | ref1(token, ';');

  Parser hiddenWhitespace() => ref0(hiddenStuffWhitespace).plus();

  Parser hiddenStuffWhitespace() =>
      ref0(visibleWhitespace) |
      ref0(singleLineComment) |
      ref0(multiLineComment);

  Parser singleLineComment() =>
      string('//') & ref0(newline).neg().star() & ref0(newline).optional();

  Parser multiLineComment() =>
      string('/*') &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string('*/');

  Parser visibleWhitespace() => whitespace();

  // Helper function to create a token parser
  Parser token(Object input) => switch (input) {
    Parser() => input.token().trim(ref0(hiddenStuffWhitespace)),
    String() => token(input.toParser()),
    _ => throw ArgumentError.value(input, 'Invalid token parser'),
  };
}
