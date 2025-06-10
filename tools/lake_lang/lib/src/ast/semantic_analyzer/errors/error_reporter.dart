// ignore_for_file: avoid_print

import 'package:source_span/source_span.dart';

import 'semantic_error.dart';

class ErrorReporter {
  final List<Diagnostic> _diagnostics = [];
  List<Diagnostic> get diagnostics => List.unmodifiable(_diagnostics);

  bool get hasErrors => _diagnostics.any(
    (d) =>
        d.severity == DiagnosticSeverity.error ||
        d.severity == DiagnosticSeverity.fatal,
  );

  void report(Diagnostic diagnostic) {
    _diagnostics.add(diagnostic);

    // Optionally, if a fatal error is reported, you might want to throw
    // a special exception to stop further compilation immediately.
    // if (diagnostic.severity == DiagnosticSeverity.fatal) {
    //   throw FatalCompilationError(
    //     'Fatal error encountered: ${diagnostic.message}'
    //   );
    // }
  }

  void printDiagnostics() {
    if (_diagnostics.isEmpty) {
      print('No issues found.');
      return;
    }

    print('--- Diagnostics ---');
    for (final diag in _diagnostics) {
      final codeText = diag.code != null ? ' [${diag.code}]' : '';
      print(
        '${diag.primarySpan.start.line + 1}:'
        '${diag.primarySpan.start.column + 1} '
        '${diag.severity.displayName}$codeText: ${diag.message}\n'
        '${diag.primarySpan.highlight()}\n',
      );

      for (final (:span, :message) in diag.labels) {
        print(
          '  --> ${span.start.line + 1}:${span.start.column + 1}: $message\n'
          '${span.highlight()}\n',
        );
      }

      print('  Suggestions:');
      for (final suggestion in diag.suggestions) {
        print('    - $suggestion');
      }
      print('');

      if (diag.helpLink case final String link) {
        print('  More info: $link\n');
      }

      print('--------------------');
    }
  }
}

// Generic extension for ErrorReporter to handle common diagnostics

extension ErrorReporterGenericExtension on ErrorReporter {
  /// Reports a generic diagnostic message with custom message and span.
  /// Use this when a more specific diagnostic class is not available or
  ///  necessary.
  void reportGeneric(
    String message,
    SourceSpan span, {
    DiagnosticSeverity severity = DiagnosticSeverity.error,
    String? code,
    List<DiagnosticLabel> labels = const [],
    List<String> suggestions = const [],
    String? helpLink,
  }) {
    report(
      GenericDiagnostic(
        message,
        span,
        severity: severity,
        code: code,
        labels: labels,
        suggestions: suggestions,
        helpLink: helpLink,
      ),
    );
  }
}

extension ErrorReporterExtension on ErrorReporter {
  /// Reports an [UndefinedSymbolDiagnostic].
  void reportUndefinedSymbol(String name, SourceSpan span) {
    report(UndefinedSymbolDiagnostic(name, span));
  }

  /// Reports a [DuplicateDeclarationDiagnostic].
  void reportDuplicateDeclaration(
    String name,
    SourceSpan span, {
    SourceSpan? previousDeclarationSpan,
  }) {
    report(DuplicateDeclarationDiagnostic(name, span, previousDeclarationSpan));
  }

  /// Reports an [EmptyEnumDefinitionDiagnostic].
  void reportEmptyEnumDefinition(SourceSpan span) {
    report(EmptyEnumDefinitionDiagnostic(span));
  }

  /// Reports an [EmptyStructDefinitionDiagnostic].
  void reportEmptyStructDefinition(SourceSpan span) {
    report(EmptyStructDefinitionDiagnostic(span));
  }

  void reportValueCannotBeAssigned({
    required String valueTypeName,
    required String valueKindName,
    required String constTypeName,
    required SourceSpan valueSpan,
    SourceSpan? constTypeSpan,
  }) {
    report(
      ValueCannotBeAssignedDiagnostic(
        valueTypeName: valueTypeName,
        valueKindName: valueKindName,
        constTypeName: constTypeName,
        valueSpan: valueSpan,
        constTypeSpan: constTypeSpan,
      ),
    );
  }

  void reportInvalidIdentifierName(String identifier, SourceSpan span) {
    report(InvalidIdentifierNameDiagnostic(identifier, span));
  }
}
