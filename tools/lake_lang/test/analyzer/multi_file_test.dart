import 'dart:io';
import 'package:lake_lang/src/analyzer/analysis_session.dart';
import 'package:test/test.dart';

void main() {
  group('AnalysisSession (Multi-file Resolution)', () {
    test('Successfully imports and resolves symbols from another file', () {
      final fileSystem = {
        'main.lake': File(
          'test/test_data/lake_sources/multi_file_test_12.lake',
        ).readAsStringSync(),
        'models.lake': File(
          'test/test_data/lake_sources/multi_file_test_11.lake',
        ).readAsStringSync(),
      };

      final session = AnalysisSession((path) {
        if (!fileSystem.containsKey(path)) {
          throw Exception('File not found: $path');
        }
        return fileSystem[path]!;
      })..analyzeProject('main.lake');

      final mainContext = session.getFile('main.lake')!;
      final modelsContext = session.getFile('models.lake')!;

      // No errors in models
      expect(modelsContext.reporter.hasErrors, isFalse);

      // No errors in main
      expect(mainContext.reporter.hasErrors, isFalse);

      // Check if User struct is available in main.lake's imported tables
      expect(mainContext.symbolTable.importedTables.length, equals(1));
      expect(
        mainContext.symbolTable.importedTables.first,
        equals(modelsContext.symbolTable),
      );
    });

    test('Reports error on missing imported file', () {
      final fileSystem = {
        'main.lake': File(
          'test/test_data/lake_sources/multi_file_test_10.lake',
        ).readAsStringSync(),
      };

      final session = AnalysisSession((path) {
        if (!fileSystem.containsKey(path)) {
          throw Exception('File not found: $path');
        }
        return fileSystem[path]!;
      })..analyzeProject('main.lake');

      final mainContext = session.getFile('main.lake')!;
      expect(mainContext.reporter.hasErrors, isTrue);

      final errors = mainContext.reporter.diagnostics;
      expect(errors.length, equals(1));
      expect(
        errors.first.message,
        contains('Could not load imported file "missing.lake"'),
      );
    });

    test('Reports error on circular imports', () {
      final fileSystem = {
        'a.lake': File(
          'test/test_data/lake_sources/multi_file_test_9.lake',
        ).readAsStringSync(),
        'b.lake': File(
          'test/test_data/lake_sources/multi_file_test_8.lake',
        ).readAsStringSync(),
      };

      final session = AnalysisSession((path) {
        if (!fileSystem.containsKey(path)) {
          throw Exception('File not found: $path');
        }
        return fileSystem[path]!;
      })..analyzeProject('a.lake');

      final bContext = session.getFile('b.lake')!;
      expect(bContext.reporter.hasErrors, isTrue);

      final errors = bContext.reporter.diagnostics;
      expect(errors.length, equals(1));
      expect(
        errors.first.message,
        contains('Circular import detected: a.lake -> b.lake -> a.lake'),
      );
    });
  });
}
