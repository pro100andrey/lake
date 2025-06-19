import '../../ast/nodes/ast_nodes.dart';
import '../diagnostics/diagnostic_system.dart';
import '../symbol_table/compilation_symbol_table.dart';

/// Abstract base class for all semantic analysis rules.
///
/// Each rule is responsible for validating a specific type of [AstNode]
/// and reporting any semantic errors or warnings using the provided
/// [diagnosticSystem].
///
/// Type parameter [T] specifies the type of [AstNode] that this rule can check.
abstract class BaseRule<T extends AstNode> {
  /// Creates a new rule with the given context.
  ///
  /// - Parameter [diagnosticSystem]: The [DiagnosticSystem] instance used to
  /// emit semantic errors, warnings, or hints.
  /// - Parameter [compilationSymbolTable]: The central manager for all symbol
  ///   tables across compilation units, used for resolving symbols globally.
  /// - Parameter [currentFilePath]: The absolute path of the file currently
  ///   being processed, which serves as the context for symbol lookups.
  const BaseRule({
    required this.diagnosticSystem,
    required this.compilationSymbolTable,
    required this.currentFilePath,
  });

  /// Reporter used to emit semantic errors.
  final DiagnosticSystem diagnosticSystem;

  /// The compilation-wide symbol table, providing access to all resolved
  /// symbols
  /// across different files.
  final CompilationSymbolTable compilationSymbolTable;

  /// The path of the file currently being analyzed by this rule.
  /// This is crucial for cross-file symbol resolution.
  final String currentFilePath;

  /// Validates the provided [node] against the rule's logic.
  ///
  /// Subclasses must implement this method to define the specific validation
  /// logic for the AST node type [T]. Any issues found should be reported
  /// using the [diagnosticSystem].
  ///
  /// - Parameter [node]: The [AstNode] of type [T] to be checked.
  void check(T node);
}
