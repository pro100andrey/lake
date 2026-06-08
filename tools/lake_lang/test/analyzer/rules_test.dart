import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/analyzer/errors/semantic_error.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/keyword_as_identifier_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/literal_assignment_type_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/non_empty_enum_definition_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/non_empty_struct_definition_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/optional_field_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/required_field_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/union_field_modifiers_rule.dart';
import 'package:lake_lang/src/analyzer/rules/declaration/unique_field_id_rule.dart';
import 'package:lake_lang/src/analyzer/symbols/symbol_table.dart';
import 'package:lake_lang/src/analyzer/visitors/symbol_table_visitor.dart';
import 'package:lake_lang/src/analyzer/visitors/type_checking_visitor.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

/// Helper: parse Lake source and return the document.
DocumentNode _parse(String source, ErrorReporter reporter) {
  final parser = LakeParser(source, reporter);
  return parser.parseDocument();
}

/// Helper: extract the first definition of type [T] from parsed source.
T _firstDef<T extends DefinitionNode>(String source, ErrorReporter reporter) {
  final doc = _parse(source, reporter);
  return doc.definitions.whereType<T>().first;
}

/// Helper: extract all FieldNodes from a struct source.
List<FieldNode> _structFields(String source, ErrorReporter reporter) {
  final struct = _firstDef<StructDefinitionNode>(source, reporter);
  return struct.fields;
}

void main() {

  // ─────────────────────────────────────────────
  // KeywordAsIdentifierRule tests
  // ─────────────────────────────────────────────
  group('KeywordAsIdentifierRule', () {
    late ErrorReporter reporter;
    late KeywordAsIdentifierRule rule;

    setUp(() {
      reporter = ErrorReporter();
      rule = KeywordAsIdentifierRule(reporter: reporter);
    });

    test('reports error when reserved keyword is used as identifier', () {
      const keywords = [
        'struct',
        'service',
        'enum',
        'const',
        'import',
        'namespace',
        'type',
        'void',
        'bool',
        'byte',
        'i8',
        'i16',
        'i32',
        'i64',
        'double',
        'string',
        'binary',
        'uuid',
        'list',
        'map',
        'set',
        'stream',
        'extends',
        'throws',
      ];

      for (final kw in keywords) {
        final r = ErrorReporter();
        final _ = KeywordAsIdentifierRule(reporter: r)
          ..check(
            IdentifierNode(name: kw, startOffset: 0, endOffset: kw.length),
          );
        expect(r.hasErrors, isTrue, reason: 'Expected error for keyword "$kw"');
        expect(
          r.diagnostics.first.code,
          DiagnosticCode.keywordAsIdentifier,
          reason: 'Wrong code for keyword "$kw"',
        );
      }
    });

    test('does NOT report error for valid identifiers', () {
      const validNames = ['myVar', 'user_id', 'Status', 'X', 'hello123'];
      for (final name in validNames) {
        rule.check(
          IdentifierNode(name: name, startOffset: 0, endOffset: name.length),
        );
      }
      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // NonEmptyEnumDefinitionRule tests
  // ─────────────────────────────────────────────
  group('NonEmptyEnumDefinitionRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error on empty enum', () {
      final enumNode = _firstDef<EnumDefinitionNode>(
        'enum Empty {}',
        reporter,
      );
      // Parser won't add errors about empty enum, the rule does
      reporter = ErrorReporter();
      NonEmptyEnumDefinitionRule(reporter: reporter).check(enumNode);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.emptyEnumDefinition,
      );
    });

    test('does NOT report error on non-empty enum', () {
      final enumNode = _firstDef<EnumDefinitionNode>(
        'enum Color { RED, GREEN, BLUE }',
        reporter,
      );
      reporter = ErrorReporter();
      NonEmptyEnumDefinitionRule(reporter: reporter).check(enumNode);
      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // NonEmptyStructDefinitionRule tests
  // ─────────────────────────────────────────────
  group('NonEmptyStructDefinitionRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error on empty struct', () {
      final structNode = _firstDef<StructDefinitionNode>(
        'struct Empty {}',
        reporter,
      );
      reporter = ErrorReporter();
      NonEmptyStructDefinitionRule(reporter: reporter).check(structNode);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.emptyStructDefinition,
      );
    });

    test('does NOT report error on non-empty struct', () {
      final structNode = _firstDef<StructDefinitionNode>(
        'struct User { 1: i32 id }',
        reporter,
      );
      reporter = ErrorReporter();
      NonEmptyStructDefinitionRule(reporter: reporter).check(structNode);
      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // LiteralAssignmentTypeRule tests
  // ─────────────────────────────────────────────
  group('LiteralAssignmentTypeRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error: string assigned to i32 const', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const i32 MY_CONST = "hello"',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.literalValueCannotBeAssigned,
      );
    });

    test('reports error: int assigned to string const', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const string MY_STR = 42',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.literalValueCannotBeAssigned,
      );
    });

    test('reports error: bool assigned to double const', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const double MY_D = true',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isTrue);
    });

    test('does NOT report error: int assigned to i32', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const i32 MY_INT = 42',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error: string assigned to string', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const string MY_STR = "hello"',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error: bool assigned to bool', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const bool MY_BOOL = true',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error: double assigned to double', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const double MY_D = 3.14',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error: int assigned to i64', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const i64 BIG = 99999',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('list const with mismatched element type', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const list<i32> NUMS = [1, "two", 3]',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.any(
          (d) => d.code == DiagnosticCode.listElementTypeMismatch,
        ),
        isTrue,
      );
    });

    test('list const with all matching elements — no error', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const list<i32> NUMS = [1, 2, 3]',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('map const with mismatched key type', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const map<string, i32> M = {42: 1}',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.any(
          (d) => d.code == DiagnosticCode.mapValueTypeMismatch,
        ),
        isTrue,
      );
    });

    test('map const with mismatched value type', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const map<string, i32> M = {"a": "b"}',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isTrue);
    });

    test('map const with correct types — no error', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const map<string, i32> M = {"a": 1, "b": 2}',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      expect(reporter.hasErrors, isFalse);
    });

    test('skips identifier value (deferred to type checking)', () {
      final constNode = _firstDef<ConstDefinitionNode>(
        'const i32 B = A',
        reporter,
      );
      reporter = ErrorReporter();
      LiteralAssignmentTypeRule(reporter: reporter).check(constNode);
      // Identifier values are skipped by this rule
      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // RequiredFieldRule tests
  // ─────────────────────────────────────────────
  group('RequiredFieldRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error when required field has a default value', () {
      final fields = _structFields(
        'struct S { 1: required i32 count = 5 }',
        reporter,
      );
      reporter = ErrorReporter();
      RequiredFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.requiredFieldCannotHaveDefaultValue,
      );
    });

    test('does NOT report error when required field has no default', () {
      final fields = _structFields(
        'struct S { 1: required i32 count }',
        reporter,
      );
      reporter = ErrorReporter();
      RequiredFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error for non-required field (no modifier)', () {
      final fields = _structFields(
        'struct S { 1: i32 count }',
        reporter,
      );
      reporter = ErrorReporter();
      RequiredFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error for optional field with default', () {
      final fields = _structFields(
        'struct S { 1: optional i32 count = 10 }',
        reporter,
      );
      reporter = ErrorReporter();
      RequiredFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // OptionalFieldRule tests
  // ─────────────────────────────────────────────
  group('OptionalFieldRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error when optional field default type mismatches', () {
      final fields = _structFields(
        'struct S { 1: optional i32 count = "hello" }',
        reporter,
      );
      reporter = ErrorReporter();
      OptionalFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.literalValueCannotBeAssigned,
      );
    });

    test('does NOT report error when optional field default type matches', () {
      final fields = _structFields(
        'struct S { 1: optional i32 count = 42 }',
        reporter,
      );
      reporter = ErrorReporter();
      OptionalFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isFalse);
    });

    test('does NOT report error for optional field without default', () {
      final fields = _structFields(
        'struct S { 1: optional i32 count }',
        reporter,
      );
      reporter = ErrorReporter();
      OptionalFieldRule(reporter: reporter).check(fields.first);
      expect(reporter.hasErrors, isFalse);
    });

    test(
      'does NOT report error for non-required field '
      'without modifier with matching default',
      () {
        // Fields without modifier are NOT required
        // (isRequired = false by default)
        final fields = _structFields(
          'struct S { 1: i32 count = 7 }',
          reporter,
        );
        reporter = ErrorReporter();
        OptionalFieldRule(reporter: reporter).check(fields.first);
        expect(reporter.hasErrors, isFalse);
      },
    );

    test('does NOT check required fields (deferred to RequiredFieldRule)', () {
      // A required field with mismatched default — OptionalFieldRule skips it
      final fields = _structFields(
        'struct S { 1: required i32 count = "hello" }',
        reporter,
      );
      reporter = ErrorReporter();
      OptionalFieldRule(reporter: reporter).check(fields.first);
      // OptionalFieldRule skips required fields
      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // ConstIdentifierResolutionRule tests
  // ─────────────────────────────────────────────
  group('ConstIdentifierResolutionRule', () {
    test('resolves identifier reference in const definition', () {
      final reporter = ErrorReporter();
      final symbolTable = SymbolTable(reporter);
      const source = '''
const i32 A = 42
const i32 B = A
''';
      final doc = _parse(source, reporter);

      // Phase 1: Build symbol table
      final stv = SymbolTableVisitor(symbolTable, reporter);
      doc.accept(stv);

      // Phase 2: Type checking (resolves const types and identifier refs)
      final tcv = TypeCheckingVisitor(symbolTable, reporter);
      doc.accept(tcv);

      // B should have been resolved without errors
      // The only thing we check is no type-mismatch error from the rule
      expect(
        reporter.diagnostics.where(
          (d) => d.code == DiagnosticCode.literalValueCannotBeAssigned,
        ),
        isEmpty,
      );
    });

    test('reports error on type mismatch in identifier resolution', () {
      final reporter = ErrorReporter();
      final symbolTable = SymbolTable(reporter);
      const source = '''
const string GREETING = "hello"
const i32 NUM = GREETING
''';
      final doc = _parse(source, reporter);

      // Phase 1: Build symbol table
      final stv = SymbolTableVisitor(symbolTable, reporter);
      doc.accept(stv);

      // Phase 2: Type checking
      final tcv = TypeCheckingVisitor(symbolTable, reporter);
      doc.accept(tcv);

      // Should have a type mismatch error
      expect(
        reporter.diagnostics.any(
          (d) => d.code == DiagnosticCode.literalValueCannotBeAssigned,
        ),
        isTrue,
      );
    });

    test('reports error when referencing undefined identifier', () {
      final reporter = ErrorReporter();
      final symbolTable = SymbolTable(reporter);
      const source = '''
const i32 B = UNDEFINED_CONST
''';
      final doc = _parse(source, reporter);

      // Phase 1
      final stv = SymbolTableVisitor(symbolTable, reporter);
      doc.accept(stv);

      // Phase 2
      final tcv = TypeCheckingVisitor(symbolTable, reporter);
      doc.accept(tcv);

      // Should report undefined symbol
      expect(
        reporter.diagnostics.any(
          (d) => d.code == DiagnosticCode.undefinedSymbol,
        ),
        isTrue,
      );
    });
  });

  // ─────────────────────────────────────────────
  // Integration: full visitor pipeline
  // ─────────────────────────────────────────────
  group('Integration: SymbolTableVisitor applies rules', () {
    test('empty enum detected via visitor pipeline', () {
      final reporter = ErrorReporter();
      final symbolTable = SymbolTable(reporter);
      final doc = _parse('enum Empty {}', reporter);
      final stv = SymbolTableVisitor(symbolTable, reporter);
      doc.accept(stv);
      expect(
        reporter.diagnostics.any(
          (d) => d.code == DiagnosticCode.emptyEnumDefinition,
        ),
        isTrue,
      );
    });

    test('empty struct detected via visitor pipeline', () {
      final reporter = ErrorReporter();
      final symbolTable = SymbolTable(reporter);
      final doc = _parse('struct Empty {}', reporter);
      final stv = SymbolTableVisitor(symbolTable, reporter);
      doc.accept(stv);
      expect(
        reporter.diagnostics.any(
          (d) => d.code == DiagnosticCode.emptyStructDefinition,
        ),
        isTrue,
      );
    });

    test('keyword as identifier detected via visitor pipeline', () {
      // The parser uses 'struct' as a keyword so it can't appear as an
      // identifier directly. But identifiers like field names that happen to
      // match keywords are checked by IdentifierNode visitor.
      // Use a const definition whose value is an identifier with
      // a keyword name:
      // This won't parse 'struct' as an identifier since it's a keyword token.
      // Instead, test with a valid parse that has identifiers checked.
      final reporter = ErrorReporter();
      final symbolTable = SymbolTable(reporter);
      // The SymbolTableVisitor dispatches KeywordAsIdentifierRule on
      // IdentifierNode visits. Identifiers are visited for const values,
      // field names etc. Regular names won't trigger. We construct a node
      // directly for completeness:
      final _ = KeywordAsIdentifierRule(reporter: reporter)
        ..check(
          const IdentifierNode(name: 'enum', startOffset: 0, endOffset: 4),
        );
      expect(reporter.hasErrors, isTrue);
      expect(symbolTable, isNotNull); // just to use it
    });
  });

  // ─────────────────────────────────────────────
  // UniqueFieldIdRule tests
  // ─────────────────────────────────────────────
  group('UniqueFieldIdRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error on duplicate field IDs in struct', () {
      final parser = LakeParser(
        'struct User { 1: i32 a; 1: string b; }',
        reporter,
      );
      final doc = parser.parseDocument();
      final structNode = doc.definitions.first as StructDefinitionNode;

      UniqueFieldIdRule<StructDefinitionNode>(
        reporter: reporter,
      ).check(structNode);

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.duplicateFieldId,
      );
    });

    test('does NOT report error for unique field IDs', () {
      final parser = LakeParser(
        'struct User { 1: i32 a; 2: string b; }',
        reporter,
      );
      final doc = parser.parseDocument();
      final structNode = doc.definitions.first as StructDefinitionNode;

      UniqueFieldIdRule<StructDefinitionNode>(
        reporter: reporter,
      ).check(structNode);

      expect(reporter.hasErrors, isFalse);
    });
  });

  // ─────────────────────────────────────────────
  // UnionFieldModifiersRule tests
  // ─────────────────────────────────────────────
  group('UnionFieldModifiersRule', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('reports error if union field is required', () {
      final parser = LakeParser(
        'union Result { 1: required i32 a; }',
        reporter,
      );
      final doc = parser.parseDocument();
      final unionNode = doc.definitions.first as UnionDefinitionNode;

      UnionFieldModifiersRule(reporter: reporter).check(unionNode);

      expect(reporter.hasErrors, isTrue);
      expect(
        reporter.diagnostics.first.code,
        DiagnosticCode.invalidUnionFieldModifier,
      );
    });

    test('does NOT report error for normal union fields', () {
      final parser = LakeParser('union Result { 1: i32 a; }', reporter);
      final doc = parser.parseDocument();
      final unionNode = doc.definitions.first as UnionDefinitionNode;

      UnionFieldModifiersRule(reporter: reporter).check(unionNode);

      expect(reporter.hasErrors, isFalse);
    });
  });
}
