import 'package:petitparser/petitparser.dart';

/// Defines the grammar for the lake language using the PetitParser library.
/// This approach helps in parsing the lake files by defining the structure and
/// rules of the language.
class LakeGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(document).end();

  // [1] Document ::=  Header* Definition*
  Parser document() => ref0(header).star() & ref0(definition).star();

  // [2] Header ::= Import | Namespace
  Parser header() => ref0(import) | ref0(namespace);

  // [3] Import ::=  'import' Literal
  Parser import() => ref1(token, 'import') & ref0(literal);

  // [4] Namespace ::= ( 'namespace' ( NamespaceScope Identifier ) )
  Parser namespace() =>
      ref1(token, 'namespace') & (ref0(namespaceScope) & ref0(identifier));

  // [5] NamespaceScope ::=  '*' | 'js' | 'dart'
  Parser namespaceScope() =>
      ref1(token, '*') | ref1(token, 'js') | ref1(token, 'dart');

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
      ref1(token, 'const') &
      ref0(fieldType) &
      ref0(identifier) &
      ref1(token, '=') &
      ref0(constValue) &
      ref0(listSeparator).optional();

  // [8] Typedef ::= 'typedef' DefinitionType Identifier ListSeparator?
  Parser typedefDefinition() =>
      ref1(token, 'typedef') &
      ref0(definitionType) &
      ref0(identifier) &
      ref0(listSeparator).optional();

  // [9] Enum ::= 'enum' Identifier '{' EnumValue* '}'
  Parser enumDefinition() =>
      ref1(token, 'enum') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(enumValue).star() &
      ref1(token, '}');

  // [9.1] EnumValue ::= Identifier ('=' IntConstant)? ListSeparator?
  Parser enumValue() =>
      ref0(identifier) &
      (ref1(token, '=') & ref0(intConstant)).optional() &
      ref0(listSeparator).optional();

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

  // [12] Service ::= 'service' Identifier ( 'extends' Identifier )?
  // '{' Function* '}'
  Parser serviceDefinition() =>
      ref1(token, 'service') &
      ref0(identifier) &
      (ref1(token, 'extends') & ref0(identifier)).optional() &
      ref1(token, '{') &
      ref0(function).star() &
      ref1(token, '}');

  // [13] Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)?
  // ListSeparator?
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

  // [16] Function ::= FunctionType Identifier
  // '(' StreamType identifier | Field* ')' Throws? ListSeparator?
  Parser function() =>
      ref0(functionType) &
      ref0(identifier) &
      ref1(token, '(') &
      (ref0(streamType) & ref0(identifier) | ref0(field).star()) &
      ref1(token, ')') &
      ref0(throws).optional() &
      ref0(listSeparator).optional();

  // [17] FunctionType ::= StreamType | FieldType | 'void'
  Parser functionType() =>
      ref0(streamType) | ref0(fieldType) | ref1(token, 'void');

  // [18] Throws ::= 'throws' '(' Field* ')'
  Parser throws() =>
      ref1(token, 'throws') &
      ref1(token, '(') &
      ref0(field).star() &
      ref1(token, ')');

  // [19] FieldType ::= ContainerType | BaseType | Identifier
  Parser fieldType() => ref0(containerType) | ref0(baseType) | ref0(identifier);

  // [20] DefinitionType ::= ContainerType | BaseType
  Parser definitionType() => ref0(containerType) | ref0(baseType);

  // [21] BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' |
  // 'double' | 'string' | 'binary' | 'uuid' |
  Parser baseType() => [
    'bool',
    'byte',
    'i8',
    'i16',
    'i32',
    'i64',
    'double',
    'string',
    'binary',
    'uuid',
  ].map((type) => ref1(token, type)).toChoiceParser();

  // [22] ContainerType ::= MapType | SetType | ListType
  Parser containerType() => ref0(mapType) | ref0(setType) | ref0(listType);

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

  // [27] ConstValue ::= ConstList | ConstMap | DoubleConstant | IntConstant |
  // EnumConstant | Literal | Identifier
  Parser constValue() =>
      ref0(constList) |
      ref0(constMap) |
      ref0(doubleConstant) |
      ref0(intConstant) |
      ref0(identifier) |
      ref0(literal);

  // [28] IntConstant ::= ('+' | '-')? Digit+
  Parser intConstant() => ref1(
    token,
    ((char('+') | char('-')).optional() & ref0(digit).plus()).flatten(),
  );

  // [29] DoubleConstant ::= ('+' | '-')?
  // (Digit* '.' Digit+ ( ('E' | 'e') IntConstant )? |
  // Digit+ ( ('E' | 'e') IntConstant ) )
  Parser doubleConstant() {
    final sign = (char('+') | char('-')).optional();
    final exponent = (char('E') | char('e')) & ref0(intConstant);

    return ref1(
      token,
      (sign &
              ((ref0(digit).star() &
                      char('.') &
                      ref0(digit).plus() &
                      exponent.optional()) |
                  (ref0(digit).plus() & exponent)))
          .flatten(),
    );
  }

  // [30] ConstList ::= '[' (ConstValue ListSeparator?)* ']'
  Parser constList() =>
      ref1(token, '[') &
      (ref0(constValue) & ref0(listSeparator).optional()).star() &
      ref1(token, ']');

  // [31] ConstMap ::=
  // '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
  Parser constMap() =>
      ref1(token, '{') &
      (ref0(constValue) &
              ref1(token, ':') &
              ref0(constValue) &
              ref0(listSeparator).optional())
          .star() &
      ref1(token, '}');

  // [32] Literal ::=
  // ('"' [^"]* '"') | ("'" [^']* "'")
  Parser literal() => ref1(
    token,
    (char('"') & pattern('^"').star() & char('"') |
            char("'") & pattern("^'").star() & char("'"))
        .flatten(),
  );

  // [33] Identifier ::=
  // ( Letter | '_' ) ( Letter | Digit | '.' | '_' )*
  Parser identifier() => ref1(
    token,
    ((ref0(letter) | char('_')).flatten() &
            (ref0(letter) | ref0(digit) | char('.') | char('_')).star())
        .flatten(),
  );

  // [34] ListSeparator ::=
  // ',' | ';'
  Parser listSeparator() => ref1(token, ',') | ref1(token, ';');

  Parser hiddenWhitespace() => ref0(hiddenStuffWhitespace).plus();

  Parser hiddenStuffWhitespace() =>
      ref0(visibleWhitespace) |
      ref0(singleLineComment) |
      ref0(multiLineComment);

  Parser comment() =>
      (ref0(singleLineComment) | ref0(multiLineComment)).flatten();

  Parser singleLineComment() =>
      string('//') & ref0(newline).neg().star() & ref0(newline).optional();

  Parser multiLineComment() =>
      string('/*') &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string('*/');

  Parser docComment() =>
      string('///') & ref0(newline).neg().star() & ref0(newline).optional();

  Parser visibleWhitespace() => whitespace();

  // Helper function to create a token parser
  Parser token(Object input) => switch (input) {
    Parser() => input.token().trim(ref0(hiddenStuffWhitespace)),
    String() => token(input.toParser()),
    _ => throw ArgumentError.value(input, 'Invalid token parser'),
  };
}
