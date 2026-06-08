import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// Rule that ensures all fields within a struct, union, exception, or method
/// have unique integer identifiers.
class UniqueFieldIdRule<T extends AstNode> extends BaseRule<T> {
  const UniqueFieldIdRule({required super.reporter});
  @override
  void check(T node) {
    final Iterable<FieldNode> fields =
        switch (node) {
          StructDefinitionNode(:final fields) => fields,
          UnionDefinitionNode(:final fields) => fields,
          ExceptionDefinitionNode(:final fields) => fields,
          MethodNode(:final parameters) => parameters,
          _ => null,
        } ??
        const [];

    if (fields.isEmpty) {
      return;
    }

    final seenIds = <int, FieldNode>{};
    for (final field in fields) {
      if (field.fieldId == null) {
        continue;
      }

      if (seenIds.containsKey(field.fieldId!.value)) {
        final prev = seenIds[field.fieldId!.value]!;
        reporter.reportDuplicateFieldId(
          id: field.fieldId!.value,
          startOffset: field.startOffset,
          endOffset: field.endOffset,
          prevStart: prev.startOffset,
          prevEnd: prev.endOffset,
        );
      } else {
        seenIds[field.fieldId!.value] = field;
      }
    }
  }
}
