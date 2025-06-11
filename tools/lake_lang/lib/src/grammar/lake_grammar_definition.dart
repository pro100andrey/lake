import 'package:petitparser/petitparser.dart';

/// Defines the grammar for the Lake language using the PetitParser library.
/// This class provides a structured way to parse Lake files by defining the
/// syntax and rules of the language. Each method corresponds to a grammar rule
/// as specified in the Lake language specification, enabling parsing of
/// documents, headers, definitions, and other language constructs.
///
/// The grammar follows a top-down approach, starting with the `document` rule
/// and breaking down into specific constructs like imports, namespaces,
/// structs, and constants. All parsers are designed to handle whitespace and
/// comments appropriately using the `token` helper method.
class LakeGrammarDefinition extends GrammarDefinition {
  /// Returns the starting parser for the Lake language, which parses an entire
  /// document and ensures no input remains.
  @override
  Parser start() => ref0(document).end();

  /// Document ::= Header* Definition*
  ///
  /// Parses a Lake document, consisting of zero or more headers followed by
  /// zero or more definitions.
  Parser document() => ref0(header).star() & ref0(definition).star();

  /// Header ::= Import | Namespace
  ///
  /// Parses a header, which can be either an import statement or a namespace
  /// declaration.
  Parser header() => ref0(import) | ref0(namespace);

  /// Import ::= 'import' Literal
  ///
  /// Parses an import statement, consisting of the keyword 'import' followed
  /// by a string literal.
  Parser import() => ref1(token, 'import') & ref0(literal);

  /// Namespace ::= ( 'namespace' ( NamespaceScope Identifier ) )
  ///
  /// Parses a namespace declaration, consisting of the keyword 'namespace'
  /// followed by a scope and an identifier.
  Parser namespace() =>
      ref1(token, 'namespace') & (ref0(namespaceScope) & ref0(identifier));

  /// NamespaceScope ::= '*' | 'js' | 'dart'
  ///
  /// Parses a namespace scope, which can be '*' (all), 'js', or 'dart'.
  Parser namespaceScope() =>
      ref1(token, '*') | ref1(token, 'js') | ref1(token, 'dart');

  /// Definition ::= Const | Typedef | Enum | Struct | Exception | Service
  ///
  /// Parses a definition, which can be a constant, typedef, enum, struct,
  /// exception, or service.
  Parser definition() =>
      ref0(constDefinition) |
      ref0(typedefDefinition) |
      ref0(enumDefinition) |
      ref0(structDefinition) |
      ref0(exceptionDefinition) |
      ref0(serviceDefinition);

  /// Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
  ///
  /// Parses a constant definition, consisting of the keyword 'const', a field
  /// type, an identifier, an equals sign, a constant value, and an optional
  /// list separator.
  Parser constDefinition() =>
      ref1(token, 'const') &
      ref0(fieldType) &
      ref0(identifier) &
      ref1(token, '=') &
      ref0(constValue) &
      ref0(listSeparator).optional();

  /// Typedef ::= 'typedef' DefinitionType Identifier ListSeparator?
  ///
  /// Parses a typedef definition, consisting of the keyword 'typedef', a
  /// definition type, an identifier, and an optional list separator.
  Parser typedefDefinition() =>
      ref1(token, 'typedef') &
      ref0(definitionType) &
      ref0(identifier) &
      ref0(listSeparator).optional();

  /// Enum ::= 'enum' Identifier '{' EnumValue* '}'
  ///
  /// Parses an enum definition, consisting of the keyword 'enum', an
  /// identifier, and a brace-enclosed list of enum values.
  Parser enumDefinition() =>
      ref1(token, 'enum') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(enumValue).star() &
      ref1(token, '}');

  /// EnumValue ::= Identifier ('=' IntConstant)? ListSeparator?
  ///
  /// Parses an enum value, consisting of an identifier, an optional integer
  /// assignment, and an optional list separator.
  Parser enumValue() =>
      ref0(identifier) &
      (ref1(token, '=') & ref0(intConstant)).optional() &
      ref0(listSeparator).optional();

  /// Struct ::= 'struct' Identifier '{' Field* '}'
  ///
  /// Parses a struct definition, consisting of the keyword 'struct', an
  /// identifier, and a brace-enclosed list of fields.
  Parser structDefinition() =>
      ref1(token, 'struct') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(field).star() &
      ref1(token, '}');

  /// Exception ::= 'exception' Identifier '{' Field* '}'
  ///
  /// Parses an exception definition, consisting of the keyword 'exception', an
  /// identifier, and a brace-enclosed list of fields.
  Parser exceptionDefinition() =>
      ref1(token, 'exception') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(field).star() &
      ref1(token, '}');

  /// Service ::= 'service' Identifier ( 'extends' Identifier )?
  /// '{' Function* '}'
  ///
  /// Parses a service definition, consisting of the keyword 'service', an
  /// identifier, an optional 'extends' clause, and a brace-enclosed list of
  /// functions.
  Parser serviceDefinition() =>
      ref1(token, 'service') &
      ref0(identifier) &
      (ref1(token, 'extends') & ref0(identifier)).optional() &
      ref1(token, '{') &
      ref0(function).star() &
      ref1(token, '}');

  /// Field ::= FieldID? FieldReq? FieldType Identifier ('=' ConstValue)?
  /// ListSeparator?
  ///
  /// Parses a field, consisting of an optional field ID, an optional
  /// requirement specifier, a field type, an identifier, an optional default
  /// value, and an optional list separator.
  Parser field() =>
      ref0(fieldID).optional() &
      ref0(fieldReq).optional() &
      ref0(fieldType) &
      ref0(identifier) &
      (ref1(token, '=') & ref0(constValue)).optional() &
      ref0(listSeparator).optional();

  /// FieldID ::= IntConstant ':'
  ///
  /// Parses a field ID, consisting of an integer constant followed by a colon.
  Parser fieldID() => ref0(intConstant) & ref1(token, ':');

  /// FieldReq ::= 'required' | 'optional'
  ///
  /// Parses a field requirement specifier, either 'required' or 'optional'.
  Parser fieldReq() => ref1(token, 'required') | ref1(token, 'optional');

  /// Function ::= FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
  ///
  /// Parses a function definition, consisting of a function type, an
  /// identifier, a parenthesized list of fields, an optional throws clause,
  /// and an optional list separator.
  Parser function() =>
      ref0(functionType) &
      ref0(identifier) &
      ref1(token, '(') &
      ref0(field).star() &
      ref1(token, ')') &
      ref0(throws).optional() &
      ref0(listSeparator).optional();

  /// FunctionType ::= FieldType | 'void'
  ///
  /// Parses a function return type, which can be a field type or 'void'.
  Parser functionType() => ref0(fieldType) | ref1(token, 'void');

  /// Throws ::= 'throws' '(' Field* ')'
  ///
  /// Parses a throws clause, consisting of the keyword 'throws' followed by a
  /// parenthesized list of fields.
  Parser throws() =>
      ref1(token, 'throws') &
      ref1(token, '(') &
      ref0(field).star() &
      ref1(token, ')');

  /// FieldType ::= StreamType | ContainerType | BaseType | Identifier
  ///
  /// Parses a field type, which can be a stream type, container type, base
  /// type, or an identifier (for custom types).
  Parser fieldType() =>
      ref0(streamType) |
      ref0(containerType) |
      ref0(baseType) |
      ref0(identifier);

  /// DefinitionType ::= ContainerType | BaseType
  ///
  /// Parses a definition type, which can be a container type or a base type.
  Parser definitionType() => ref0(containerType) | ref0(baseType);

  /// BaseType ::= 'bool' | 'byte' | 'i8' | 'i16' | 'i32' | 'i64' |
  /// 'double' | 'string' | 'binary' | 'uuid'
  ///
  /// Parses a base type, one of the predefined scalar types in the Lake
  /// language.
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

  /// ContainerType ::= MapType | SetType | ListType
  ///
  /// Parses a container type, which can be a map, set, or list type.
  Parser containerType() => ref0(mapType) | ref0(setType) | ref0(listType);

  /// MapType ::= 'map' '<' FieldType ',' FieldType '>'
  ///
  /// Parses a map type, consisting of the keyword 'map' followed by two field
  /// types (key and value) in angle brackets.
  Parser mapType() =>
      ref1(token, 'map') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, ',') &
      ref0(fieldType) &
      ref1(token, '>');

  /// SetType ::= 'set' '<' FieldType '>'
  ///
  /// Parses a set type, consisting of the keyword 'set' followed by a field
  /// type in angle brackets.
  Parser setType() =>
      ref1(token, 'set') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  /// ListType ::= 'list' '<' FieldType '>'
  ///
  /// Parses a list type, consisting of the keyword 'list' followed by a field
  /// type in angle brackets.
  Parser listType() =>
      ref1(token, 'list') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  /// StreamType ::= 'stream' '<' FieldType '>'
  ///
  /// Parses a stream type, consisting of the keyword 'stream' followed by a
  /// field type in angle brackets.
  Parser streamType() =>
      ref1(token, 'stream') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  /// ConstValue ::= ConstList | ConstMap | DoubleConstant | IntConstant |
  /// BooleanConstant | EnumConstant | Literal | Identifier
  ///
  /// Parses a constant value, which can be a list, map, number, boolean,
  /// identifier, or string literal.
  Parser constValue() =>
      ref0(constList) |
      ref0(constMap) |
      ref0(intConstant) |
      ref0(doubleConstant) |
      ref0(boolConstant) |
      ref0(identifier) |
      ref0(literal);

  /// IntConstant ::= ('+' | '-')? Digit+
  ///
  /// Parses an integer constant, consisting of an optional sign and one or more
  /// digits, ensuring no decimal or exponent is present.
  Parser intConstant() {
    final sign = (char('+') | char('-')).optional();
    final integerPart = sign & digit().plus();

    final noDecimalOrExponent = (char('.') | char('E') | char('e')).not();
    final combined = integerPart & noDecimalOrExponent;

    return ref1(
      token,
      combined.flatten(),
    );
  }

  /// DoubleConstant ::= ('+' | '-')? ( Digit* '.' Digit+ ( ('E' | 'e')
  /// ('+' | '-')? Digit+ )? | Digit+ ( ('E' | 'e') ('+' | '-')? Digit+ )? )
  ///
  /// Parses a double constant, consisting of an optional sign, a decimal number
  /// or an integer with an exponent.
  Parser doubleConstant() {
    final sign = (char('+') | char('-')).optional();
    final exponent = (char('E') | char('e')) & (sign & digit().plus());

    final decimalPart = digit().star() & char('.') & digit().plus();
    final integerWithDecimal = decimalPart & exponent.optional();
    final integerWithExponent = digit().plus() & exponent;

    final numberBody = integerWithDecimal | integerWithExponent;

    final combinedParts = (sign & numberBody).flatten();

    return ref1(token, combinedParts);
  }

  /// BooleanConstant ::= 'true' | 'false'
  ///
  /// Parses a boolean constant, either 'true' or 'false'.
  Parser boolConstant() => ref1(token, 'true') | ref1(token, 'false');

  /// ConstList ::= '[' (ConstValue ListSeparator?)* ']'
  ///
  /// Parses a constant list, consisting of square-bracketed constant values
  /// with optional separators.
  Parser constList() =>
      ref1(token, '[') &
      (ref0(constValue) & ref0(listSeparator).optional()).star() &
      ref1(token, ']');

  /// ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
  ///
  /// Parses a constant map, consisting of brace-enclosed key-value pairs with
  /// optional separators.
  Parser constMap() =>
      ref1(token, '{') &
      (ref0(constValue) &
              ref1(token, ':') &
              ref0(constValue) &
              ref0(listSeparator).optional())
          .star() &
      ref1(token, '}');

  /// Literal ::= ('"' [^"]* '"') | ("'" [^']* "'")
  ///
  /// Parses a string literal, enclosed in either single or double quotes.
  Parser literal() => ref1(
    token,
    (char('"') & pattern('^"').star() & char('"') |
            char("'") & pattern("^'").star() & char("'"))
        .flatten(),
  );

  /// Identifier ::= ( Letter | '_' ) ( ( Letter | Digit | '_' )*
  /// ( '.' ( Letter | Digit | '_' )+ )* )
  ///
  /// Parses an identifier, starting with a letter or underscore, followed by
  /// letters, digits, underscores, or dot-separated segments.
  Parser identifier() => ref1(
    token,
    ((ref0(letter) | char('_')).flatten() &
            ((ref0(letter) | ref0(digit) | char('_')).star() &
                    (char('.') &
                            (ref0(letter) | ref0(digit) | char('_')).plus())
                        .star())
                .flatten())
        .flatten(),
  );

  /// ListSeparator ::= ',' | ';'
  ///
  /// Parses a list separator, either a comma or semicolon.
  Parser listSeparator() => ref1(token, ',') | ref1(token, ';');

  /// Parses one or more hidden whitespace characters or comments, used to
  /// ignore irrelevant content during tokenization.
  Parser hiddenWhitespace() => ref0(hiddenStuffWhitespace).plus();

  /// HiddenStuffWhitespace ::= VisibleWhitespace | Comment
  ///
  /// Parses hidden content, either visible whitespace or a comment.
  Parser hiddenStuffWhitespace() => ref0(visibleWhitespace) | ref0(comment);

  /// Comment ::= SingleLineComment | MultiLineComment
  ///
  /// Parses a comment, either single-line or multi-line.
  Parser comment() => ref0(singleLineComment) | ref0(multiLineComment);

  /// SingleLineComment ::= '//' [^\n]* [\n]?
  ///
  /// Parses a single-line comment, starting with '//' and ending at the newline
  /// (if any)
  Parser singleLineComment() =>
      (string('//') & ref0(newline).neg().star() & ref0(newline).optional())
          .flatten();

  /// MultiLineComment ::= '/*' ( MultiLineComment | [^*] )* '*/'
  ///
  /// Parses a multi-line comment, enclosed in '/*' with and '*/', allowing
  /// nested comments.
  Parser multiLineComment() =>
      (string('/*') &
              (ref0(multiLineComment) | string('*/').neg()).star() &
              string('*/'))
          .flatten();

  /// VisibleWhitespace ::= ' ' | '\t' | '\n' | '\r' | '\f'
  ///
  /// Parses visible whitespace characters (space, tab, newline, etc.).
  Parser visibleWhitespace() => whitespace();

  /// Creates a token parser for the given input, trimming whitespace and
  /// comments.
  ///
  /// - Args:
  ///   input: The input parser or string to tokenize.
  /// - Returns:
  ///   A parser that produces a token with trimmed whitespace and comments.
  /// - Throws:
  ///   ArgumentError: If the input is neither a parser nor a string.
  Parser token(Object input) => switch (input) {
    Parser() => input.token().trim(ref0(hiddenStuffWhitespace)),
    String() => token(input.toParser()),
    _ => throw ArgumentError.value(input, 'Invalid token parser'),
  };
}
