import '../../ast/ast_visitor.dart';

part 'ast_definitions.dart';
part 'ast_expressions.dart';

/// Base sealed class for all AST nodes in the new parser.
/// Contains flat start and end offsets instead of allocating Span objects.
sealed class AstNode {
  const AstNode({
    required this.startOffset,
    required this.endOffset,
  });

  /// The absolute starting character index of this node in the source text.
  final int startOffset;

  /// The absolute ending character index of this node in the source text
  /// (exclusive).
  final int endOffset;

  /// Accepts an [AstVisitor] to traverse the tree.
  T accept<T>(AstVisitor<T> visitor);

  /// Casts this node to a specific type [T].
  T cast<T extends AstNode>() => this as T;
}
