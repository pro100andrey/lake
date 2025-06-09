import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';

import '../grammar/lake_grammar_definition.dart';
import 'nodes/ast_nodes.dart';

class LakeAstGrammarDefinition extends LakeGrammarDefinition {
  LakeAstGrammarDefinition(this._sourceFile);

  final SourceFile _sourceFile;

  SourceSpan _getSpan(Object startElement, Object endElement) {
    final start = switch (startElement) {
      Token(start: final start) => start,
      AstNode(span: SourceSpan(start: final start)) => start.offset,
      _ => throw ArgumentError('Invalid start element for span: $startElement'),
    };

    final end = switch (endElement) {
      Token(stop: final stop) => stop,
      AstNode(span: SourceSpan(end: final end)) => end.offset,
      _ => throw ArgumentError('Invalid end element for span: $endElement'),
    };

    return _sourceFile.span(start, end);
  }

  @override
  Parser<DocumentNode> document() => super.document().map((t) {
    final [List headers, List definitions] = t as List;

    final resultHeaders = headers.cast<HeaderNode>();
    final resultDefinitions = definitions.cast<DefinitionNode>();
    final allNodes = [...resultHeaders, ...resultDefinitions];

    final span = allNodes.isNotEmpty
        ? _getSpan(allNodes.first, allNodes.last)
        : _sourceFile.span(0, 0);

    return DocumentNode(
      headers: resultHeaders,
      definitions: resultDefinitions,
      span: span,
    );
  });

  @override
  Parser import() => super.import().map((t) {
    final [Token keyword, LiteralNode literal] = t as List;

    final span = _getSpan(keyword, literal);

    return ImportNode(path: literal, span: span);
  });

  @override
  Parser namespace() => super.namespace().map((t) {
    final [
      Token keyword,
      [LiteralNode lang, IdentifierNode identifier],
    ] = t as List;

    final span = _getSpan(keyword, identifier);

    return NamespaceNode(scope: lang, identifier: identifier, span: span);
  });

  @override
  Parser namespaceScope() => super.namespaceScope().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);
    return LiteralNode(value: token.value, span: span);
  });

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

  @override
  Parser fieldReq() => super.fieldReq().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return FieldRequirementNode(value: token.value, span: span);
  });

  @override
  Parser baseType() => super.baseType().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return BaseTypeNode(value: token.value, span: span);
  });

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

  @override
  Parser setType() => super.setType().map((t) {
    final [Token keyword, Token ld, AstNode type, Token rd] = t as List;

    final itemType = switch (type) {
      BaseTypeNode() => type,
      IdentifierNode() => CustomTypeNode(value: type.value, span: type.span),
      _ => throw StateError('Unexpected type in set: $type'),
    };

    final span = _getSpan(keyword, rd);

    return SetTypeNode(elementType: itemType, span: span);
  });

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

  @override
  Parser intConstant() => super.intConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return IntConstantNode(value: token.value, span: span);
  });

  @override
  Parser doubleConstant() => super.doubleConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return DoubleConstantNode(value: token.value, span: span);
  });

  @override
  Parser boolConstant() => super.boolConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return BoolConstantNode(value: token.value == 'true', span: span);
  });

  @override
  Parser constList() => super.constList().map((t) {
    final [Token ld, List<List> values, Token rd] = t as List;

    final span = _getSpan(ld, rd);

    final elements = values
        .map((e) => e.first as ConstValueNode)
        .toList(growable: false);

    return ConstListNode(elements: elements, span: span);
  });

  @override
  Parser constMap() => super.constMap().map((t) {
    final [Token ld, List<List> values, Token rd] = t as List;

    final span = _getSpan(ld, rd);

    final entries = values
        .map((e) => MapEntry(e[0] as ConstValueNode, e[2] as ConstValueNode))
        .toList(growable: false);

    return ConstMapNode(entries: entries, span: span);
  });

  @override
  Parser literal() => super.literal().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return LiteralNode(value: token.value, span: span);
  });

  @override
  Parser identifier() => super.identifier().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return IdentifierNode(value: token.value, span: span);
  });

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
    final functionsList = functions.cast<FunctionNode>();

    return ServiceDefinitionNode(
      identifier: identifier,
      extendsService: extendsService,
      functions: functionsList,
      span: span,
    );
  });

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
