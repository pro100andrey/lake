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
