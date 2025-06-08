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
  const DuplicateDeclarationError(String name, SourceSpan span)
    : super('Duplicate declaration of "$name"', span);

  @override
  List<Object?> get props => [message, span];
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
