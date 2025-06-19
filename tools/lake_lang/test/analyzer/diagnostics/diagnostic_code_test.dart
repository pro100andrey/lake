import 'package:lake_lang/lake_lang.dart';
import 'package:test/test.dart';

void main() {
  group('DiagnosticCode', () {
    test(
      'literalValueCannotBeAssigned should have correct id and suggestions',
      () {
        const code = DiagnosticCode.literalValueCannotBeAssigned;
        expect(code.id, 'E1001');

        expect(
          code.suggestions,
          containsAllInOrder([
            'Ensure the literal value matches the declared type.',
            'Change the declared type to match the value.',
          ]),
        );
        expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1001');
      },
    );

    test('duplicateDeclaration should have correct id and suggestions', () {
      const code = DiagnosticCode.duplicateDeclaration;
      expect(code.id, 'E1002');

      expect(
        code.suggestions,
        containsAllInOrder([
          'Rename one of the declarations.',
          'Remove the duplicate declaration.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1002');
    });

    test('undefinedSymbol should have correct id and suggestions', () {
      const code = DiagnosticCode.undefinedSymbol;
      expect(code.id, 'E1003');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Declare the symbol before using it.',
          'Check for typos in the symbol name.',
          'Ensure the symbol is in scope.',
          'Import the necessary lake files.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1003');
    });

    test('emptyEnumDefinition should have correct id and suggestions', () {
      const code = DiagnosticCode.emptyEnumDefinition;
      expect(code.id, 'E1004');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Add at least one value to the enum.',
          'Consider removing the enum if it is not needed.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1004');
    });

    test('emptyStructDefinition should have correct id and suggestions', () {
      const code = DiagnosticCode.emptyStructDefinition;
      expect(code.id, 'E1005');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Add at least one field to the struct.',
          'Consider removing the struct if it is not needed.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1005');
    });

    test('keywordAsIdentifier should have correct id and suggestions', () {
      const code = DiagnosticCode.keywordAsIdentifier;
      expect(code.id, 'E1006');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Rename the identifier to avoid using reserved keywords',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1006');
    });

    test('listElementTypeMismatch should have correct id and suggestions', () {
      const code = DiagnosticCode.listElementTypeMismatch;
      expect(code.id, 'E1007');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Ensure all list elements are of the same type.',
          'Check the type of each element in the list.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1007');
    });

    test(
      'unsupportedListElementType should have correct id and suggestions',
      () {
        const code = DiagnosticCode.unsupportedListElementType;
        expect(code.id, 'E1008');
        expect(
          code.suggestions,
          containsAllInOrder([
            'Use a supported type like i32, bool, or string as list elements.',
            // ignore: lines_longer_than_80_chars
            'Check the language documentation for supported list element types.',
          ]),
        );
        expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1008');
      },
    );

    test('mapKeyTypeMismatch should have correct id and suggestions', () {
      const code = DiagnosticCode.mapKeyTypeMismatch;
      expect(code.id, 'E1009');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Ensure the map entry key matches the declared type.',
          'Change the declared type to match the key.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1009');
    });

    test('mapValueTypeMismatch should have correct id and suggestions', () {
      const code = DiagnosticCode.mapValueTypeMismatch;
      expect(code.id, 'E1010');
      expect(
        code.suggestions,
        containsAllInOrder([
          'Ensure the map entry value matches the declared type.',
          'Change the declared type to match the value.',
        ]),
      );
      expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1010');
    });

    test(
      'requiredFieldCannotHaveDefaultValue should have correct id and '
      'suggestions',
      () {
        const code = DiagnosticCode.requiredFieldCannotHaveDefaultValue;
        expect(code.id, 'E1011');
        expect(
          code.suggestions,
          containsAll([
            'Remove the default value from the required field.',
            'Consider making the field optional if a default value is needed.',
          ]),
        );
        expect(code.helpLink, 'https://lake.org/docs/diagnostic/E1011');
      },
    );

    test('all help links should follow the expected pattern', () {
      for (final code in DiagnosticCode.values) {
        expect(code.helpLink, 'https://lake.org/docs/diagnostic/${code.id}');
      }
    });

    test('all codes should have at least one suggestion', () {
      for (final code in DiagnosticCode.values) {
        expect(
          code.suggestions,
          isNotEmpty,
          reason: 'Code ${code.id} has no suggestions',
        );
      }
    });
  });
}
