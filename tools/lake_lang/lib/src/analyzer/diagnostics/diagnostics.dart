/// @docImport 'diagnostic_severity.dart';
library;

import 'package:source_span/source_span.dart' show SourceSpan;

import '../../common/span.dart';
import 'diagnostic.dart';
import 'diagnostic_code.dart';

/// Generic diagnostic for general errors, warnings, or info messages.
///
/// This class can be used when a specific, highly specialized diagnostic
/// class is not warranted. It allows for flexible creation of messages
/// with customizable severity and details.
final class GenericDiagnostic extends Diagnostic {
  /// @docImport 'diagnostic_severity.dart';
  /// Creates a [GenericDiagnostic] instance.
  ///
  /// - Parameters:
  ///   - [message]: The main diagnostic message.
  ///   - [span]: The primary [Span] for this diagnostic.
  ///   - [severity]: The severity level. Defaults to
  /// [DiagnosticSeverity.error].
  ///   - [code]: An optional diagnostic code.
  ///   - [labels]: Additional contextual labels.
  const GenericDiagnostic({
    required super.filePath,
    required super.message,
    required super.span,
    super.labels,
    super.severity,
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
  ///   - [valueSpan]: The [Span] of the value that is causing the type
  /// mismatch.
  ///   - [literalTypeSpan]: An optional [Span] indicating the location
  /// where the literal's type was declared, providing additional context.
  LiteralValueCannotBeAssignedDiagnostic({
    required String valueTypeName,
    required String valueKindName,
    required String literalTypeName,
    required Span valueSpan,
    required super.filePath,
    Span? literalTypeSpan,
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
    required Span previousDeclarationSpan,
    required super.filePath,
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
  ///   - [span]: The [Span] where the undefined symbol was used.
  const UndefinedSymbolDiagnostic({
    required String name,
    required super.span,
    required super.filePath,
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
  ///   - [span]: The [Span] of the empty enum definition.
  const EmptyEnumDefinitionDiagnostic({
    required super.span,
    required super.filePath,
  }) : super(
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
  const EmptyStructDefinitionDiagnostic({
    required super.span,
    required super.filePath,
  }) : super(
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
    required super.filePath,
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
    required super.filePath,
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
    required super.filePath,
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
    required super.filePath,
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
    required super.filePath,
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
    required super.filePath,
  }) : super(
         message: 'A required field "$fieldName" cannot have a default value.',
         code: DiagnosticCode.requiredFieldCannotHaveDefaultValue,
       );
}
