// ignore_for_file: avoid_print

import 'package:source_span/source_span.dart';

import 'semantic_error.dart';

final class ErrorReporter {
  final List<SemanticError> _errors = [];

  /// Returns true if any errors have been reported.
  bool get hasErrors => _errors.isNotEmpty;

  /// Returns an unmodifiable list of all reported errors.
  List<SemanticError> get errors => List.unmodifiable(_errors);

  /// Reports a generic [SemanticError].
  /// This is the most general way to report an error.
  void report(SemanticError error) {
    _errors.add(error);
  }

  /// Reports a generic semantic error with custom message and span.
  /// Use this when a more specific error  class is not available or necessary.
  void reportError(String message, SourceSpan span) {
    report(GenericSemanticError(message, span));
  }

  void reportValueCannotBeAssigned(
    String valueType,
    String valueKind,
    String constType,
    SourceSpan span,
  ) {
    report(
      ValueCannotBeAssignedError(valueType, valueKind, constType, span),
    );
  }

  /// Reports a [DuplicateDeclarationError].
  void reportDuplicateDeclaration(String name, SourceSpan span) {
    report(DuplicateDeclarationError(name, span));
  }

  /// Reports an [UndefinedSymbolError].
  void reportUndefinedSymbol(String name, SourceSpan span) {
    report(UndefinedSymbolError(name, span));
  }

  /// Reports an [EmptyEnumDefinitionError].
  void reportEmptyEnumDefinition(SourceSpan span) {
    report(EmptyEnumDefinitionError(span));
  }

  /// Reports an [EmptyStructDefinitionError].
  void reportEmptyStructDefinition(SourceSpan span) {
    report(EmptyStructDefinitionError(span));
  }

  void printErrors() {
    if (_errors.isEmpty) {
      print('No semantic errors found.');
      return;
    }

    print('Semantic Errors:');
    for (final error in _errors) {
      print(
        '${error.span.start.line + 1}:${error.span.start.column + 1} - '
        '${error.message} \n'
        '${error.span.highlight()}\n',
      );
    }
  }
}
