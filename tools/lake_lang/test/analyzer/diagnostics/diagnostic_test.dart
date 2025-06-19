import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

void main() {
  group('Diagnostic', () {
    const testFilePath = '/home/user/project/src/main.lake';
    const span = (start: 5, end: 15);

    test('should be created with required parameters', () {
      const message = 'Test diagnostic';

      const diagnostic = Diagnostic(
        message: message,
        span: span,
        filePath: testFilePath,
      );

      expect(diagnostic.filePath, testFilePath);
      expect(diagnostic.message, message);
      expect(diagnostic.span, span);
      expect(diagnostic.severity, DiagnosticSeverity.error);
      expect(diagnostic.code, isNull);
      expect(diagnostic.labels, isEmpty);
    });

    test('should be created with all optional parameters', () {
      const literalTypeName = 'String';
      const literalTypeSpan = (start: 10, end: 20);
      const message = 'Test diagnostic with labels';
      const labelMessage = 'Literal declared here as "$literalTypeName"';

      const diagnostic = Diagnostic(
        message: message,
        span: span,
        filePath: testFilePath,
        severity: DiagnosticSeverity.warning,
        code: DiagnosticCode.duplicateDeclaration,
        labels: [
          (span: literalTypeSpan, message: labelMessage),
        ],
      );

      expect(diagnostic.filePath, equals(testFilePath));
      expect(diagnostic.message, equals(message));
      expect(diagnostic.span, equals(span));
      expect(diagnostic.severity, equals(DiagnosticSeverity.warning));
      expect(diagnostic.code, equals(DiagnosticCode.duplicateDeclaration));
      expect(diagnostic.labels.length, equals(1));

      final (span: lbSpan, message: lbMessage) = diagnostic.labels[0];

      expect(lbSpan, equals(literalTypeSpan));
      expect(lbMessage, equals(labelMessage));
    });

    test('labels should be an empty list by default', () {
      const message = 'Test diagnostic without labels';
      const diagnostic = Diagnostic(
        message: message,
        span: span,
        filePath: testFilePath,
      );

      expect(diagnostic.labels, isEmpty);
    });

    test('severity should default to error', () {
      const message = 'Test diagnostic with default severity';
      const diagnostic = Diagnostic(
        message: message,
        span: span,
        filePath: testFilePath,
      );

      expect(diagnostic.severity, equals(DiagnosticSeverity.error));
    });

    test('code should be null by default', () {
      const message = 'Test diagnostic with no code';
      const diagnostic = Diagnostic(
        message: message,
        span: span,
        filePath: testFilePath,
      );

      expect(diagnostic.code, isNull);
    });

    test('equality and hashCode for DiagnosticLabel', () {
      const label1 = (span: (start: 0, end: 5), message: 'Label 1');
      const label2 = (span: (start: 0, end: 5), message: 'Label 1');
      const label3 = (span: (start: 0, end: 10), message: 'Label 3');

      expect(label1, equals(label2));
      expect(label1.hashCode, equals(label2.hashCode));
      expect(label1, isNot(equals(label3)));
      expect(label1.hashCode, isNot(equals(label3.hashCode)));
    });
  });
}
