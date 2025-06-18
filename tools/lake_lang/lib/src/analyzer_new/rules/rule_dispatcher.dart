// lib/analyzer/rules/rule_dispatcher.dart

import '../../ast/nodes/ast_nodes.dart';
import 'base_rule.dart';

/// A dispatcher that manages and applies semantic analysis rules to AST nodes.
///
/// [RuleDispatcher] allows for registering multiple [BaseRule] instances,
/// mapping them to specific [AstNode] types. When `applyRules` is called
/// with an AST node, it automatically dispatches the node to all relevant
/// registered rules for validation.
final class RuleDispatcher {
  /// A map that stores lists of [BaseRule] instances,
  /// keyed by the [Type] of [AstNode] they apply to.
  ///
  /// This map ensures that rules are organized by the type of AST node
  /// they are designed to validate, allowing efficient lookup and application.
  final Map<Type, List<BaseRule>> _ruleMap = {};

  /// Adds a [rule] to the dispatcher.
  ///
  /// The rule will be associated with the type [T], meaning it will be applied
  /// to [AstNode]s of type [T] or its exact subtypes when [applyRules] is
  /// called.
  void addRule<T extends AstNode>(BaseRule<T> rule) {
    _ruleMap.putIfAbsent(T, () => []).add(rule);
  }

  /// Applies all registered rules to the given [node].
  ///
  /// This method looks up rules associated with the exact [runtimeType] of the
  /// provided [node] and executes their `check` method. It is important to note
  /// that rules are matched by the *exact* runtime type, not by supertypes.
  ///
  /// Rules are applied in the order they were added for a specific node type.
  ///
  /// - Parameter [node]: The [AstNode] to which the rules should be applied.
  void applyRules(AstNode node) {
    final rulesForNode = _ruleMap[node.runtimeType];

    if (rulesForNode != null) {
      for (final rule in rulesForNode) {
        // The rule.check method will use the context it was constructed with.
        rule.check(node);
      }
    }
  }
}
