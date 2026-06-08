import 'package:source_span/source_span.dart';

import '../../ast/base/types.dart';

/// Represents an additional label for a specific part of the code
/// that provides context to a diagnostic message.
///
/// This typedef is used within [Diagnostic] to highlight secondary locations
/// in the source code that are relevant to the primary diagnostic message.
///
/// Fields:
/// - `span`: The [Span] indicating the exact location in the code.
/// - `message`: A concise message explaining the context of this label.
///
/// Example:
/// ```dart
/// DiagnosticLabel myLabel = (
///   span: mySourceFile.span(10, 20),
///   message: 'This is related to the error'
/// );
/// ```
typedef DiagnosticLabel = ({SourceSpan span, String message});

/// Enum defining the severity level of a diagnostic message.
///
/// Diagnostics can range from informational hints to fatal errors that
/// prevent compilation. Each severity level has a display name and a priority
/// for sorting or filtering.
enum DiagnosticSeverity {
  /// Informational message, e.g., a hint.
  /// Typically does not indicate a problem, but provides useful information.
  info('INFO', 1),

  /// A warning that doesn't stop compilation but indicates a potential issue.
  /// Code may run, but with potential unexpected behavior or inefficiencies.
  warning('WARNING', 2),

  /// An error that prevents successful compilation.
  /// The code cannot be executed until this error is resolved.
  error('ERROR', 3),

  /// A fatal error that makes further compilation impossible or meaningless.
  /// Often indicates an unrecoverable state or a critical internal issue.
  fatal('FATAL', 4);

  /// Private constructor for [DiagnosticSeverity]
  const DiagnosticSeverity(this.displayName, this.priority);

  /// The human-readable name of the severity.
  final String displayName;

  /// A numerical priority for sorting or filtering diagnostics.
  /// Higher numbers typically indicate higher urgency.
  final int priority;

  @override
  String toString() => displayName;
}

/// Enum defining unique codes for different types of diagnostic messages.
///
/// Each code is associated with a specific error, warning, or hint, and
/// provides a list of actionable suggestions to resolve the issue.
enum DiagnosticCode {
  /// Error code for literal value assignment issues.
  ///
  /// This occurs when a value cannot be assigned to a literal because of a
  /// type mismatch.
  literalValueCannotBeAssigned('E1001', [
    'Ensure the literal value matches the declared type.',
    'Change the declared type to match the value.',
  ]),

  /// Error code for duplicate declarations of a symbol.
  ///
  /// This occurs when a symbol (e.g., variable, method, class) is declared
  /// more than once in the same scope.
  duplicateDeclaration('E1002', [
    'Rename one of the declarations.',
    'Remove the duplicate declaration.',
  ]),

  /// Error code for undefined symbols.
  ///
  /// This occurs when a symbol is used but has not been declared or is not
  /// accessible within the current scope.
  undefinedSymbol('E1003', [
    'Declare the symbol before using it.',
    'Check for typos in the symbol name.',
    'Ensure the symbol is in scope.',
    'Import the necessary lake files.',
  ]),

  /// Error code for empty enum definitions.
  ///
  /// This occurs when an enum is defined without any members.
  emptyEnumDefinition('E1004', [
    'Add at least one value to the enum.',
    'Consider removing the enum if it is not needed.',
  ]),

  /// Error code for empty struct definitions.
  ///
  /// This occurs when a struct is defined without any fields.
  emptyStructDefinition('E1005', [
    'Add at least one field to the struct.',
    'Consider removing the struct if it is not needed.',
  ]),

  /// Error code for invalid identifier names.
  ///
  /// This occurs when a reserved keyword is used as an identifier
  keywordAsIdentifier('E1006', [
    'Rename the identifier to avoid using reserved keywords',
  ]),

  /// Error code for list element type mismatches.
  ///
  /// This occurs when elements within a list do not conform to a consistent
  /// or expected type.
  listElementTypeMismatch('E1007', [
    'Ensure all list elements are of the same type.',
    'Check the type of each element in the list.',
  ]),

  /// Error code for unsupported list element types.
  ///
  /// This occurs when an attempt is made to use a type as a list element
  /// that is not supported by the language or context.
  unsupportedListElementType('E1008', [
    'Use a supported type like i32, bool, or string as list elements.',
    'Check the language documentation for supported list element types.',
  ]),

  /// Error code for map key type mismatches.
  ///
  /// This occurs when the key type of a map entry does not match the
  /// declared type for that map.
  mapKeyTypeMismatch('E1009', [
    'Ensure the map entry key matches the declared type.',
    'Change the declared type to match the key.',
  ]),

  /// Error code for map value type mismatches.
  ///
  /// This occurs when the value type of a map entry does not match the
  /// declared type for that map.
  mapValueTypeMismatch('E1010', [
    'Ensure the map entry value matches the declared type.',
    'Change the declared type to match the value.',
  ]),

  /// Error code for required fields that cannot have default values.
  ///
  /// This occurs when a field is marked as required but also has a default
  /// value, which is contradictory.
  requiredFieldCannotHaveDefaultValue('E1011', [
    'Remove the default value from the required field.',
    'Consider making the field optional if a default value is needed.',
  ]);

  /// Creates a [DiagnosticCode] instance.
  ///
  /// - Parameters:
  ///   - [id]: The unique string identifier for the diagnostic
  /// (e.g., "E1001").
  ///   - [suggestions]: A list of actionable suggestions to resolve the issue.
  const DiagnosticCode(this.id, this.suggestions);

  /// The unique string identifier for the diagnostic (e.g., "E1001").
  final String id;

  /// A list of actionable suggestions to help the user resolve the diagnostic.
  final List<String> suggestions;

  /// An optional URL pointing to more detailed help documentation.
  /// This link can guide users to comprehensive explanations and examples.
  String? get helpLink => 'https://lake.org/docs/diagnostic/$id';
}

/// Base class for all semantic diagnostics (errors, warnings, hints).
///
/// This abstract class provides the common structure for all diagnostic
/// messages generated by the Lake language compiler/analyzer. It includes
/// information about the primary location of the issue, a descriptive message,
/// severity, an optional unique code, and additional contextual information.
sealed class Diagnostic {
  /// Creates a new [Diagnostic] instance.
  ///
  /// - Parameters:
  ///   - [span]: The main location in the source code where the diagnostic
  /// originates. This is the most important piece of location information.
  ///   - [message]: The main message describing the diagnostic, intended to be
  /// user-friendly and actionable.
  ///   - [severity]: The [DiagnosticSeverity] of the diagnostic, defaulting to
  /// [DiagnosticSeverity.error] if not specified.
  ///   - [code]: An optional unique code for the diagnostic (e.g., "E1001",
  /// "W2001"). Useful for programmatic identification and documentation links.
  ///   - [labels]: A list of additional [DiagnosticLabel]s providing context
  /// to parts of the code related to the primary span. Defaults to an empty
  /// list.
  const Diagnostic({
    required this.span,
    required this.message,
    this.severity = DiagnosticSeverity.error,
    this.code,
    this.labels = const [],
  });

  /// The main location in the source code where the diagnostic originates.
  /// This is typically the most relevant part of the code for the issue.
  final SourceSpan span;

  /// The main message describing the diagnostic.
  /// This message should be clear and concise, explaining what went wrong.
  final String message;

  /// The severity of the diagnostic (e.g., error, warning, info, fatal).
  /// Determines how the diagnostic should be presented to the user and its
  /// impact on compilation.
  final DiagnosticSeverity severity;

  /// An optional unique code for the diagnostic (e.g., "E1001", "W2001").
  /// This allows users to look up more information about a specific issue.
  final DiagnosticCode? code;

  /// A list of additional [DiagnosticLabel]s providing context.
  /// These labels highlight other relevant parts of the code that contribute
  /// to the diagnostic message.
  final List<DiagnosticLabel> labels;
}

/// Generic diagnostic for general errors, warnings, or info messages.
///
/// This class can be used when a specific, highly specialized diagnostic
/// class is not warranted. It allows for flexible creation of messages
/// with customizable severity and details.
final class GenericDiagnostic extends Diagnostic {
  /// Creates a [GenericDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [message]: The main diagnostic message.
  ///   - [span]: The primary [SourceSpan] for this diagnostic.
  ///   - [severity]: The severity level. Defaults to
  /// [DiagnosticSeverity.error].
  ///   - [code]: An optional diagnostic code.
  ///   - [labels]: Additional contextual labels.
  const GenericDiagnostic({
    required super.message,
    required super.span,
    required super.severity,
    required super.labels,
    super.code,
  });
}

/// Diagnostic for when a value of one type cannot be assigned to a literal
/// declared with a different type.
///
/// This error (E1001) occurs during semantic analysis when there is a type
/// mismatch in a literal assignment.
final class LiteralValueCannotBeAssignedDiagnostic extends Diagnostic {
  /// Creates a [LiteralValueCannotBeAssignedDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [valueTypeName]: The name of the type of the value being assigned
  /// (e.g., "string").
  ///   - [valueKindName]: A description of the kind of value (e.g., "literal",
  /// "expression").
  ///   - [literalTypeName]: The name of the type declared for the literal
  /// (e.g., "i32").
  ///   - [valueSpan]: The [SourceSpan] of the value that is causing the type
  /// mismatch.
  ///   - [literalTypeSpan]: An optional [SourceSpan] indicating the location
  /// where the literal's type was declared, providing additional context.
  LiteralValueCannotBeAssignedDiagnostic({
    required String valueTypeName,
    required String valueKindName,
    required String literalTypeName,
    required SourceSpan valueSpan,
    SourceSpan? literalTypeSpan,
  }) : super(
         span: valueSpan,
         message:
             'Cannot assign a value of type "$valueTypeName" ($valueKindName) '
             'to a literal of type "$literalTypeName".',
         code: DiagnosticCode.literalValueCannotBeAssigned,
         labels: [
           if (literalTypeSpan != null)
             (
               span: literalTypeSpan,
               message: 'Literal declared here as "$literalTypeName"',
             ),
         ],
       );
}

/// Diagnostic for a duplicate declaration of a symbol.
///
/// This error (E1002) occurs when a symbol (like a variable, struct, or enum
/// name) is declared more than once in the same scope.
final class DuplicateDeclarationDiagnostic extends Diagnostic {
  /// Creates a [DuplicateDeclarationDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [name]: The name of the symbol that is duplicated.
  ///   - [span]: The [SourceSpan] of the current, duplicate declaration.
  ///   - [previousDeclarationSpan]: An optional [SourceSpan] indicating the
  /// location of the original declaration of the symbol, providing helpful
  /// context.
  DuplicateDeclarationDiagnostic({
    required String name,
    required super.span,
    required SourceSpan previousDeclarationSpan,
  }) : super(
         message: 'A symbol named "$name" is already declared in this scope.',
         code: DiagnosticCode.duplicateDeclaration,
         labels: [
           (
             span: previousDeclarationSpan,
             message: 'Previous declaration of "$name" was here',
           ),
         ],
       );
}

/// Diagnostic for an undefined symbol.
///
/// This error (E1003) occurs when a symbol is used in the code but has not
/// been declared or is not in scope.
final class UndefinedSymbolDiagnostic extends Diagnostic {
  // Creates an [UndefinedSymbolDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [name]: The name of the undefined symbol.
  ///   - [span]: The [SourceSpan] where the undefined symbol was used.
  const UndefinedSymbolDiagnostic({
    required String name,
    required super.span,
  }) : super(
         message: 'Undefined symbol: "$name".',
         code: DiagnosticCode.undefinedSymbol,
       );
}

/// Diagnostic for an empty enum definition.
///
/// This error (E1004) occurs when an enum is defined without any members.
final class EmptyEnumDefinitionDiagnostic extends Diagnostic {
  /// Creates an [EmptyEnumDefinitionDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [span]: The [SourceSpan] of the empty enum definition.
  const EmptyEnumDefinitionDiagnostic({required super.span})
    : super(
        message:
            'Enum definition cannot be empty. '
            'Enums must have at least one member.',
        code: DiagnosticCode.emptyEnumDefinition,
      );
}

/// Diagnostic for an empty struct definition.
///
/// This error (E1005) occurs when a struct is defined without any fields.
final class EmptyStructDefinitionDiagnostic extends Diagnostic {
  /// Creates an [EmptyStructDefinitionDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [span]: The [SourceSpan] of the empty struct definition
  const EmptyStructDefinitionDiagnostic({required super.span})
    : super(
        message:
            'Struct definition cannot be empty. '
            'Structs must have at least one field.',
        code: DiagnosticCode.emptyStructDefinition,
      );
}

/// Diagnostic for using a reserved keyword as an identifier.
///
/// This error (E1006) occurs when a programmer attempts to use a word that
/// is reserved by the language (e.g., `if`, `for`, `class`) as a name for
/// a variable, method, or other identifier.
final class KeywordAsIdentifierDiagnostic extends Diagnostic {
  /// Creates a [KeywordAsIdentifierDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [identifier]: The reserved keyword that was used as an identifier.
  ///   - [span]: The [SourceSpan] where the keyword was used as an identifier.
  const KeywordAsIdentifierDiagnostic({
    required String identifier,
    required super.span,
  }) : super(
         message:
             'Invalid identifier name: "$identifier" '
             'is a reserved keyword.',
         code: DiagnosticCode.keywordAsIdentifier,
       );
}

/// Diagnostic for a list element type mismatch.
///
/// This error (E1007) occurs when an element in a list has a type that does
/// not match the expected type for that list.
final class ListElementTypeMismatchDiagnostic extends Diagnostic {
  /// Creates a [ListElementTypeMismatchDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [expectedType]: The expected type for the list elements.
  ///   - [actualType]: The actual type found for the list element.
  ///   - [span]: The [SourceSpan] of the list element causing the mismatch.
  const ListElementTypeMismatchDiagnostic({
    required String expectedType,
    required String actualType,
    required super.span,
  }) : super(
         message:
             'List element type mismatch: expected "$expectedType", '
             'but found "$actualType".',
         code: DiagnosticCode.listElementTypeMismatch,
       );
}

/// Diagnostic for an unsupported list element type.
///
/// This error (E1008) occurs when a list is defined with an element type
/// that is not supported by the language or the current context.
final class UnsupportedListElementTypeDiagnostic extends Diagnostic {
  /// Creates an [UnsupportedListElementTypeDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [elementType]: The name of the unsupported element type.
  ///   - [span]: The [SourceSpan] of the unsupported list element type.
  const UnsupportedListElementTypeDiagnostic({
    required String elementType,
    required super.span,
  }) : super(
         message:
             'Unsupported list element type: "$elementType". '
             'Only primitive types like i32, bool, and string are supported.',
         code: DiagnosticCode.unsupportedListElementType,
       );
}

/// Diagnostic for a map key type mismatch.
/// This error (E1009) occurs when the key type of a map entry does not match
/// the declared type for that map.
final class MapKeyTypeMismatchDiagnostic extends Diagnostic {
  /// Creates a [MapKeyTypeMismatchDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [expectedType]: The expected type for the map keys.
  ///   - [actualType]: The actual type found for the map key.
  ///   - [span]: The [SourceSpan] of the map key causing the mismatch.
  const MapKeyTypeMismatchDiagnostic({
    required String expectedType,
    required String actualType,
    required super.span,
  }) : super(
         message:
             'Map key type mismatch: expected "$expectedType", '
             'but found "$actualType".',
         code: DiagnosticCode.mapKeyTypeMismatch,
       );
}

/// Diagnostic for a map value type mismatch.
/// This error (E1010) occurs when the value type of a map entry does not match
/// the declared type for that map.

final class MapValueTypeMismatchDiagnostic extends Diagnostic {
  /// Creates a [MapValueTypeMismatchDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [expectedType]: The expected type for the map values.
  ///   - [actualType]: The actual type found for the map value.
  ///   - [span]: The [SourceSpan] of the map value causing the mismatch.
  const MapValueTypeMismatchDiagnostic({
    required String expectedType,
    required String actualType,
    required super.span,
  }) : super(
         message:
             'Map value type mismatch: expected "$expectedType", '
             'but found "$actualType".',
         code: DiagnosticCode.mapValueTypeMismatch,
       );
}

/// Diagnostic for a required field that cannot have a default value.
/// This error (E1011) occurs when a field in a struct is marked as required
/// but also has a default value, which is contradictory to the semantics of
/// required fields in the Lake language.
final class RequiredFieldCannotHaveDefaultValueDiagnostic extends Diagnostic {
  /// Creates a [RequiredFieldCannotHaveDefaultValueDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [fieldName]: The name of the field that is required.
  ///   - [span]: The [SourceSpan] of the field declaration.
  const RequiredFieldCannotHaveDefaultValueDiagnostic({
    required String fieldName,
    required super.span,
  }) : super(
         message: 'A required field "$fieldName" cannot have a default value.',
         code: DiagnosticCode.requiredFieldCannotHaveDefaultValue,
       );
}
