import '../../../parser/ast/ast_base.dart';
import '../../errors/error_reporter.dart';
import '../base_rule.dart';

/// Rule that ensures all fields within a struct, union, exception, or method
/// have unique integer identifiers.
class UniqueFieldIdRule<T extends AstNode> extends BaseRule<T> {
  const UniqueFieldIdRule({required super.reporter});

  @override
  void check(T node) {
    Iterable<FieldNode> fields;
    if (node is StructDefinitionNode) {
      fields = node.fields;
    } else if (node is UnionDefinitionNode) {
      fields = node.fields;
    } else if (node is ExceptionDefinitionNode) {
      fields = node.fields;
    } else if (node is MethodNode) {
      fields = node.parameters;
    } else {
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
