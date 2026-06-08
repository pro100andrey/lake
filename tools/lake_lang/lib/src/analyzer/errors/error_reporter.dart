//
// ignore_for_file: avoid_print

import 'package:source_span/source_span.dart';

import '../../ast/base/types.dart';
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
  void printDiagnostics(SourceFile sourceFile) {
    if (_diagnostics.isEmpty) {
      print('No issues found.');
      return;
    }

    final separator = '-' * 120;

    for (final diag in _diagnostics) {
      final diagSpan = sourceFile.span(
        diag.span.start.offset,
        diag.span.end.offset,
      );

      final codeText = diag.code != null ? ' [${diag.code!.id}]' : '';
      print(
        '${diagSpan.start.line + 1}:'
        '${diagSpan.start.column + 1} '
        '${diag.severity.displayName}$codeText: ${diag.message}\n'
        '${diagSpan.highlight(color: true)}\n',
      );

      for (final (:span, :message) in diag.labels) {
        final labelSpan = sourceFile.span(
          span.start.offset,
          span.end.offset,
        );

        print(
          '  --> ${labelSpan.start.line + 1}:'
          '${labelSpan.start.column + 1}: $message\n'
          '${labelSpan.highlight(color: true)}\n',
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

      print(separator);
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
  ///   - [span]: The primary [Span] for this diagnostic.
  ///   - [severity]: The severity level. Defaults to
  /// [DiagnosticSeverity.error].
  ///   - [code]: An optional diagnostic code.
  ///   - [labels]: Additional contextual labels.
  ///   - [suggestions]: *Deprecated*. Suggestions are now handled by
  /// [DiagnosticCode].
  void reportGeneric({
    required String message,
    required SourceSpan span,
    DiagnosticSeverity severity = DiagnosticSeverity.error,
    DiagnosticCode? code,
    List<DiagnosticLabel> labels = const [],
    List<String> suggestions = const [],
  }) {
    report(
      GenericDiagnostic(
        message: message,
        span: span,
        severity: severity,
        labels: labels,
      ),
    );
  }

  // Reports an [UndefinedSymbolDiagnostic].
  ///
  /// This diagnostic is typically used when a symbol (e.g., a variable,
  /// method, or type name) is used but has not been declared or is not
  /// in scope.
  ///
  /// - Parameters:
  ///   - [name]: The name of the undefined symbol.
  ///   - [span]: The [Span] where the undefined symbol was encountered.
  void reportUndefinedSymbol({required String name, required SourceSpan span}) {
    report(UndefinedSymbolDiagnostic(name: name, span: span));
  }

  /// Reports a [DuplicateDeclarationDiagnostic].
  ///
  /// This diagnostic indicates that a symbol has been declared more than
  /// once within the same scope.
  ///
  /// - Parameters:
  ///   - [name]: The name of the duplicated symbol.
  ///   - [span]: The [Span] of the current, duplicate declaration.
  ///   - [previousDeclarationSpan]: An optional [Span] pointing to the
  /// location of the original declaration, providing helpful context.
  void reportDuplicateDeclaration({
    required String name,
    required SourceSpan span,
    required SourceSpan previousDeclarationSpan,
  }) {
    report(
      DuplicateDeclarationDiagnostic(
        name: name,
        span: span,
        previousDeclarationSpan: previousDeclarationSpan,
      ),
    );
  }

  /// Reports an [EmptyEnumDefinitionDiagnostic].
  ///
  /// This diagnostic is triggered when an `enum` is defined without any
  /// members.
  ///
  /// - Parameter [span]: The [Span] of the empty enum definition.
  void reportEmptyEnumDefinition({required SourceSpan span}) {
    report(EmptyEnumDefinitionDiagnostic(span: span));
  }

  /// Reports an [EmptyStructDefinitionDiagnostic].
  ///
  /// This diagnostic is triggered when a `struct` is defined without any
  /// fields.
  ///
  /// - Parameter [span]: The [Span] of the empty struct definition.
  void reportEmptyStructDefinition({required SourceSpan span}) {
    report(EmptyStructDefinitionDiagnostic(span: span));
  }

  /// Reports a [LiteralValueCannotBeAssignedDiagnostic].
  ///
  /// This diagnostic occurs when a value of one type cannot be assigned to
  /// a literal declared with a different type.
  ///
  /// - Parameters:
  ///   - [valueTypeName]: The name of the type of the value being assigned.
  ///   - [valueKindName]: A description of the kind of value (e.g., "literal",
  /// "expression").
  ///   - [literalTypeName]: The name of the type declared for the literal.
  ///   - [valueSpan]: The [Span] of the value causing the type mismatch.
  ///   - [literalTypeSpan]: An optional [Span] indicating the literal's
  /// type declaration for additional context.
  void reportLiteralValueCannotBeAssigned({
    required String valueTypeName,
    required String valueKindName,
    required String literalTypeName,
    required SourceSpan valueSpan,
    SourceSpan? literalTypeSpan,
  }) {
    report(
      LiteralValueCannotBeAssignedDiagnostic(
        valueTypeName: valueTypeName,
        valueKindName: valueKindName,
        literalTypeName: literalTypeName,
        valueSpan: valueSpan,
        literalTypeSpan: literalTypeSpan,
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
  ///   - [span]: The [Span] of the list element with the type mismatch.
  void reportListElementTypeMismatch({
    required String expectedType,
    required String actualType,
    required SourceSpan span,
  }) {
    report(
      ListElementTypeMismatchDiagnostic(
        expectedType: expectedType,
        actualType: actualType,
        span: span,
      ),
    );
  }

  /// Reports a [KeywordAsIdentifierDiagnostic].
  ///
  /// This diagnostic is used when a reserved keyword of the language is
  /// erroneously used as an identifier (e.g., for a variable name).
  ///
  /// - Parameters:
  ///   - [identifier]: The reserved keyword that was used as an identifier.
  ///   - [span]: The [Span] where the keyword was used as an identifier.
  void reportKeywordAsIdentifier({
    required String identifier,
    required SourceSpan span,
  }) {
    report(KeywordAsIdentifierDiagnostic(identifier: identifier, span: span));
  }

  /// Reports an [UnsupportedListElementTypeDiagnostic].
  ///
  /// This diagnostic indicates that a list has been declared with an
  /// element type that is not supported by the language or the current
  /// compilation environment.
  ///
  /// - Parameters:
  ///   - [elementType]: The name of the unsupported element type.
  ///   - [span]: The [Span] where the unsupported list element type was
  ///     encountered.
  void reportUnsupportedListElementType({
    required String elementType,
    required SourceSpan span,
  }) {
    report(
      UnsupportedListElementTypeDiagnostic(
        elementType: elementType,
        span: span,
      ),
    );
  }

  /// Reports a [MapKeyTypeMismatchDiagnostic].
  ///
  /// This diagnostic is triggered when a key of one type cannot be assigned
  /// to a map entry declared with a different type.
  ///
  /// - Parameters:
  ///   - [expectedType]: The name of the type expected for the map key.
  ///   - [actualType]: The name of the type found for the map key.
  ///   - [span]: The [Span] of the map entry with the type mismatch.
  void reportMapKeyTypeMismatch({
    required String expectedType,
    required String actualType,
    required SourceSpan span,
  }) {
    report(
      MapKeyTypeMismatchDiagnostic(
        expectedType: expectedType,
        actualType: actualType,
        span: span,
      ),
    );
  }

  /// Reports a [MapValueTypeMismatchDiagnostic].
  ///
  /// This diagnostic is triggered when a value of one type cannot be assigned
  /// to a map entry declared with a different type.
  ///
  /// - Parameters:
  ///   - [expectedType]: The name of the type expected for the map entry.
  ///   - [actualType]: The name of the type found for the map entry.
  ///   - [span]: The [Span] of the map entry with the type mismatch.
  void reportMapValueTypeMismatch({
    required String expectedType,
    required String actualType,
    required SourceSpan span,
  }) {
    report(
      MapValueTypeMismatchDiagnostic(
        expectedType: expectedType,
        actualType: actualType,
        span: span,
      ),
    );
  }

  /// Reports a [RequiredFieldCannotHaveDefaultValueDiagnostic].
  ///
  /// This diagnostic is triggered when a field marked as `required` also
  /// has a default value, which is a contradiction in the language's
  /// semantics.
  ///
  /// - Parameters:
  ///   - [fieldName]: The name of the field that is required but has a default
  /// value.
  ///   - [span]: The [Span] where the error was detected.
  void reportRequiredFieldCannotHaveDefaultValue({
    required String fieldName,
    required SourceSpan span,
  }) {
    report(
      RequiredFieldCannotHaveDefaultValueDiagnostic(
        fieldName: fieldName,
        span: span,
      ),
    );
  }
}
