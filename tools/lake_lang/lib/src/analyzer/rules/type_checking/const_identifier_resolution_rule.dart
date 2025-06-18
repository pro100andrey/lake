import '../../../ast/nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../../symbols/symbol_table.dart';
import '../../utils.dart';
import '../base_rule.dart';

/// A rule that resolves identifiers used as constant values and checks their
/// type compatibility.
///
/// This rule runs in the type-checking phase.
final class ConstIdentifierResolutionRule
    extends BaseRule<ConstDefinitionNode> {
  const ConstIdentifierResolutionRule({
    required super.reporter,
    required this.symbolTable,
  });

  final SymbolTable symbolTable;

  @override
  void check(ConstDefinitionNode node) {
    if (node.value is IdentifierNode) {
      final identifierNode = node.value as IdentifierNode;

      // 1. Resolve the identifier in the symbol table
      final symbolEntry = symbolTable.lookup(
        identifierNode.value,
        identifierNode.span,
      );

      if (symbolEntry == null) {
        // Error already reported by symbolTable.lookup
        return;
      }

      // 2. Get the semantic type of the identifier
      final identifierSemanticType = symbolEntry.resolvedType;
      if (identifierSemanticType == null) {
        // This can happen if the symbol's type hasn't been resolved yet
        // or if it's a symbol kind that doesn't have a semantic type (e.g., a
        // service declaration itself).
        // For constants, we expect a resolved type.
        reporter.reportGeneric(
          message:
              'Could not determine type of constant identifier '
              "'${identifierNode.value}'.",
          span: identifierNode.span,
          filePath: '<file_path>',
        );
        return;
      }

      // 3. Get the declared type of the constant
      final declaredSemanticType = getSemanticType(
        node.type,
        reporter,
        symbolTable,
      );

      if (declaredSemanticType == null) {
        // Error already reported by getSemanticType
        return;
      }

      // 4. Check assignability
      if (!identifierSemanticType.isAssignableTo(declaredSemanticType)) {
        reporter.reportLiteralValueCannotBeAssigned(
          literalTypeName: declaredSemanticType.name,
          // Or a more specific kind if known from symbolEntry.kind
          valueKindName: 'identifier',
          valueSpan: identifierNode.span,
          valueTypeName: identifierSemanticType.name,
          literalTypeSpan: node.type.span,
          filePath: '<file_path>',
        );
      }
    }
  }
}
