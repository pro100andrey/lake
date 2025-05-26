import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';

import '../lake_lang.dart';

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
  Parser import() => super.import().map((t) {
    final [_, LiteralNode literal] = t as List;

    return ImportNode(path: literal.value);
  });

  @override
  Parser<DocumentNode> document() => super.document().map((t) {
    final [List headers, List definitions] = t as List;
    final resultHeaders = headers.cast<HeaderNode>();
    final resultDefinitions = definitions
        .map((e) => e as DefinitionNode)
        .toList();

    return DocumentNode(headers: resultHeaders, definitions: resultDefinitions);
  });

  @override
  Parser namespace() => super.namespace().map((t) {
    final [Token tt, [Token lang, IdentifierNode identifier]] = t as List;

    return NamespaceNode(scope: lang.value, name: identifier);
  });

  @override
  Parser constList() => super.constList().map((t) {
    final elements = (t as List).cast<ConstValueNode>();

    return ConstListNode(elements: elements, span: null);
  });

  @override
  Parser constDefinition() => super.constDefinition().map((t) {
    final [
      _,
      TypeNode type,
      IdentifierNode identifier,
      _,
      ConstValueNode value,
      _,
    ] = t as List;

    return ConstDefinitionNode(name: identifier, type: type, value: value);
  });

  @override
  Parser typedefDefinition() => super.typedefDefinition().map((t) {
    final [_, TypeNode type, IdentifierNode identifier, _] = t as List;

    return TypedefDefinitionNode(name: identifier, type: type);
  });

  @override
  Parser<LiteralNode> literal() => super.literal().map((t) {
    final token = t as Token;

    final span = _getSpan(token, token);

    return LiteralNode(value: token.value, span: span);
  });

  @override
  Parser<IdentifierNode> identifier() => super.identifier().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return IdentifierNode(name: token.value, span: span);
  });

  @override
  Parser<IntConstantNode> intConstant() => super.intConstant().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return IntConstantNode(value: token.value, span: span);
  });

  @override
  Parser<DoubleConstantNode> doubleConstant() =>
      super.doubleConstant().map((t) {
        final Token token = t;

        final span = _getSpan(token, token);

        return DoubleConstantNode(value: token.value, span: span);
      });

  @override
  Parser<BaseTypeNode> baseType() => super.baseType().map((t) {
    final Token token = t;

    final span = _getSpan(token, token);

    return BaseTypeNode(name: token.value, span: span);
  });

  @override
  Parser fieldReq() => super.fieldReq().map((t) {
    final token = t as Token;

    return FieldRequirementNode(requirement: token.value);
  });

  @override
  Parser listType() => super.listType().map((t) {
    final [_, _, type, _] = t as List;

    final itemType = switch (type) {
      BaseTypeNode() => type,
      IdentifierNode() => CustomTypeNode(name: type),

      _ => throw StateError('Unexpected type in list: $type'),
    };

    return ListTypeNode(itemType: itemType);
  });

  @override
  Parser enumDefinition() => super.enumDefinition().map((t) {
    final [_, identifier, _, values, _] = t as List;
    final enumValues = values.cast<EnumValueNode>();
    final span = _getSpan(t.first, t.last);
    return EnumDefinitionNode(name: identifier, values: enumValues);
  });

  @override
  Parser<FieldNode> field() => super.field().map((t) {
    final [
      [IntConstantNode id, Token _],
      FieldRequirementNode? requirement,
      TypeNode type,
      IdentifierNode name,
      defaultValue,
      _,
    ] = t as List;

    final defaultValueResult = switch (defaultValue) {
      [_, final IdentifierNode value] => value,
      null => null,
      _ => throw StateError('Unexpected default value: $defaultValue'),
    };

    return FieldNode(
      id: id,
      requirement: requirement,
      type: type,
      name: name,
      defaultValue: null,
    );
  });
}
