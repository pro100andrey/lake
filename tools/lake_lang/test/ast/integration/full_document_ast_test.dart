import 'package:test/test.dart';

import '../_ast_helpers.dart';

void main() {
  group('Full Document AST', () {
    final ast = parseAstFromFile(
      'test/ast/integration/test_data/ast_visitor_smoke_test.lake',
    );
  });
}
