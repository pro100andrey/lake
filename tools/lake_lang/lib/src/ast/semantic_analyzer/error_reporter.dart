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

  void printErrors() {
    if (_errors.isEmpty) {
      // ignore: avoid_print
      print('No semantic errors found.');
      return;
    }

    // ignore: avoid_print
    print('Semantic Errors:');
    for (final error in _errors) {
      // ignore: avoid_print
      print(
        '${error.span.start.line + 1}:${error.span.start.column + 1} - '
        '${error.message} \n'
        '${error.span.highlight()}\n',
      );
    }
  }
}
