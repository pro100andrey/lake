import 'package:petitparser/petitparser.dart';

import '../lake_lang.dart';

class LakeAstGrammarDefinition extends LakeGrammarDefinition {
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

    return IntConstantNode(value: token.value);
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
  Parser<FieldNode> field() => super.field().map((t) {
    final tokens = t as List<Token>;

    return FieldNode(
      id: tokens[0].value,
      requirement: tokens[1].value,
      type: tokens[2].value,
      name: tokens[3].value,
      defaultValue: tokens[4].value,
    );
  });
}
