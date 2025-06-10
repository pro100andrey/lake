import 'package:equatable/equatable.dart';
import 'package:source_span/source_span.dart';

sealed class SemanticError extends Equatable {
  const SemanticError(this.message, this.span);

  final String message;
  final SourceSpan span;

  @override
  List<Object?> get props => [message, span];
}

final class DuplicateDeclarationError extends SemanticError {
  const DuplicateDeclarationError(this.name, SourceSpan span)
    : super('Duplicate declaration of "$name"', span);

  final String name;

  @override
  List<Object?> get props => [message, span, name];
}

final class EmptyEnumDefinitionError extends SemanticError {
  const EmptyEnumDefinitionError(SourceSpan span)
    : super('Empty enum definition', span);
}

final class EmptyStructDefinitionError extends SemanticError {
  const EmptyStructDefinitionError(SourceSpan span)
    : super('Empty struct definition', span);
}

final class ValueCannotBeAssignedError extends SemanticError {
  ValueCannotBeAssignedError(
    String valueType,
    String valueKind,
    String constType,
    SourceSpan span,
  ) : super(
        "The $valueKind '${span.text}' of type '$valueType' "
        "cannot be assigned to a constant of type '$constType'.",
        span,
      );
}

final class GenericSemanticError extends SemanticError {
  const GenericSemanticError(super.message, super.span);
}

final class UndefinedSymbolError extends SemanticError {
  const UndefinedSymbolError(String name, SourceSpan span)
    : super('Undefined symbol "$name"', span);
}

final class InvalidNamespaceError extends SemanticError {
  const InvalidNamespaceError(String namespace, SourceSpan span)
    : super('Invalid namespace "$namespace"', span);
}

final class InvalidTypeError extends SemanticError {
  const InvalidTypeError(String type, SourceSpan span)
    : super('Invalid type "$type"', span);
}
