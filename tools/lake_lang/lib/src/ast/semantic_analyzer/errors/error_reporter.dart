// ignore_for_file: avoid_print

import 'package:source_span/source_span.dart';

import 'semantic_error.dart';

/// A class responsible for collecting and reporting diagnostic messages.
///
/// This reporter accumulates [Diagnostic] objects, which can represent
/// errors, warnings, or informational messages generated during compilation
/// or analysis. It provides methods to add diagnostics and to print them
/// to the console in a user-friendly format
final class ErrorReporter {
  /// List of diagnostics collected by this reporter.
  final List<Diagnostic> _diagnostics = [];

  /// Returns an unmodifiable view of the diagnostics collected.
  List<Diagnostic> get diagnostics => List.unmodifiable(_diagnostics);

  /// Checks if any errors (severity [DiagnosticSeverity.error] or
  /// [DiagnosticSeverity.fatal]) have been reported.
  bool get hasErrors => _diagnostics.any(
    (d) =>
        d.severity == DiagnosticSeverity.error ||
        d.severity == DiagnosticSeverity.fatal,
  );

  /// Reports a single diagnostic message.
  ///
  /// The diagnostic is added to the internal list. If a fatal error is
  /// reported, you might choose to throw a specific exception to halt
  /// further processing.
  ///
  /// - Parameter [diagnostic]: The [Diagnostic] object to report
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

  /// Prints all collected diagnostics to the console.
  ///
  /// Each diagnostic is formatted to show its location, severity, message,
  /// associated code (if any), highlighted source span, additional labels,
  /// suggestions, and a link to more information.
  void printDiagnostics() {
    if (_diagnostics.isEmpty) {
      print('No issues found.');
      return;
    }

    print('--- Diagnostics ---');
    for (final diag in _diagnostics) {
      final codeText = diag.code != null ? ' [${diag.code!.id}]' : '';
      print(
        '${diag.primarySpan.start.line + 1}:'
        '${diag.primarySpan.start.column + 1} '
        '${diag.severity.displayName}$codeText: ${diag.message}\n'
        '${diag.primarySpan.highlight(color: true)}\n',
      );

      for (final (:span, :message) in diag.labels) {
        print(
          '  --> ${span.start.line + 1}:'
          '${span.start.column + 1}: $message\n'
          '${span.highlight(color: true)}\n',
        );
      }

      print('  Suggestions:');
      for (final suggestion in diag.code?.suggestions ?? []) {
        print('    - $suggestion');
      }
      print('');

      if (diag.code?.helpLink case final String link) {
        print('  More info: $link\n');
      }

      print('--------------------');
    }
  }
}

/// Extension methods for [ErrorReporter] to report common diagnostic types.
///
/// This extension provides convenient `report` methods for specific
/// [Diagnostic] subclasses, simplifying the process of creating and
/// reporting structured diagnostic messages.
extension ErrorReporterGenericExtension on ErrorReporter {
  /// Reports a generic diagnostic message with custom message and span.
  ///
  /// Use this method when a more specific diagnostic class is not available
  /// or necessary. It allows for reporting diagnostics with flexible severity,
  /// code, and additional labels.
  ///
  /// - Parameters:
  ///   - [message]: The main diagnostic message.
  ///   - [span]: The primary [SourceSpan] for this diagnostic.
  ///   - [severity]: The severity level. Defaults to
  /// [DiagnosticSeverity.error].
  ///   - [code]: An optional diagnostic code.
  ///   - [labels]: Additional contextual labels.
  ///   - [suggestions]: *Deprecated*. Suggestions are now handled by
  /// [DiagnosticCode].
  void reportGeneric(
    String message,
    SourceSpan span, {
    DiagnosticSeverity severity = DiagnosticSeverity.error,
    DiagnosticCode? code,
    List<DiagnosticLabel> labels = const [],
    List<String> suggestions = const [],
  }) {
    report(
      GenericDiagnostic(
        message,
        span,
        severity: severity,
        labels: labels,
      ),
    );
  }

  // Reports an [UndefinedSymbolDiagnostic].
  ///
  /// This diagnostic is typically used when a symbol (e.g., a variable,
  /// function, or type name) is used but has not been declared or is not
  /// in scope.
  ///
  /// - Parameters:
  ///   - [name]: The name of the undefined symbol.
  ///   - [span]: The [SourceSpan] where the undefined symbol was encountered.
  void reportUndefinedSymbol(String name, SourceSpan span) {
    report(UndefinedSymbolDiagnostic(name, span));
  }

  /// Reports a [DuplicateDeclarationDiagnostic].
  ///
  /// This diagnostic indicates that a symbol has been declared more than
  /// once within the same scope.
  ///
  /// - Parameters:
  ///   - [name]: The name of the duplicated symbol.
  ///   - [span]: The [SourceSpan] of the current, duplicate declaration.
  ///   - [previousDeclarationSpan]: An optional [SourceSpan] pointing to the
  /// location of the original declaration, providing helpful context.
  void reportDuplicateDeclaration(
    String name,
    SourceSpan span, {
    SourceSpan? previousDeclarationSpan,
  }) {
    report(
      DuplicateDeclarationDiagnostic(name, span, previousDeclarationSpan),
    );
  }

  /// Reports an [EmptyEnumDefinitionDiagnostic].
  ///
  /// This diagnostic is triggered when an `enum` is defined without any
  /// members.
  ///
  /// - Parameter [span]: The [SourceSpan] of the empty enum definition.
  void reportEmptyEnumDefinition(SourceSpan span) {
    report(EmptyEnumDefinitionDiagnostic(span));
  }

  /// Reports an [EmptyStructDefinitionDiagnostic].
  ///
  /// This diagnostic is triggered when a `struct` is defined without any
  /// fields.
  ///
  /// - Parameter [span]: The [SourceSpan] of the empty struct definition.
  void reportEmptyStructDefinition(SourceSpan span) {
    report(EmptyStructDefinitionDiagnostic(span));
  }

  /// Reports a [ConstValueCannotBeAssignedDiagnostic].
  ///
  /// This diagnostic occurs when a value of one type cannot be assigned to
  /// a constant declared with a different type.
  ///
  /// - Parameters:
  ///   - [valueTypeName]: The name of the type of the value being assigned.
  ///   - [valueKindName]: A description of the kind of value (e.g., "literal",
  /// "expression").
  ///   - [constTypeName]: The name of the type declared for the constant.
  ///   - [valueSpan]: The [SourceSpan] of the value causing the type mismatch.
  ///   - [constTypeSpan]: An optional [SourceSpan] indicating the constant's
  /// type declaration for additional context.
  void reportConstValueCannotBeAssigned({
    required String valueTypeName,
    required String valueKindName,
    required String constTypeName,
    required SourceSpan valueSpan,
    SourceSpan? constTypeSpan,
  }) {
    report(
      ConstValueCannotBeAssignedDiagnostic(
        valueTypeName: valueTypeName,
        valueKindName: valueKindName,
        constTypeName: constTypeName,
        valueSpan: valueSpan,
        constTypeSpan: constTypeSpan,
      ),
    );
  }

  /// Reports a [ListElementTypeMismatchDiagnostic].
  ///
  /// This diagnostic indicates that an element within a list has a type
  /// that does not match the expected type for that list.
  ///
  /// - Parameters:
  ///   - [expectedType]: The name of the type expected for list elements.
  ///   - [actualType]: The name of the type found for the mismatched element.
  ///   - [span]: The [SourceSpan] of the list element with the type mismatch.
  void reportListElementTypeMismatch({
    required String expectedType,
    required String actualType,
    required SourceSpan span,
  }) {
    report(ListElementTypeMismatchDiagnostic(expectedType, actualType, span));
  }

  /// Reports a [KeywordAsIdentifierDiagnostic].
  ///
  /// This diagnostic is used when a reserved keyword of the language is
  /// erroneously used as an identifier (e.g., for a variable name).
  ///
  /// - Parameters:
  ///   - [identifier]: The reserved keyword that was used as an identifier.
  ///   - [span]: The [SourceSpan] where the keyword was used as an identifier.
  void reportKeywordAsIdentifier(String identifier, SourceSpan span) {
    report(KeywordAsIdentifierDiagnostic(identifier, span));
  }

  /// Reports an [UnsupportedListElementTypeDiagnostic].
  ///
  /// This diagnostic indicates that a list has been declared with an
  /// element type that is not supported by the language or the current
  /// compilation environment.
  ///
  /// - Parameters:
  ///   - [elementType]: The name of the unsupported element type.
  ///   - [span]: The [SourceSpan] where the unsupported list element type was
  ///     encountered.
  void reportUnsupportedListElementType(String elementType, SourceSpan span) {
    report(UnsupportedListElementTypeDiagnostic(elementType, span));
  }
}
