import '../../ast/nodes/ast_nodes.dart';
import 'semantic_info.dart';

final class AnalysisCache {
  // Cache for Abstract Syntax Trees (ASTs)
  final Map<String, DocumentNode> _astCache = {};

  // Cache for semantic information (e.g., local symbol tables, resolved types)
  final Map<String, SemanticInfo> _semanticCache = {};

  // Tracks which files are currently considered "dirty" or invalidated
  final Set<String> _invalidatedFiles = {};

  /// Retrieves the cached AST for a given file path.
  /// Returns null if the AST is not cached or has been invalidated.
  DocumentNode? getAst(String filePath) {
    if (_invalidatedFiles.contains(filePath)) {
      return null; // Don't return invalidated ASTs
    }
    
    return _astCache[filePath];
  }

  /// Stores an AST in the cache for a given file path.
  void setAst(String filePath, DocumentNode ast) {
    _astCache[filePath] = ast;
    _invalidatedFiles.remove(filePath); // Mark as valid/fresh
  }

  /// Retrieves the cached semantic information for a given file path.
  /// Returns null if the semantic info is not cached or has been invalidated.
  SemanticInfo? getSemanticInfo(String filePath) {
    if (_invalidatedFiles.contains(filePath)) {
      return null; // Don't return invalidated semantic info
    }
    return _semanticCache[filePath];
  }

  /// Stores semantic information in the cache for a given file path.
  void setSemanticInfo(String filePath, SemanticInfo semanticInfo) {
    _semanticCache[filePath] = semanticInfo;
    _invalidatedFiles.remove(filePath); // Mark as valid/fresh
  }

  /// Invalidates the cache for a specific file.
  /// This marks the file as 'dirty', so its AST and semantic info
  /// will be re-parsed and re-analyzed on next access.
  void invalidate(String filePath) {
    _invalidatedFiles.add(filePath);
    // We don't remove from _astCache or _semanticCache immediately
    // in case some partial data is still useful, but getAst/getSemanticInfo
    // will now return null. Actual removal can happen during cleanup or
    // when a new version is set.
  }

  /// Checks if a file's cache is currently invalidated.
  bool isInvalidated(String filePath) => _invalidatedFiles.contains(filePath);

  /// Clears all cached data and invalidation flags.
  void clearAll() {
    _astCache.clear();
    // _semanticCache.clear();
    _invalidatedFiles.clear();
  }
}
