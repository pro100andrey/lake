import 'package:petitparser/petitparser.dart';

import '../grammar/lake_grammar_definition.dart';
import 'base/types.dart';
import 'nodes/ast_nodes.dart';

/// Defines the grammar for the Lake language with a focus on building an
/// Abstract Syntax Tree (AST).
///
/// This class extends `LakeGrammarDefinition` and overrides its parsing
/// methods. Instead of returning raw tokens or lists of parsed elements,
/// each overridden method maps the parser results to specific AST nodes
/// defined in `ast_nodes.dart`. This transformation is crucial for
/// semantic analysis, code generation, and other language processing tasks.
///
/// It also calculates and attaches `span` information to each AST node,
/// providing precise location data within the source file for error reporting
/// and tooling.
class LakeAstGrammarDefinition extends LakeGrammarDefinition {
  /// Creates a new [LakeAstGrammarDefinition] instance.
  const LakeAstGrammarDefinition();

  /// Calculates the [Span] for an AST node based on its starting
  /// and ending elements.
  ///
  /// This method is a crucial helper for constructing AST nodes with correct
  /// source location information. It can derive the span from either
  /// [Token] objects (representing raw lexemes) or existing [AstNode]s
  /// (for composite nodes).
  ///
  /// - Parameters:
  ///   - `startElement`: The element (either a [Token] or an [AstNode])
  ///     that marks the beginning of the AST node's span.
  ///   - `endElement`: The element (either a [Token] or an [AstNode])
  ///     that marks the end of the AST node's span.
  ///
  /// - Returns:
  ///   A [Span] object representing the range in the source file.
  ///
  /// - Throws:
  ///   [ArgumentError] if `startElement` or `endElement` is not a
  ///   supported type ([Token] or [AstNode]).
  Span _getSpan(Object startElement, Object endElement) {
    final start = switch (startElement) {
      Token(:final start) => start,
      AstNode(span: Span(:final start)) => start,
      _ => throw ArgumentError(
        'Invalid start element for span: $startElement',
      ),
    };

    final end = switch (endElement) {
      Token(:final stop) => stop,
      AstNode(span: Span(:final end)) => end,
      _ => throw ArgumentError('Invalid end element for span: $endElement'),
    };

    return (start: start, end: end);
  }

  // Overrides the [document] parser to return a [DocumentNode].
  ///
  /// This parser processes the top-level structure of a Lake file, converting
  /// lists of headers and definitions into their respective AST nodes and
  /// wrapping them in a [DocumentNode].
  @override
  Parser<DocumentNode> document() => super.document().map((t) {
    final [List headers, List definitions] = t as List;

    final resultHeaders = headers.cast<HeaderNode>();
    final resultDefinitions = definitions.cast<DefinitionNode>();
    final allNodes = [...resultHeaders, ...resultDefinitions];

    final span = allNodes.isNotEmpty
        ? _getSpan(allNodes.first, allNodes.last)
        : (start: 0, end: 0);

    return DocumentNode(
      headers: resultHeaders,
      definitions: resultDefinitions,
      span: span,
    );
  });

  /// Overrides the [import] parser to return an [ImportNode].
  ///
  /// It extracts the 'import' keyword and the literal path, then constructs
  /// an [ImportNode] with the appropriate source span.
  @override
  Parser import() => super.import().map((t) {
    final [
      Token keyword,
      LiteralNode literal,
      Token? listSeparator,
    ] = t as List;

    final span = _getSpan(keyword, literal);

    return ImportNode(path: literal, span: span);
  });

  /// Overrides the [namespace] parser to return a [NamespaceNode].
  ///
  /// It captures the 'namespace' keyword, the scope and the
  /// identifier, creating a [NamespaceNode].
  @override
  Parser namespace() => super.namespace().map((t) {
    final [
      Token keyword,
      IdentifierNode lang,
      IdentifierNode identifier,
      Token? listSeparator,
    ] = t as List;

    final span = _getSpan(keyword, identifier);

    return NamespaceNode(scope: lang, identifier: identifier, span: span);
  });

  /// Overrides the [namespaceScope] parser to return a [LiteralNode].
  ///
  /// Converts the raw token representing the namespace scope
  /// ('*', 'js', 'dart') into a [LiteralNode] for consistency within the AST.
  @override
  Parser namespaceScope() => super.namespaceScope().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return IdentifierNode(value: token.value, span: span);
  });

  /// Overrides the [constDefinition] parser to return a [ConstDefinitionNode].
  ///
  /// It parses the 'const' keyword, type, identifier, '=' sign, and constant
  /// value to form a [ConstDefinitionNode].
  @override
  Parser constDefinition() => super.constDefinition().map((t) {
    final [
      Token keyword,
      TypeNode type,
      IdentifierNode identifier,
      Token eq,
      ConstValueNode value,
      Token? listSeparator,
    ] = t as List;

    final span = _getSpan(keyword, listSeparator ?? value);

    return ConstDefinitionNode(
      identifier: identifier,
      type: type,
      value: value,
      span: span,
    );
  });

  /// Overrides the [typedefDefinition] parser to return a
  /// [TypedefDefinitionNode].
  ///
  /// Captures the 'typedef' keyword, the defined type, and the new identifier
  /// to create a [TypedefDefinitionNode].
  @override
  Parser typedefDefinition() => super.typedefDefinition().map((t) {
    final [
      Token keyword,
      TypeNode type,
      IdentifierNode identifier,
      Token? listSeparator,
    ] = t as List;

    final span = _getSpan(keyword, listSeparator ?? identifier);

    return TypedefDefinitionNode(
      identifier: identifier,
      type: type,
      span: span,
    );
  });

  /// Overrides the [enumDefinition] parser to return an [EnumDefinitionNode].
  ///
  /// It processes the 'enum' keyword, identifier, and a list of enum values,
  /// collecting them into an [EnumDefinitionNode].
  @override
  Parser enumDefinition() => super.enumDefinition().map((t) {
    final [
      Token keyword,
      IdentifierNode identifier,
      Token ld,
      List values,
      Token rd,
    ] = t as List;

    final span = _getSpan(keyword, rd);
    final enumValues = values.cast<EnumValueNode>();

    return EnumDefinitionNode(
      identifier: identifier,
      members: enumValues,
      span: span,
    );
  });

  /// Overrides the [enumValue] parser to return an [EnumValueNode].
  ///
  /// Handles enum members, which can be just an identifier or an identifier
  /// with an assigned integer constant.
  @override
  Parser enumValue() => super.enumValue().map((t) {
    final [
      IdentifierNode identifier,
      List? v,
      Token? separator,
    ] = t as List;

    final value = switch (v) {
      [_, final IntConstantNode value] => value,
      null => null,
      _ => throw StateError('Unexpected enum value list: $v'),
    };

    final span = _getSpan(identifier, separator ?? value ?? identifier);

    return EnumValueNode(
      identifier: identifier,
      value: value,
      span: span,
    );
  });

  /// Overrides the [structDefinition] parser to return a
  /// [StructDefinitionNode].
  ///
  /// It parses the 'struct' keyword, identifier, and collects all defined
  /// fields into a [StructDefinitionNode]
  @override
  Parser structDefinition() => super.structDefinition().map((t) {
    final [
      Token keyword,
      IdentifierNode identifier,
      Token ld,
      List fields,
      Token rd,
    ] = t as List;

    final span = _getSpan(keyword, rd);

    final fieldNodes = fields.cast<FieldNode>();

    return StructDefinitionNode(
      identifier: identifier,
      fields: fieldNodes,
      span: span,
    );
  });

  /// Overrides the [unionDefinition] parser to return an
  /// [UnionDefinitionNode].
  ///
  /// Similar to struct definitions, it parses the 'union' keyword,
  /// identifier, and its fields to form an [UnionDefinitionNode].
  @override
  Parser unionDefinition() => super.unionDefinition().map((t) {
    final [
      Token keyword,
      IdentifierNode identifier,
      Token ld,
      List fields,
      Token rd,
    ] = t as List;

    final span = _getSpan(keyword, rd);

    final fieldNodes = fields.cast<FieldNode>();

    return UnionDefinitionNode(
      identifier: identifier,
      fields: fieldNodes,
      span: span,
    );
  });

  /// Overrides the [exceptionDefinition] parser to return an
  /// [ExceptionDefinitionNode].
  ///
  /// Similar to struct definitions, it parses the 'exception' keyword,
  /// identifier, and its fields to form an [ExceptionDefinitionNode].
  @override
  Parser exceptionDefinition() => super.exceptionDefinition().map((t) {
    final [
      Token keyword,
      IdentifierNode identifier,
      Token ld,
      List fields,
      Token rd,
    ] = t as List;

    final span = _getSpan(keyword, rd);

    final fieldNodes = fields.cast<FieldNode>();

    return ExceptionDefinitionNode(
      identifier: identifier,
      fields: fieldNodes,
      span: span,
    );
  });

  /// Overrides the [field] parser to return a [FieldNode].
  ///
  /// This complex parser captures optional field ID, requirement, type,
  /// identifier, and an optional default value, consolidating them into
  /// a [FieldNode]. It includes logic to correctly identify the field's type
  /// as either a base type, container type, or custom (identifier) type.
  @override
  Parser field() => super.field().map((t) {
    final [
      List? fieldIdentifier,
      FieldRequirementNode? requirement,
      AstNode type,
      IdentifierNode identifier,
      List? defaultValue,
      Token? separator,
    ] = t as List;

    final fieldId = switch (fieldIdentifier) {
      [final IntConstantNode index, _] => index,
      null => null,
      _ => throw StateError('Unexpected field index format: $fieldIdentifier'),
    };

    final defaultValueResult = switch (defaultValue) {
      null => null,
      [Token() /*equalOp*/, final ConstValueNode value] => switch (value) {
        final ConstValueNode constValue => constValue,
      },
      _ => throw StateError('Unexpected default value list: $defaultValue'),
    };

    final calculatedType = switch (type) {
      BaseTypeNode() => type,
      IdentifierNode() => CustomTypeNode(value: type.value, span: type.span),
      ContainerTypeNode() => type,
      StreamTypeNode() => type,

      _ => throw StateError('Unexpected type in field: $type'),
    };

    final span = _getSpan(
      fieldId ?? requirement ?? calculatedType,
      separator ?? defaultValueResult ?? identifier,
    );

    return FieldNode(
      fieldId: fieldId,
      requirement: requirement,
      type: calculatedType,
      identifier: identifier,
      defaultValue: defaultValueResult,
      span: span,
    );
  });

  /// Overrides the [fieldReq] parser to return a [FieldRequirementNode].
  ///
  /// Converts the 'required' or 'optional' token into a [FieldRequirementNode].
  @override
  Parser fieldReq() => super.fieldReq().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return FieldRequirementNode(value: token.value, span: span);
  });

  /// Overrides the [baseType] parser to return a [BaseTypeNode].
  ///
  /// Maps recognized base type tokens ('bool', 'byte', etc.) to
  /// [BaseTypeNode]s.
  @override
  Parser baseType() => super.baseType().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return BaseTypeNode(value: token.value, span: span);
  });

  /// Overrides the [mapType] parser to return a [MapTypeNode].
  ///
  /// Parses the 'map' keyword and its key/value type arguments, converting
  /// them into a [MapTypeNode]. It correctly handles cases where key/value
  /// types are either built-in or custom (identifiers).
  @override
  Parser mapType() => super.mapType().map((t) {
    final [
      Token keyword,
      Token ld,
      AstNode keyType,
      Token comma,
      AstNode valueType,
      Token rd,
    ] = t as List;

    final keyTypeNode = switch (keyType) {
      TypeNode() => keyType,
      IdentifierNode() => CustomTypeNode(
        value: keyType.value,
        span: keyType.span,
      ),
      _ => throw StateError('Unexpected key type in map: $keyType'),
    };

    final valueTypeNode = switch (valueType) {
      TypeNode() => valueType,
      IdentifierNode() => CustomTypeNode(
        value: valueType.value,
        span: valueType.span,
      ),
      _ => throw StateError('Unexpected value type in map: $valueType'),
    };

    final span = _getSpan(keyword, rd);

    return MapTypeNode(
      keyType: keyTypeNode,
      valueType: valueTypeNode,
      span: span,
    );
  });

  /// Overrides the [setType] parser to return a [SetTypeNode].
  ///
  /// Parses the 'set' keyword and its element type argument, converting
  /// it into a [SetTypeNode].
  @override
  Parser setType() => super.setType().map((t) {
    final [Token keyword, Token ld, AstNode type, Token rd] = t as List;

    final itemType = switch (type) {
      BaseTypeNode() => type,
      ContainerTypeNode() => type,
      IdentifierNode() => CustomTypeNode(value: type.value, span: type.span),
      _ => throw StateError('Unexpected type in set: $type'),
    };

    final span = _getSpan(keyword, rd);

    return SetTypeNode(elementType: itemType, span: span);
  });

  /// Overrides the [listType] parser to return a [ListTypeNode].
  ///
  /// Parses the 'list' keyword and its element type argument, converting
  /// it into a [ListTypeNode].
  @override
  Parser listType() => super.listType().map((t) {
    final [Token keyword, Token ld, AstNode type, Token rd] = t as List;

    final elementType = switch (type) {
      TypeNode() => type,
      IdentifierNode() => CustomTypeNode(value: type.value, span: type.span),

      _ => throw StateError('Unexpected type in list: $type'),
    };

    final span = _getSpan(keyword, rd);

    return ListTypeNode(elementType: elementType, span: span);
  });

  /// Overrides the [intConstant] parser to return an [IntConstantNode].
  ///
  /// Converts the raw token of an integer constant into an [IntConstantNode].
  @override
  Parser intConstant() => super.intConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return IntConstantNode(rawValue: token.value, span: span);
  });

  /// Overrides the [doubleConstant] parser to return a [DoubleConstantNode].
  ///
  /// Converts the raw token of a double constant into a [DoubleConstantNode].
  @override
  Parser doubleConstant() => super.doubleConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return DoubleConstantNode(rawValue: token.value, span: span);
  });

  /// Overrides the [boolConstant] parser to return a [BoolConstantNode].
  ///
  /// Converts the 'true' or 'false' token into a [BoolConstantNode].
  @override
  Parser boolConstant() => super.boolConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return BoolConstantNode(rawValue: token.value, span: span);
  });

  /// Overrides the [constList] parser to return a [ConstListNode].
  ///
  /// Processes a list of constant values enclosed in square brackets,
  /// converting them into a [ConstListNode].
  @override
  Parser constList() => super.constList().map((t) {
    final [Token ld, List<List> values, Token rd] = t as List;

    final span = _getSpan(ld, rd);

    final elements = values
        .map((e) => e.first as ConstValueNode)
        .toList(growable: false);

    return ConstListNode(elements: elements, span: span);
  });

  /// Overrides the [constMap] parser to return a [ConstMapNode].
  ///
  /// Processes a map of key-value constant pairs enclosed in curly braces,
  /// converting them into a [ConstMapNode].
  @override
  Parser constMap() => super.constMap().map((t) {
    final [Token ld, List<List> values, Token rd] = t as List;

    final span = _getSpan(ld, rd);

    final entries = values
        .map(
          (e) => (
            key: e[0] as ConstValueNode,
            value: e[2] as ConstValueNode,
          ),
        )
        .toList(growable: false);

    return ConstMapNode(entries: entries, span: span);
  });

  /// Overrides the [literal] parser to return a [LiteralNode].
  ///
  /// Converts string literals (single or double quoted) into a [LiteralNode].
  @override
  Parser literal() => super.literal().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return LiteralNode(rawValue: token.value, span: span);
  });

  /// Overrides the [identifier] parser to return an [IdentifierNode].
  ///
  /// Converts recognized identifiers into an [IdentifierNode].
  @override
  Parser identifier() => super.identifier().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return IdentifierNode(value: token.value, span: span);
  });

  /// Overrides the [serviceDefinition] parser to return a
  /// [ServiceDefinitionNode].
  ///
  /// Processes a service definition, including its optional 'extends' clause
  /// and list of methods, creating a [ServiceDefinitionNode].
  @override
  Parser serviceDefinition() => super.serviceDefinition().map((t) {
    final [
      Token keyword,
      IdentifierNode identifier,
      List? extendsClause,
      Token ld,
      List functions,
      Token rd,
    ] = t as List;

    final extendsService = switch (extendsClause) {
      null => null,
      [final Token _ /*extends*/, final IdentifierNode extendsName] =>
        extendsName,
      _ => throw StateError('Unexpected extends clause: $extendsClause'),
    };

    final span = _getSpan(keyword, rd);
    final methods = functions.cast<FunctionNode>();

    return ServiceDefinitionNode(
      identifier: identifier,
      extendsService: extendsService,
      methods: methods,
      span: span,
    );
  });

  /// Overrides the [function] parser to return a [FunctionNode].
  ///
  /// Parses a function definition, including its return type, identifier,
  /// parameters, and optional 'throws' clause, then creates a [FunctionNode].
  /// It also correctly handles the 'void' return type.
  @override
  Parser function() => super.function().map((e) {
    final [
      AstNode type,
      IdentifierNode identifier,
      Token lparen,
      List parameters,
      Token rparen,
      List? throws,
      Token? separator,
    ] = e as List;

    final returnType = switch (type) {
      TypeNode() => type,
      IdentifierNode() => switch (type.value) {
        'void' => VoidTypeNode(span: type.span),
        _ => CustomTypeNode(value: type.value, span: type.span),
      },

      _ => throw StateError('Unexpected return type in function: $type'),
    };

    final parametersList = parameters.cast<FieldNode>();

    final throwsLists = switch (throws) {
      null => <FieldNode>[],
      [final Token _, final Token _, final List fields, final Token _] =>
        fields.cast<FieldNode>(),

      _ => throw StateError('Unexpected throws clause: $throws'),
    };

    final span = _getSpan(type, separator ?? throws?.last ?? rparen);

    return FunctionNode(
      returnType: returnType,
      identifier: identifier,
      parameters: parametersList,
      throws: throwsLists,
      span: span,
    );
  });

  /// Overrides the [streamType] parser to return a [StreamTypeNode].
  ///
  /// Parses the 'stream' keyword and its element type argument, converting
  /// it into a [StreamTypeNode].
  @override
  Parser streamType() => super.streamType().map((e) {
    final [Token keyword, Token ld, AstNode t, Token rd] = e as List;

    final type = switch (t) {
      TypeNode() => t,
      IdentifierNode() => CustomTypeNode(value: t.value, span: t.span),
      _ => throw StateError('Unexpected type in stream: $t'),
    };

    final span = _getSpan(keyword, rd);

    return StreamTypeNode(elementType: type, span: span);
  });
}
