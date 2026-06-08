import '../../parser/ast/ast_base.dart';
import '../errors/error_reporter.dart';

/// Abstract base class for all semantic analysis rules.
///
/// Each rule is responsible for validating a specific type of [AstNode]
/// and reporting any semantic errors or warnings using the provided [reporter].
///
/// Type parameter [T] specifies the type of [AstNode] that this rule can check.
abstract class BaseRule<T extends AstNode> {
  /// Creates a new rule with the given [reporter] for error reporting.
  ///
  /// - Parameter [reporter]: The [ErrorReporter] instance used to emit
  ///   semantic errors, warnings, or hints.
  const BaseRule({required this.reporter});

  /// Reporter used to emit semantic errors.
  final ErrorReporter reporter;

  /// Validates the provided node against the rule's logic.
  ///
  /// Subclasses must implement this method to define the specific validation
  /// logic for the AST node type [T]. Any issues found should be reported
  /// using the [reporter].
  ///
  /// - Parameter node: The [AstNode] of type [T] to be checked.
  void check(T node);
}

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
  ///
  /// Example:
  /// ```dart
  /// class MyVariableRule extends BaseRule<VariableDeclaration> {
  ///   MyVariableRule(super.reporter);
  ///   @override
  ///   void check(VariableDeclaration node) {
  ///     // Implement checking logic
  ///   }
  /// }
  ///
  /// final dispatcher = RuleDispatcher();
  /// dispatcher.addRule<VariableDeclaration>(MyVariableRule(errorReporter));
  /// ```
  ///```
  void addRule<T extends AstNode>(BaseRule<T> rule) {
    _ruleMap.putIfAbsent(T, () => []).add(rule);
  }

  /// Applies all registered rules to the given node.
  ///
  /// This method looks up rules associated with the exact [runtimeType] of the
  /// provided node and executes their `check` method. It is important to note
  /// that rules are matched by the *exact* runtime type, not by supertypes.
  ///
  /// Rules are applied in the order they were added for a specific node type.
  ///
  /// - Parameter node: The [AstNode] to which the rules should be applied.
  void applyRules(AstNode node) {
    final rulesForNode = _ruleMap[node.runtimeType];

    if (rulesForNode != null) {
      for (final rule in rulesForNode) {
        rule.check(node);
      }
    }
  }
}
