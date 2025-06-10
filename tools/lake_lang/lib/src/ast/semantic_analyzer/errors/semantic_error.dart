import 'package:source_span/source_span.dart';

/// Represents an additional label for a specific part of the code
/// that provides context to a diagnostic message.
typedef DiagnosticLabel = ({SourceSpan span, String message});

/// Enum defining the severity level of a diagnostic message.
enum DiagnosticSeverity {
  /// Informational message, e.g., a hint.
  info('INFO', 1),

  /// A warning that doesn't stop compilation but indicates a potential issue.
  warning('WARNING', 2),

  /// An error that prevents successful compilation
  error('ERROR', 3),

  /// A fatal error that makes further compilation impossible or meaningless.
  fatal('FATAL', 4);

  const DiagnosticSeverity(this.displayName, this.priority);

  /// The human-readable name of the severity.
  final String displayName;

  /// A numerical priority for sorting or filtering diagnostics.
  final int priority;

  @override
  String toString() => displayName;
}

/// Base class for all semantic diagnostics (errors, warnings, hints).
abstract base class Diagnostic {
  const Diagnostic({
    required this.primarySpan,
    required this.message,
    this.severity = DiagnosticSeverity.error,
    this.code,
    this.labels = const [],
    this.suggestions = const [],
    this.helpLink,
  });

  /// The main location in the source code where the diagnostic originates.
  final SourceSpan primarySpan;

  /// The main message describing the diagnostic
  final String message;

  /// The severity of the diagnostic (e.g., error, warning)
  final DiagnosticSeverity severity;

  /// An optional unique code for the diagnostic (e.g., "E1001").
  final String? code;

  /// A list of additional [DiagnosticLabel]s providing context.
  final List<DiagnosticLabel> labels;

  /// A list of suggested code changes or hints to fix the issue
  final List<String> suggestions;

  /// An optional URL pointing to more detailed help documentation.
  final String? helpLink;
}

/// Generic diagnostic for general errors, warnings, or info messages.
final class GenericDiagnostic extends Diagnostic {
  const GenericDiagnostic(
    String message,
    SourceSpan span, {
    super.severity,
    super.code,
    super.labels,
    super.suggestions,
    super.helpLink,
  }) : super(
         primarySpan: span,
         message: message,
       );
}

final class ValueCannotBeAssignedDiagnostic extends Diagnostic {
  ValueCannotBeAssignedDiagnostic({
    required String valueTypeName,
    required String valueKindName,
    required String constTypeName,
    required SourceSpan valueSpan,
    SourceSpan? constTypeSpan,
  }) : super(
         primarySpan: valueSpan,
         message:
             'Cannot assign a value of type "$valueTypeName" ($valueKindName) '
             'to a constant of type "$constTypeName".',
         code: 'E1001',
         labels: constTypeSpan != null
             ? [
                 (
                   span: constTypeSpan,
                   message: 'Constant declared here as "$constTypeName"',
                 ),
               ]
             : [],
         suggestions: const [
           'Ensure the constant value matches the declared type.',
           'Change the declared type to match the value.',
         ],
         helpLink: 'https://lakelang.org/docs/errors/E1001',
       );
}

/// Diagnostic for a duplicate declaration.
final class DuplicateDeclarationDiagnostic extends Diagnostic {
  DuplicateDeclarationDiagnostic(
    String name,
    SourceSpan span,
    SourceSpan? previousDeclarationSpan,
  ) : super(
        primarySpan: span,
        message: 'A symbol named "$name" is already declared in this scope.',
        code: 'E1002',
        labels: previousDeclarationSpan != null
            ? [
                (
                  span: previousDeclarationSpan,
                  message: 'Previous declaration of "$name" was here',
                ),
              ]
            : [],
        suggestions: const [
          'Rename this declaration.',
          'Remove the duplicate declaration.',
        ],
        helpLink: 'https://lakelang.org/docs/errors/E1002',
      );
}

/// Diagnostic for an undefined symbol.
final class UndefinedSymbolDiagnostic extends Diagnostic {
  const UndefinedSymbolDiagnostic(String name, SourceSpan span)
    : super(
        primarySpan: span,
        message: 'Undefined symbol: "$name".',
        code: 'E1003',
        suggestions: const [
          'Check for typos or declare the symbol before use.',
        ],
        helpLink: 'https://lakelang.org/docs/errors/E1003',
      );
}

/// Diagnostic for an empty enum definition.
final class EmptyEnumDefinitionDiagnostic extends Diagnostic {
  const EmptyEnumDefinitionDiagnostic(SourceSpan span)
    : super(
        primarySpan: span,
        message:
            'Enum definition cannot be empty. '
            'Enums must have at least one member.',
        code: 'E1004',
        suggestions: const [
          'Add at least one member to the enum.',
          'Remove the empty enum definition.',
        ],
      );
}

/// Diagnostic for an empty struct definition.
final class EmptyStructDefinitionDiagnostic extends Diagnostic {
  const EmptyStructDefinitionDiagnostic(SourceSpan span)
    : super(
        primarySpan: span,
        message:
            'Struct definition cannot be empty. '
            'Structs must have at least one field.',
        code: 'E1005',
        suggestions: const [
          'Add at least one field to the struct.',
          'Remove the empty struct definition.',
        ],
      );
}

final class ListElementTypeMismatchDiagnostic extends Diagnostic {
  const ListElementTypeMismatchDiagnostic(
    String expectedType,
    String actualType,
    SourceSpan span,
  ) : super(
        primarySpan: span,
        message:
            'List element type mismatch: expected "$expectedType", '
            'but found "$actualType".',
        code: 'E1007',
        suggestions: const [
          'Ensure all list elements are of the same type.',
          'Check the type of each element in the list.',
        ],
        helpLink: 'https://lakelang.org/docs/errors/E1007',
      );
}

final class UnsupportedListElementTypeDiagnostic extends Diagnostic {
  const UnsupportedListElementTypeDiagnostic(
    String elementType,
    SourceSpan span,
  ) : super(
        primarySpan: span,
        message:
            'Unsupported list element type: "$elementType". '
            'Only primitive types like i32, bool, and string are supported.',
        code: 'E1010',
        suggestions: const [
          'Use a supported type like i32, bool, or string.',
        ],
      );
}

/// Diagnostic for using a deprecated feature.
final class DeprecatedFeatureDiagnostic extends Diagnostic {
  const DeprecatedFeatureDiagnostic(
    String featureName,
    SourceSpan span,
    String deprecationReason,
  ) : super(
        primarySpan: span,
        message: 'Deprecated feature used: "$featureName". $deprecationReason',
        severity: DiagnosticSeverity.warning,
        code: 'W2001',
        suggestions: const [
          'Consider updating to the recommended alternative.',
        ],
      );
}

// 'Invalid identifier name: "${node.value}" is a reserved keyword.',

final class InvalidIdentifierNameDiagnostic extends Diagnostic {
  const InvalidIdentifierNameDiagnostic(String identifier, SourceSpan span)
    : super(
        primarySpan: span,
        message:
            'Invalid identifier name: "$identifier" '
            'is a reserved keyword.',
        code: 'E1006',
        suggestions: const [
          'Rename the identifier to avoid using reserved keywords.',
        ],
        helpLink: 'https://lakelang.org/docs/errors/E1006',
      );
}
