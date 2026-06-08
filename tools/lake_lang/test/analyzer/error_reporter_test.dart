import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/errors/semantic_error.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorReporter', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('initially has no diagnostics', () {
      expect(reporter.diagnostics, isEmpty);
    });

    test('hasErrors is false when no diagnostics', () {
      expect(reporter.hasErrors, isFalse);
    });

    test('hasErrors is false when only warnings reported', () {
      reporter.reportGeneric(
        message: 'just a warning',
        startOffset: 0,
        endOffset: 5,
        severity: DiagnosticSeverity.warning,
      );
      expect(reporter.hasErrors, isFalse);
    });

    test('hasErrors is false when only info reported', () {
      reporter.reportGeneric(
        message: 'info message',
        startOffset: 0,
        endOffset: 5,
        severity: DiagnosticSeverity.info,
      );
      expect(reporter.hasErrors, isFalse);
    });

    test('hasErrors is true when error reported', () {
      reporter.reportGeneric(
        message: 'an error',
        startOffset: 0,
        endOffset: 5,
      );
      expect(reporter.hasErrors, isTrue);
    });

    test('hasErrors is true when fatal reported', () {
      reporter.report(
        const GenericDiagnostic(
          message: 'fatal issue',
          startOffset: 0,
          endOffset: 5,
          severity: DiagnosticSeverity.fatal,
          labels: [],
        ),
      );
      expect(reporter.hasErrors, isTrue);
    });

    test('diagnostics returns unmodifiable list', () {
      reporter.reportGeneric(
        message: 'test',
        startOffset: 0,
        endOffset: 1,
      );
      final diags = reporter.diagnostics;
      expect(diags, hasLength(1));
      expect(
        () => diags.add(
          const GenericDiagnostic(
            message: 'x',
            startOffset: 0,
            endOffset: 1,
            severity: DiagnosticSeverity.error,
            labels: [],
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('report() adds diagnostic to list', () {
      const diag = GenericDiagnostic(
        message: 'hello',
        startOffset: 0,
        endOffset: 3,
        severity: DiagnosticSeverity.error,
        labels: [],
      );
      reporter.report(diag);
      expect(reporter.diagnostics, hasLength(1));
      expect(reporter.diagnostics.first, same(diag));
    });

    group('convenience methods', () {
      test('reportGeneric() creates GenericDiagnostic', () {
        reporter.reportGeneric(
          message: 'generic msg',
          startOffset: 10,
          endOffset: 20,
        );
        expect(reporter.diagnostics, hasLength(1));
        final d = reporter.diagnostics.first;
        expect(d, isA<GenericDiagnostic>());
        expect(d.message, 'generic msg');
        expect(d.startOffset, 10);
        expect(d.endOffset, 20);
        expect(d.severity, DiagnosticSeverity.error);
      });

      test(
        'reportDuplicateDeclaration() creates DuplicateDeclarationDiagnostic',
        () {
          reporter.reportDuplicateDeclaration(
            name: 'Foo',
            startOffset: 10,
            endOffset: 13,
            prevStart: 0,
            prevEnd: 3,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<DuplicateDeclarationDiagnostic>());
          expect(d.message, contains('Foo'));
          expect(d.code, DiagnosticCode.duplicateDeclaration);
          expect(d.labels, hasLength(1));
          expect(d.labels.first.message, contains('Previous declaration'));
        },
      );

      test('reportUndefinedSymbol() creates UndefinedSymbolDiagnostic', () {
        reporter.reportUndefinedSymbol(
          name: 'bar',
          startOffset: 5,
          endOffset: 8,
        );
        expect(reporter.diagnostics, hasLength(1));
        final d = reporter.diagnostics.first;
        expect(d, isA<UndefinedSymbolDiagnostic>());
        expect(d.message, contains('bar'));
        expect(d.code, DiagnosticCode.undefinedSymbol);
      });

      test(
        'reportEmptyEnumDefinition() creates EmptyEnumDefinitionDiagnostic',
        () {
          reporter.reportEmptyEnumDefinition(startOffset: 0, endOffset: 10);
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<EmptyEnumDefinitionDiagnostic>());
          expect(d.message, contains('Enum definition cannot be empty'));
          expect(d.code, DiagnosticCode.emptyEnumDefinition);
        },
      );

      test(
        'reportEmptyStructDefinition() creates EmptyStructDefinitionDiagnostic',
        () {
          reporter.reportEmptyStructDefinition(startOffset: 0, endOffset: 10);
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<EmptyStructDefinitionDiagnostic>());
          expect(d.message, contains('Struct definition cannot be empty'));
          expect(d.code, DiagnosticCode.emptyStructDefinition);
        },
      );

      test(
        'reportLiteralValueCannotBeAssigned() creates '
        'LiteralValueCannotBeAssignedDiagnostic',
        () {
          reporter.reportLiteralValueCannotBeAssigned(
            valueTypeName: 'StringLiteralNode',
            valueKindName: 'literal',
            literalTypeName: 'i32',
            startOffset: 10,
            endOffset: 20,
            literalTypeStart: 5,
            literalTypeEnd: 8,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<LiteralValueCannotBeAssignedDiagnostic>());
          expect(d.message, contains('Cannot assign'));
          expect(d.code, DiagnosticCode.literalValueCannotBeAssigned);
          // Should have label for declared type location
          expect(d.labels, hasLength(1));
        },
      );

      test(
        'reportLiteralValueCannotBeAssigned() without '
        'literalTypeSpan has no labels',
        () {
          reporter.reportLiteralValueCannotBeAssigned(
            valueTypeName: 'StringLiteralNode',
            valueKindName: 'literal',
            literalTypeName: 'i32',
            startOffset: 10,
            endOffset: 20,
          );
          final d = reporter.diagnostics.first;
          expect(d.labels, isEmpty);
        },
      );

      test(
        'reportKeywordAsIdentifier() creates KeywordAsIdentifierDiagnostic',
        () {
          reporter.reportKeywordAsIdentifier(
            identifier: 'struct',
            startOffset: 0,
            endOffset: 6,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<KeywordAsIdentifierDiagnostic>());
          expect(d.message, contains('struct'));
          expect(d.message, contains('reserved keyword'));
          expect(d.code, DiagnosticCode.keywordAsIdentifier);
        },
      );

      test(
        'reportListElementTypeMismatch() creates '
        'ListElementTypeMismatchDiagnostic',
        () {
          reporter.reportListElementTypeMismatch(
            expectedType: 'i32',
            actualType: 'StringLiteralNode',
            startOffset: 0,
            endOffset: 5,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<ListElementTypeMismatchDiagnostic>());
          expect(d.message, contains('i32'));
          expect(d.code, DiagnosticCode.listElementTypeMismatch);
        },
      );

      test(
        'reportUnsupportedListElementType() creates '
        'UnsupportedListElementTypeDiagnostic',
        () {
          reporter.reportUnsupportedListElementType(
            elementType: 'MyStruct',
            startOffset: 0,
            endOffset: 10,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<UnsupportedListElementTypeDiagnostic>());
          expect(d.message, contains('MyStruct'));
          expect(d.code, DiagnosticCode.unsupportedListElementType);
        },
      );

      test(
        'reportMapKeyTypeMismatch() creates MapKeyTypeMismatchDiagnostic',
        () {
          reporter.reportMapKeyTypeMismatch(
            expectedType: 'string',
            actualType: 'IntLiteralNode',
            startOffset: 0,
            endOffset: 5,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<MapKeyTypeMismatchDiagnostic>());
          expect(d.message, contains('string'));
          expect(d.code, DiagnosticCode.mapKeyTypeMismatch);
        },
      );

      test(
        'reportMapValueTypeMismatch() creates MapValueTypeMismatchDiagnostic',
        () {
          reporter.reportMapValueTypeMismatch(
            expectedType: 'i32',
            actualType: 'StringLiteralNode',
            startOffset: 0,
            endOffset: 5,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<MapValueTypeMismatchDiagnostic>());
          expect(d.message, contains('i32'));
          expect(d.code, DiagnosticCode.mapValueTypeMismatch);
        },
      );

      test(
        'reportRequiredFieldCannotHaveDefaultValue() creates '
        'correct diagnostic',
        () {
          reporter.reportRequiredFieldCannotHaveDefaultValue(
            fieldName: 'age',
            startOffset: 0,
            endOffset: 10,
          );
          expect(reporter.diagnostics, hasLength(1));
          final d = reporter.diagnostics.first;
          expect(d, isA<RequiredFieldCannotHaveDefaultValueDiagnostic>());
          expect(d.message, contains('age'));
          expect(d.message, contains('required'));
          expect(d.code, DiagnosticCode.requiredFieldCannotHaveDefaultValue);
        },
      );
    });
  });

  group('DiagnosticCode', () {
    test('each code has a non-empty id', () {
      for (final code in DiagnosticCode.values) {
        expect(code.id, isNotEmpty);
      }
    });

    test('each code has non-null suggestions', () {
      for (final code in DiagnosticCode.values) {
        expect(code.suggestions, isNotNull);
        expect(code.suggestions, isNotEmpty);
      }
    });

    test('ids are unique', () {
      final ids = DiagnosticCode.values.map((c) => c.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('helpLink contains diagnostic id', () {
      for (final code in DiagnosticCode.values) {
        expect(code.helpLink, contains(code.id));
      }
    });

    test('specific code ids match expected values', () {
      expect(
        DiagnosticCode.literalValueCannotBeAssigned.id,
        equals('E1001'),
      );
      expect(DiagnosticCode.duplicateDeclaration.id, equals('E1002'));
      expect(DiagnosticCode.undefinedSymbol.id, equals('E1003'));
      expect(DiagnosticCode.emptyEnumDefinition.id, equals('E1004'));
      expect(DiagnosticCode.emptyStructDefinition.id, equals('E1005'));
      expect(DiagnosticCode.keywordAsIdentifier.id, equals('E1006'));
      expect(DiagnosticCode.listElementTypeMismatch.id, equals('E1007'));
      expect(DiagnosticCode.unsupportedListElementType.id, equals('E1008'));
      expect(DiagnosticCode.mapKeyTypeMismatch.id, equals('E1009'));
      expect(DiagnosticCode.mapValueTypeMismatch.id, equals('E1010'));
      expect(
        DiagnosticCode.requiredFieldCannotHaveDefaultValue.id,
        equals('E1011'),
      );
    });
  });

  group('DiagnosticSeverity', () {
    test('displayName values are correct', () {
      expect(DiagnosticSeverity.info.displayName, equals('INFO'));
      expect(DiagnosticSeverity.warning.displayName, equals('WARNING'));
      expect(DiagnosticSeverity.error.displayName, equals('ERROR'));
      expect(DiagnosticSeverity.fatal.displayName, equals('FATAL'));
    });

    test('priority ordering is ascending by severity', () {
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

    test('toString returns displayName', () {
      for (final severity in DiagnosticSeverity.values) {
        expect(severity.toString(), equals(severity.displayName));
      }
    });
  });
}
