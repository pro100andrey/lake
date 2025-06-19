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
