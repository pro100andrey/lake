import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';

import '../../lake_lang.dart';

class LakeAstGrammarDefinition extends LakeGrammarDefinition {
  LakeAstGrammarDefinition(this._sourceFile);

  final SourceFile _sourceFile;

  SourceSpan _getSpan(Object startElement, Object endElement) {
    int startOffset;
    int endOffset;

    if (startElement is Token) {
      startOffset = startElement.start;
    } else if (startElement is AstNode && startElement.span != null) {
      startOffset = startElement.span!.start.offset;
    } else {
      throw ArgumentError('Invalid start element for span: $startElement');
    }

    if (endElement is Token) {
      endOffset = endElement.stop;
    } else if (endElement is AstNode && endElement.span != null) {
      endOffset = endElement.span!.end.offset;
    } else {
      throw ArgumentError('Invalid end element for span: $endElement');
    }

    return _sourceFile.span(startOffset, endOffset);
  }

  @override
  Parser<DocumentNode> document() => super.document().map((t) {
    final [List headers, List definitions] = t as List;

    final resultHeaders = headers.cast<HeaderNode>();
    final resultDefinitions = definitions.cast<DefinitionNode>();
    final allNodes = [...resultHeaders, ...resultDefinitions];

    final span = allNodes.isNotEmpty
        ? _getSpan(allNodes.first, allNodes.last)
        : null;

    return DocumentNode(
      headers: resultHeaders,
      definitions: resultDefinitions,
      span: span,
    );
  });

  @override
  Parser import() => super.import().map((t) {
    final [_, LiteralNode literal] = t as List;

    final span = _getSpan(t.first, t.last);

    return ImportNode(path: literal.value, span: span);
  });

  @override
  Parser namespace() => super.namespace().map((t) {
    final [Token tt, [Token lang, LiteralNode literal]] = t as List;

    final span = _getSpan(tt, literal);

    return NamespaceNode(scope: lang.value, name: literal.value, span: span);
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

    final entriesList = values
        .map((e) => MapEntry(e[0] as ConstValueNode, e[2] as ConstValueNode))
        .toList(growable: false);

    final entries = Map.fromEntries(entriesList);

    return ConstMapNode(entries: entries, span: span);
  });

  @override
  Parser constDefinition() => super.constDefinition().map((t) {
    final [
      Token keyword,
      TypeNode type,
      IdentifierNode identifier,
      Token equalOp,
      ConstValueNode value,
      _,
    ] = t as List;

    final span = _getSpan(keyword, value);

    return ConstDefinitionNode(
      name: identifier,
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

    return TypedefDefinitionNode(name: identifier, type: type, span: span);
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
  Parser enumConstant() => super.enumConstant().map((t) {
    final [IdentifierNode type, Token comma, IdentifierNode value] = t as List;

    final span = _getSpan(type, value);

    return EnumConstantNode(type: type, value: value, span: span);
  });

  @override
  Parser baseType() => super.baseType().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return BaseTypeNode(type: token.value, span: span);
  });

  @override
  Parser fieldReq() => super.fieldReq().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return FieldRequirementNode(requirement: token.value, span: span);
  });

  @override
  Parser mapType() => super.mapType().map((t) {
    final [
      Token mapKeyword,
      Token ld,
      AstNode keyType,
      Token comma,
      AstNode valueType,
      Token rd,
    ] = t as List;

    final keyTypeNode = switch (keyType) {
      BaseTypeNode() => keyType,
      IdentifierNode() => CustomTypeNode(type: keyType, span: keyType.span),
      _ => throw StateError('Unexpected key type in map: $keyType'),
    };

    final valueTypeNode = switch (valueType) {
      BaseTypeNode() => valueType,
      IdentifierNode() => CustomTypeNode(type: valueType, span: valueType.span),
      _ => throw StateError('Unexpected value type in map: $valueType'),
    };

    final span = _getSpan(ld, rd);

    return MapTypeNode(
      keyType: keyTypeNode,
      valueType: valueTypeNode,
      span: span,
    );
  });

  @override
  Parser listType() => super.listType().map((t) {
    final [Token listKeyword, Token ld, AstNode type, Token rd] = t as List;

    final itemType = switch (type) {
      BaseTypeNode() => type,
      IdentifierNode() => CustomTypeNode(type: type, span: type.span),

      _ => throw StateError('Unexpected type in list: $type'),
    };

    final span = _getSpan(ld, rd);

    return ListTypeNode(itemType: itemType, span: span);
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
    final enumValues = values.cast<EnumValueNode>();

    final span = _getSpan(keyword, rd);

    return EnumDefinitionNode(name: identifier, values: enumValues, span: span);
  });

  @override
  Parser enumValue() => super.enumValue().map((t) {
    final [
      IdentifierNode memberName,
      [Token? equalOp, IntConstantNode? value],
      Token? separator,
    ] = t as List;

    final span = _getSpan(memberName, separator ?? value ?? memberName);

    return EnumValueNode(memberName: memberName, value: value, span: span);
  });

  @override
  Parser field() => super.field().map((t) {
    final [
      [IntConstantNode id, Token idSeparator],
      FieldRequirementNode? requirement,
      AstNode type,
      IdentifierNode name,
      List? defaultValueTuple,
      Token? separator,
    ] = t as List;

    final defaultValue = () {
      if (defaultValueTuple != null) {
        final [Token equalOp, AstNode value] = defaultValueTuple;

        final result = switch (value) {
          ConstValueNode() => value,
          _ => throw StateError('Unexpected default value type: $value'),
        };

        return result;
      }
    }();

    final calculatedType = switch (type) {
      BaseTypeNode() => type,
      IdentifierNode() => CustomTypeNode(type: type, span: type.span),
      ContainerTypeNode() => type,

      _ => throw StateError('Unexpected type in field: $type'),
    };

    final span = _getSpan(id, separator ?? defaultValue ?? name);

    return FieldNode(
      id: id,
      requirement: requirement,
      type: calculatedType,
      name: name,
      defaultValue: defaultValue,
      span: span,
    );
  });

  @override
  Parser setType() => super.setType().map((t) {
    final [Token setKeyword, Token ld, AstNode type, Token rd] = t as List;

    final itemType = switch (type) {
      BaseTypeNode() => type,
      IdentifierNode() => CustomTypeNode(type: type, span: type.span),
      _ => throw StateError('Unexpected type in set: $type'),
    };

    final span = _getSpan(ld, rd);

    return SetTypeNode(itemType: itemType, span: span);
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
      name: identifier,
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
      name: identifier,
      fields: fieldNodes,
      span: span,
    );
  });
}
