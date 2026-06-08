import 'dart:io';
import 'package:lake_lang/src/analyzer/errors/error_reporter.dart';
import 'package:lake_lang/src/parser/ast/ast_base.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Parser Error Recovery', () {
    test('File-level recovery: Recovers and parses the second struct', () {
      final source = File(
        'test/test_data/lake_sources/error_recovery_test_15.lake',
      ).readAsStringSync();

      final reporter = ErrorReporter();
      final parser = LakeParser(source, reporter);
      final document = parser.parseDocument();

      // We expect an error for the syntax error in BadStruct
      expect(reporter.hasErrors, isTrue);

      // But we still expect GoodStruct to be parsed correctly
      expect(document.definitions.length, equals(2));

      final goodStruct = document.definitions.last;
      expect(goodStruct, isA<StructDefinitionNode>());
      final goodStructNode = goodStruct as StructDefinitionNode;
      expect(goodStructNode.identifier.name, equals('GoodStruct'));
      expect(goodStruct.fields.length, equals(1));
    });

    test('Field-level recovery: Recovers inside a struct', () {
      final source = File(
        'test/test_data/lake_sources/error_recovery_test_14.lake',
      ).readAsStringSync();

      final reporter = ErrorReporter();
      final parser = LakeParser(source, reporter);
      final document = parser.parseDocument();

      expect(reporter.hasErrors, isTrue);
      expect(document.definitions.length, equals(1));

      final structDef = document.definitions.first as StructDefinitionNode;
      expect(structDef.identifier.name, equals('MyStruct'));

      // It should recover and parse 'a', 'b', and 'c'
      expect(structDef.fields.length, equals(3));
      expect(structDef.fields[0].identifier.name, equals('a'));
      expect(structDef.fields[1].identifier.name, equals('b'));
      expect(structDef.fields[2].identifier.name, equals('c'));
    });

    test('Method-level recovery: Recovers inside a service', () {
      final source = File(
        'test/test_data/lake_sources/error_recovery_test_13.lake',
      ).readAsStringSync();

      final reporter = ErrorReporter();
      final parser = LakeParser(source, reporter);
      final document = parser.parseDocument();

      expect(reporter.hasErrors, isTrue);
      expect(document.definitions.length, equals(1));

      final serviceDef = document.definitions.first as ServiceDefinitionNode;
      expect(serviceDef.identifier.name, equals('MyService'));

      // Should recover and parse 'goodMethod' and 'anotherGoodMethod'
      expect(serviceDef.methods.length, equals(2));
      expect(serviceDef.methods[0].identifier.name, equals('goodMethod'));
      expect(
        serviceDef.methods[1].identifier.name,
        equals('anotherGoodMethod'),
      );
    });
  });
}
