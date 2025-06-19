import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

void main() {
  group('DiagnosticSystem', () {
    late DiagnosticSystem ds;

    const filePath1 = '/path/to/file1.lake';
    const filePath2 = '/path/to/file2.lake';

    late Diagnostic d1;
    late Diagnostic d2;
    late Diagnostic d3;

    setUp(() {
      ds = DiagnosticSystem();

      d1 = const Diagnostic(
        message: 'Test diagnostic 1',
        span: (start: 0, end: 10),
        filePath: filePath1,
      );

      d2 = const Diagnostic(
        message: 'Test diagnostic 2',
        span: (start: 5, end: 15),
        filePath: filePath1,
      );

      d3 = const Diagnostic(
        message: 'Test diagnostic 3',
        span: (start: 0, end: 20),
        filePath: filePath2,
      );
    });

    test('report should add diagnostic to the correct file path', () {
      ds.report(d1);

      expect(ds.getDiagnosticsForFile(filePath1), contains(d1));
      expect(ds.getDiagnosticsForFile(filePath1).length, 1);
    });
    test('report should add multiple diagnostics to the same file path', () {
      ds
        ..report(d1)
        ..report(d2);

      expect(ds.getDiagnosticsForFile(filePath1).length, 2);
      expect(ds.getDiagnosticsForFile(filePath1), containsAll([d1, d2]));
    });

    test('report should add diagnostics to different file paths', () {
      ds
        ..report(d1)
        ..report(d3);

      expect(ds.getDiagnosticsForFile(filePath1).length, 1);
      expect(ds.getDiagnosticsForFile(filePath2).length, 1);
    });

    test(
      'clearDiagnosticsForFile should remove diagnostics for a specific file',
      () {
        ds
          ..report(d1)
          ..report(d3);

        expect(ds.getDiagnosticsForFile(filePath1), isNotEmpty);
        ds.clearDiagnosticsForFile(filePath1);
        expect(ds.getDiagnosticsForFile(filePath1), isEmpty);
        expect(ds.getDiagnosticsForFile(filePath2), contains(d3));
      },
    );

    test(
      'getDiagnosticsForFile should return an empty list if no diagnostics '
      'exist',
      () {
        expect(ds.getDiagnosticsForFile('/nonexistent/file.lake'), isEmpty);
      },
    );

    test(
      'getAllDiagnostics should return an unmodifiable map of all diagnostics',
      () {
        ds
          ..report(d1)
          ..report(d3);

        final allDiagnostics = ds.getAllDiagnostics();
        expect(allDiagnostics.length, 2);
        expect(allDiagnostics[filePath1], contains(d1));
        expect(allDiagnostics[filePath2], contains(d3));

        // Try to modify the returned map to ensure it's unmodifiable
        expect(() => allDiagnostics['newFile'] = [], throwsUnsupportedError);
      },
    );

    test('hasDiagnostics should return true if diagnostics exist', () {
      expect(ds.hasDiagnostics(), isFalse);
      ds.report(d1);
      expect(ds.hasDiagnostics(), isTrue);
    });

    test('hasDiagnostics should return false if no diagnostics exist', () {
      ds
        ..report(d1)
        ..clearAllDiagnostics();

      expect(ds.hasDiagnostics(), isFalse);
    });
  });
}
