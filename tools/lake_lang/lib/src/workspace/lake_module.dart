import '../parser/ast/ast_base.dart';

/// Represents a compiled Lake file with its resolved AST and immediate 
/// dependencies.
class LakeModule {
  LakeModule({
    required this.path,
    required this.ast,
    required this.dependencies,
  });

  /// The absolute or relative path to the Lake source file.
  final String path;

  /// The root AST node for the parsed document.
  final DocumentNode ast;

  /// List of paths extracted from import statements in the document.
  final List<String> dependencies;
}
