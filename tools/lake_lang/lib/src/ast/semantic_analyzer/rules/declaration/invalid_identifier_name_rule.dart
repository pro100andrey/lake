import '../../../nodes/ast_nodes.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// A rule that checks if an identifier is a reserved keyword.
final class InvalidIdentifierNameRule extends BaseRule<IdentifierNode> {
  const InvalidIdentifierNameRule(super.reporter);

  // Define a set of reserved keywords that cannot be used as identifiers.
  static const Set<String> _reservedKeywords = {
    'const', 'type', 'enum', 'struct', 'service', 'import', 'namespace', //
    'void', 'bool', 'byte', 'i8', 'i16', 'i32', 'i64', 'double', 'string',
    'binary', 'uuid', 'list', 'map', 'set', 'stream', 'extends', 'throws',
  };

  @override
  void check(IdentifierNode node) {
    if (_reservedKeywords.contains(node.value)) {
      reporter.reportInvalidIdentifierName(node.value, node.span);
    }
  }
}
