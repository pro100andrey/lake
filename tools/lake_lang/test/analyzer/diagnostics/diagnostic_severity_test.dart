import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

void main() {
  group('DiagnosticSeverity', () {
    test('should have correct display names', () {
      expect(DiagnosticSeverity.info.displayName, 'INFO');
      expect(DiagnosticSeverity.warning.displayName, 'WARNING');
      expect(DiagnosticSeverity.error.displayName, 'ERROR');
      expect(DiagnosticSeverity.fatal.displayName, 'FATAL');
    });

    test('should have correct priorities', () {
      expect(DiagnosticSeverity.info.priority, 1);
      expect(DiagnosticSeverity.warning.priority, 2);
      expect(DiagnosticSeverity.error.priority, 3);
      expect(DiagnosticSeverity.fatal.priority, 4);
    });

    test('toString should return display name', () {
      expect(DiagnosticSeverity.info.toString(), 'INFO');
      expect(DiagnosticSeverity.warning.toString(), 'WARNING');
      expect(DiagnosticSeverity.error.toString(), 'ERROR');
      expect(DiagnosticSeverity.fatal.toString(), 'FATAL');
    });

    test('priorities should be in ascending order of severity', () {
      expect(
        DiagnosticSeverity.info.priority,
        lessThan(DiagnosticSeverity.warning.priority),
      );
      expect(
        DiagnosticSeverity.warning.priority,
        lessThan(DiagnosticSeverity.error.priority),
      );
      expect(
        DiagnosticSeverity.error.priority,
        lessThan(DiagnosticSeverity.fatal.priority),
      );
    });
  });
}
