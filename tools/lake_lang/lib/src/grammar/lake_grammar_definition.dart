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
  /// Creates a new instance of the Lake grammar definition.
  const LakeGrammarDefinition();

  /// Returns the starting parser for the Lake language, which parses an entire
  /// document and ensures no input remains.
  ///
  /// Example:
  /// ```
  /// import "my_lib";
  /// namespace js my_app;
  /// struct MyData {}
  /// ```
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
  ///
  /// Example:
  /// ```
  /// import "path/to/my_file";
  /// ```
  Parser import() => ref1(token, 'import') & ref0(literal);

  /// Namespace ::= 'namespace' NamespaceScope Identifier
  ///
  /// Parses a namespace declaration, consisting of the keyword 'namespace'
  /// followed by a scope and an identifier.
  ///
  /// Example:
  /// ```
  /// namespace js my_app;
  /// ```
  Parser namespace() =>
      ref1(token, 'namespace') & (ref0(namespaceScope) & ref0(identifier));

  /// NamespaceScope ::= '*' | 'js' | 'dart'
  ///
  /// Parses a namespace scope, which defines the target language for the
  /// namespace: '*' (all), 'js' (JavaScript), or 'dart'.
  Parser namespaceScope() =>
      ref1(token, '*') | ref1(token, 'js') | ref1(token, 'dart');

  /// Definition ::= Const | Typedef | Enum | Struct | Exception | Service
  ///
  /// Parses a definition, which can be a constant, typedef, enum, struct,
  /// union, exception, or service.
  Parser definition() =>
      ref0(constDefinition) |
      ref0(typedefDefinition) |
      ref0(enumDefinition) |
      ref0(structDefinition) |
      ref0(unionDefinition) |
      ref0(exceptionDefinition) |
      ref0(serviceDefinition);

  /// Const ::= 'const' FieldType Identifier '=' ConstValue ListSeparator?
  ///
  /// Parses a constant definition, consisting of the keyword 'const', a field
  /// type, an identifier, an equals sign, a constant value, and an optional
  /// list separator.
  ///
  /// Example:
  /// ```
  /// const string appName = "MyApplication";
  /// ```
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
  ///
  /// Example:
  /// ```
  /// typedef list<string> StringList;
  /// ```
  Parser typedefDefinition() =>
      ref1(token, 'typedef') &
      ref0(definitionType) &
      ref0(identifier) &
      ref0(listSeparator).optional();

  /// Enum ::= 'enum' Identifier '{' EnumValue* '}'
  ///
  /// Parses an enum definition, consisting of the keyword 'enum', an
  /// identifier, and a brace-enclosed list of enum values.
  ///
  /// Example:
  /// ```
  /// enum Status {
  ///   ACTIVE = 1,
  ///   INACTIVE,
  ///   PENDING = 3;
  /// }
  /// ```
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
  ///
  /// Example:
  /// ```
  /// ACTIVE = 1,
  /// ```
  /// or
  /// ```
  /// INACTIVE
  /// ```
  Parser enumValue() =>
      ref0(identifier) &
      (ref1(token, '=') & ref0(intConstant)).optional() &
      ref0(listSeparator).optional();

  /// Struct ::= 'struct' Identifier '{' Field* '}'
  ///
  /// Parses a struct definition, consisting of the keyword 'struct', an
  /// identifier, and a brace-enclosed list of fields.
  ///
  /// Example:
  /// ```
  /// struct User {
  ///   1: required string name;
  ///   2: optional i32 age = 30;
  /// }
  /// ```
  Parser structDefinition() =>
      ref1(token, 'struct') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(field).star() &
      ref1(token, '}');

  /// Union ::= 'union' Identifier '{' Field* '}'
  ///
  /// Parses a union definition, consisting of the keyword 'union', an
  /// identifier, and a brace-enclosed list of fields.
  ///
  /// Example:
  /// ```
  /// union UserData {
  ///   1: string name;
  ///   2: i32 age;
  /// }
  /// ```
  Parser unionDefinition() =>
      ref1(token, 'union') &
      ref0(identifier) &
      ref1(token, '{') &
      ref0(field).star() &
      ref1(token, '}');

  /// Exception ::= 'exception' Identifier '{' Field* '}'
  ///
  /// Parses an exception definition, consisting of the keyword 'exception', an
  /// identifier, and a brace-enclosed list of fields.
  ///
  /// Example:
  /// ```
  /// exception UserNotFoundException {
  ///   1: string message;
  /// }
  /// ```
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
  ///
  /// Example:
  /// ```lake
  /// service UserService extends BaseService {
  ///   string getUserById(1: i32 id) throws (1: UserNotFoundException);
  ///   void createUser(1: User newUser);
  /// }
  /// ```
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
  /// requirement specifier ('required' or 'optional'), a field type, an
  /// identifier, an optional default value, and an optional list separator.
  ///
  /// Example:
  /// ```
  /// 1: required string name;
  /// ```
  /// or
  /// ```
  /// optional i32 age = 30
  /// ```
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
  ///
  /// Example:
  /// ```
  /// 1:
  /// ```
  Parser fieldID() => ref0(intConstant) & ref1(token, ':');

  /// FieldReq ::= 'required' | 'optional'
  ///
  /// Parses a field requirement specifier, either 'required' or 'optional'.
  Parser fieldReq() => ref1(token, 'required') | ref1(token, 'optional');

  /// Function ::= FunctionType Identifier '(' Field* ')' Throws? ListSeparator?
  ///
  /// Parses a function definition, consisting of a function type, an
  /// identifier, a parenthesized list of fields (arguments), an optional
  /// throws clause, and an optional list separator.
  ///
  /// Example:
  /// ```
  /// string getUserById(1: i32 id) throws (1: UserNotFoundException);
  /// ```
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
  /// Parses a function return type, which can be any field type or 'void'.
  Parser functionType() => ref0(fieldType) | ref1(token, 'void');

  /// Throws ::= 'throws' '(' Field* ')'
  ///
  /// Parses a throws clause, consisting of the keyword 'throws' followed by a
  /// parenthesized list of fields (exceptions).
  ///
  /// Example:
  /// ```
  /// throws (1: UserNotFoundException)
  /// ```
  Parser throws() =>
      ref1(token, 'throws') &
      ref1(token, '(') &
      ref0(field).star() &
      ref1(token, ')');

  /// FieldType ::= StreamType | ContainerType | BaseType | Identifier
  ///
  /// Parses a field type, which can be a stream type, container type, a base
  /// type, or an identifier (referencing a custom type like a struct or enum).
  Parser fieldType() =>
      ref0(streamType) |
      ref0(containerType) |
      ref0(baseType) |
      ref0(identifier);

  /// DefinitionType ::= ContainerType | BaseType
  ///
  /// Parses a type used in a `typedef` definition, which can be a container
  /// type or a base type. Custom types (identifiers) are not allowed here.
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
  ///
  /// Example:
  /// ```
  /// map<string, i32>
  /// ```
  Parser mapType() =>
      ref1(token, 'map') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, ',') &
      ref0(fieldType) &
      ref1(token, '>');

  /// SetType ::= 'set' '<' FieldType '>'
  ///
  /// Parses a set type, consisting of the keyword 'set' followed by a single
  /// field type in angle brackets.
  ///
  /// Example:
  /// ```
  /// set<string>
  /// ```
  Parser setType() =>
      ref1(token, 'set') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  /// ListType ::= 'list' '<' FieldType '>'
  ///
  /// Parses a list type, consisting of the keyword 'list' followed by a single
  /// field type in angle brackets.
  ///
  /// Example:
  /// ```
  /// list<i32>
  /// ```
  Parser listType() =>
      ref1(token, 'list') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  /// StreamType ::= 'stream' '<' FieldType '>'
  ///
  /// Parses a stream type, consisting of the keyword 'stream' followed by a
  /// field type in angle brackets.
  ///
  /// Example:
  /// ```
  /// stream<string>
  /// ```
  Parser streamType() =>
      ref1(token, 'stream') &
      ref1(token, '<') &
      ref0(fieldType) &
      ref1(token, '>');

  /// ConstValue ::= ConstList | ConstMap | DoubleConstant | IntConstant |
  /// BooleanConstant | Identifier | Literal
  ///
  /// Parses a constant value, which can be a list, map, double, integer,
  /// boolean, identifier (referencing another const), or string literal.
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
  /// digits, ensuring no decimal point or exponent is present.
  ///
  /// Example: `123`, `-45`, `+9`
  Parser intConstant() {
    final sign = (char('+') | char('-')).optional();
    final integerPart = sign & digit().plus();

    final noDecimalOrExponent = (char('.') | char('E') | char('e')).not();
    // The .not() combined with the integerPart ensures that it matches only
    // integers without decimal points or exponents.
    final combined = integerPart & noDecimalOrExponent;

    return ref1(
      token,
      combined.flatten(),
    );
  }

  /// DoubleConstant ::= ('+' | '-')? ( Digit* '.' Digit+ ( ('E' | 'e')
  /// ('+' | '-')? Digit+ )? | Digit+ ( ('E' | 'e') ('+' | '-')? Digit+ )? )
  ///
  /// Parses a double constant, consisting of an optional sign, a decimal
  /// number, or an integer with an exponent.
  ///
  /// Example: `3.14`, `-0.5`, `1e-3`, `2.5E+2`
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
  ///
  /// Example: `[1, 2, 3]` or `["a"; "b";]`
  Parser constList() =>
      ref1(token, '[') &
      (ref0(constValue) & ref0(listSeparator).optional()).star() &
      ref1(token, ']');

  /// ConstMap ::= '{' (ConstValue ':' ConstValue ListSeparator?)* '}'
  ///
  /// Parses a constant map, consisting of brace-enclosed key-value pairs with
  /// optional separators.
  ///
  /// Example: `{"key1": "value1", "key2": 123}`
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
  ///
  /// Example: `"Hello, World!"` or `'Another string'`
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
  /// letters, digits, underscores, or dot-separated segments for qualified
  /// names.
  ///
  /// Example: `myVariable`, `_internalName`, `Namespace.Type`
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
  /// Parses a list separator, either a comma (`,`) or a semicolon (`;`).
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
  /// Parses a single-line comment, starting with '//' and extending to the
  /// end of the line (including the newline character if present).
  ///
  /// Example: `// This is a single-line comment`
  Parser singleLineComment() =>
      (string('//') & ref0(newline).neg().star() & ref0(newline).optional())
          .flatten();

  /// MultiLineComment ::= '/*' ( MultiLineComment | [^*] )* '*/'
  ///
  /// Parses a multi-line comment, enclosed in '/*' and '*/', allowing for
  /// nested comments.
  ///
  /// Example:
  /// ```
  /// /* This is a
  ///    multi-line comment.
  ///    /* Nested comment */
  /// */
  /// ```
  Parser multiLineComment() =>
      (string('/*') &
              (ref0(multiLineComment) | string('*/').neg()).star() &
              string('*/'))
          .flatten();

  /// VisibleWhitespace ::= ' ' | '\t' | '\n' | '\r' | '\f'
  ///
  /// Parses visible whitespace characters (space, tab, newline, carriage
  /// return, form feed).
  Parser visibleWhitespace() => whitespace();

  /// Creates a token parser for the given input, trimming whitespace and
  /// comments around it.
  ///
  /// This helper method simplifies grammar definitions by automatically
  /// handling the skipping of `hiddenStuffWhitespace` (whitespace and comments)
  /// before and after the actual token.
  ///
  /// - Args:
  ///   input: The raw parser or string literal to be tokenized.
  /// - Returns:
  ///   A parser that produces a token with trimmed whitespace and comments.
  /// - Throws:
  ///   ArgumentError: If the input is neither a Parser nor a String.
  Parser token(Object input) => switch (input) {
    Parser() => input.token().trim(ref0(hiddenStuffWhitespace)),
    String() => token(input.toParser()),
    _ => throw ArgumentError.value(input, 'Invalid token parser'),
  };
}
