import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';
import '../symbol_table.dart';

sealed class SemanticRule {
  const SemanticRule(this.reporter, this.table);

  final ErrorReporter reporter;
  final SymbolTable table;

  void check(AstNode node);
}

final class NoDuplicateDeclarationsRule extends SemanticRule {
  const NoDuplicateDeclarationsRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    throw UnimplementedError(
      'NoDuplicateDeclarationsRule is not implemented yet.',
    );
  }
}

class NoUndefinedSymbolsRule extends SemanticRule {
  const NoUndefinedSymbolsRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    throw UnimplementedError(
      'NoUndefinedSymbolsRule is not implemented yet.',
    );
  }
}

final class ConstTypeCheckRule extends SemanticRule {
  ConstTypeCheckRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    if (node case ConstDefinitionNode(
      :final type,
      :final identifier,
      :final value,
      :final span,
    )) {
      // final declaratedSemanticType =
    }
  }
}



class EnumValueTypeRule extends SemanticRule {
  EnumValueTypeRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    throw UnimplementedError(
      'EnumValueTypeRule is not implemented yet.',
    );
  }
}

class ServiceInheritanceRule extends SemanticRule {
  ServiceInheritanceRule(super.reporter, super.table);

  @override
  void check(AstNode node) {
    throw UnimplementedError(
      'ServiceInheritanceRule is not implemented yet.',
    );
  }
}
