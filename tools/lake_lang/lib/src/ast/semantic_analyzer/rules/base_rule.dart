import '../../nodes/ast_nodes.dart';
import '../error_reporter.dart';

abstract class BaseRule {
  /// Creates a new rule with the given [reporter] for error reporting.
  const BaseRule(this.reporter);

  /// Reporter used to emit semantic errors.
  final ErrorReporter reporter;

  /// Validates the provided [node] against the rule's logic.
  void check(AstNode node);
}

final class RuleDispatcher {
  /// A map that stores lists of [BaseRule] instances,
  /// keyed by the [Type] of [AstNode] they apply to.
  final Map<Type, List<BaseRule>> _ruleMap = {};

  /// Adds a [rule] to the dispatcher.
  ///
  /// The rule will be associated with the type [T], meaning it will be applied
  /// to [AstNode]s of type [T] or its subtypes when [applyRules] is called.
  ///
  /// Example:
  /// ```dart
  /// dispatcher.addRule<VariableDeclaration>(MyVariableRule());
  /// ```
  void addRule<T extends AstNode>(BaseRule rule) {
    _ruleMap.putIfAbsent(T, () => []).add(rule);
  }

  /// Applies all registered rules to the given [node].
  ///
  /// It looks up rules associated with the [runtimeType] of the [node]
  /// and executes their `check` method.
  ///
  /// Rules are applied in the order they were added for a specific node type.
  void applyRules(AstNode node) {
    final rulesForNode = _ruleMap[node.runtimeType];

    if (rulesForNode != null) {
      for (final rule in rulesForNode) {
        rule.check(node);
      }
    }
  }
}
