import '../diagnostics/diagnostic.dart';
import '../symbols/symbol_table.dart';

/// Represents the complete semantic information for a single source file.
/// This includes its local symbol table, and any semantic diagnostics found.
class SemanticInfo {
  /// - Resolved types for each expression/node (e.g., Map<AstNode, LakeType>)
  /// - Cross-file references (e.g., Map<IdentifierNode, SymbolInfo>)

  const SemanticInfo({
    required this.localSymbolTable,
    this.diagnostics = const [],
  });

  /// The local symbol table for this file, containing definitions visible
  /// within it.
  final SymbolTable localSymbolTable;

  /// A list of diagnostics (errors, warnings) found during semantic analysis
  /// of this file.
  final List<Diagnostic> diagnostics;
}
