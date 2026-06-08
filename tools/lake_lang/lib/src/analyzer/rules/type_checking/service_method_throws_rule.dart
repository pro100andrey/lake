import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../../semantic_types.dart';
import '../../symbols/symbol_table.dart';
import '../../utils.dart';
import '../base_rule.dart';

/// Rule that ensures types listed in a throws clause correspond
/// to a valid Exception.
class ServiceMethodThrowsRule extends BaseRule<MethodNode> {
  const ServiceMethodThrowsRule({
    required super.reporter,
    required this.symbolTable,
  });

  final SymbolTable symbolTable;

  @override
  void check(MethodNode node) {
    for (final throwField in node.throws) {
      final throwType = throwField.type;
      final semanticType = getSemanticType(throwType, reporter, symbolTable);

      // If semanticType is null, UndefinedSymbolDiagnostic is already reported.
      if (semanticType != null) {
        if (semanticType is! ExceptionType) {
          reporter.reportInvalidThrowsType(
            name: semanticType.name,
            startOffset: throwField.startOffset,
            endOffset: throwField.endOffset,
          );
        }
      }
    }
  }
}
