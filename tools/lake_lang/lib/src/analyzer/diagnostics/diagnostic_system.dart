import 'diagnostic.dart';

/// Manages and provides access to diagnostics (errors, warnings, hints).
final class DiagnosticSystem {
  // Map of file paths to a list of diagnostics for that file.
  final Map<String, List<Diagnostic>> _fileDiagnostics = {};

  /// Reports a new diagnostic.
  void report(Diagnostic diagnostic) {
    _fileDiagnostics.putIfAbsent(diagnostic.filePath, () => []).add(diagnostic);
  }

  /// Clears all diagnostics for a specific file.
  /// This should be called before re-analyzing a file.
  void clearDiagnosticsForFile(String filePath) {
    _fileDiagnostics.remove(filePath);
  }

  /// Clears all diagnostics for all files.
  void clearAllDiagnostics() {
    _fileDiagnostics.clear();
  }

  /// Retrieves all diagnostics for a given file path.
  /// Returns an empty list if no diagnostics exist for the file.
  List<Diagnostic> getDiagnosticsForFile(String filePath) =>
      _fileDiagnostics[filePath] ?? const [];

  /// Retrieves all diagnostics for all files.
  Map<String, List<Diagnostic>> getAllDiagnostics() =>
      Map.unmodifiable(_fileDiagnostics);

  /// Checks if there are any diagnostics found in the system.
  bool hasDiagnostics() => _fileDiagnostics.isNotEmpty;
}
