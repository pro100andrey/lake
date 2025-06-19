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
