import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../../semantic_types.dart';
import '../../symbols/symbol_table.dart';
import '../base_rule.dart';

/// Rule that ensures a service extends a valid service.
class ServiceExtendsResolutionRule extends BaseRule<ServiceDefinitionNode> {
  const ServiceExtendsResolutionRule({
    required super.reporter,
    required this.symbolTable,
  });

  final SymbolTable symbolTable;

  @override
  void check(ServiceDefinitionNode node) {
    if (node.extendsService == null) {
      return;
    }

    final extendsName = node.extendsService!.name;
    final entry = symbolTable.lookup(extendsName, node.extendsService!);

    // If entry is null, the SymbolTable already reported
    // UndefinedSymbolDiagnostic.
    if (entry != null) {
      if (entry.resolvedType is! ServiceType) {
        reporter.reportInvalidServiceExtends(
          name: extendsName,
          startOffset: node.extendsService!.startOffset,
          endOffset: node.extendsService!.endOffset,
        );
      }
    }
  }
}
