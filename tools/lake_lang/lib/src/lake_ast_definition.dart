import 'package:petitparser/petitparser.dart';

import '../lake_lang.dart';
import 'utils/convert.dart';

class LakeAstGrammarDefinition extends LakeGrammarDefinition {
  @override
  Parser import() => super.import().map((t) {
    final [_, LiteralNode literal] = t as List;

    return ImportNode(path: literal.value);
  });

  @override
  Parser<DocumentNode> document() => super.document().map((t) {
    final [List headers, List definitions] = t as List;
    final resultHeaders = headers.cast<HeaderNode>();
    final resultDefinitions = definitions.cast<DefinitionNode>();

    return DocumentNode(headers: resultHeaders, definitions: resultDefinitions);
  });

  @override
  Parser namespace() => super.namespace().map((t) {
    final [_, [Token lang, IdentifierNode identifier]] = t as List;

    return NamespaceNode(scope: lang.value, name: identifier);
  });

  @override
  Parser<LiteralNode> literal() => super.literal().map((t) {
    final token = t as Token;

    return LiteralNode(value: token.value);
  });

  @override
  Parser<IdentifierNode> identifier() => super.identifier().map((t) {
    final Token token = t;

    return IdentifierNode(name: token.value);
  });

  @override
  Parser<IntConstantNode> intConstant() => super.intConstant().map((t) {
    final Token token = t;

    final intValue = parseStringToInt(token.value);

    return IntConstantNode(value: token.value, intValue: intValue);
  });

  @override
  Parser<DoubleConstantNode> doubleConstant() =>
      super.doubleConstant().map((t) {
        final Token token = t;

        return DoubleConstantNode(value: token.value);
      });

  @override
  Parser<BaseTypeNode> baseType() => super.baseType().map((t) {
    final Token token = t;

    return BaseTypeNode(name: token.value);
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
      id: id.intValue,
      requirement: requirement,
      type: type,
      name: name,
      defaultValue: null,
    );
  });
}
