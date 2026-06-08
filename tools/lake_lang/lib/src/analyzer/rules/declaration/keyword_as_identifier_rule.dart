import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// A rule that checks if an identifier is a reserved keyword.
///
/// This rule specifically targets the use of language-reserved keywords
/// as identifiers, preventing syntax errors and ensuring proper code structure.
final class KeywordAsIdentifierRule extends BaseRule<IdentifierNode> {
  /// Creates a new [KeywordAsIdentifierRule] with the given error [reporter].
  const KeywordAsIdentifierRule({required super.reporter});

  /// Defines a set of reserved keywords that cannot be used as identifiers.
  ///
  /// This set includes keywords for declarations (e.g., `const`, `enum`),
  /// built-in types (e.g., `i32`, `string`), and structural keywords
  /// (e.g., `extends`, `throws`).
  static const _reservedKeywords = <String>{
    'const', 'type', 'enum', 'struct', 'service', 'import', 'namespace', //
    'void', 'bool', 'byte', 'i8', 'i16', 'i32', 'i64', 'double', 'string',
    'binary', 'uuid', 'list', 'map', 'set', 'stream', 'extends', 'throws',
  };

  @override
  void check(IdentifierNode node) {
    if (_reservedKeywords.contains(node.name)) {
      reporter.reportKeywordAsIdentifier(
        identifier: node.name,
        span: node.span,
      );
    }
  }
}
