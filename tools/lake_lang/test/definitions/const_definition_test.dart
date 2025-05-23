// ignore_for_file: avoid_print

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = LakeGrammarDefinition();
  final parser = resolve(grammar.constDefinition()).end();

  group('Lake Grammar - ConstDefinition:', () {
    group('Valid Cases:', () {
      test('simple string const - succeeds', () {
        const input = 'const string NAME = "John Doe"';
        final result = parser.parse(input);
        printResult(result);
        expect(result, isA<Success>());
        expect(result.value, '');
      });

      test('integer const with semicolon - succeeds', () {
        const input = 'const i32 MAX_USERS = 100';
        final result = parser.parse(input);
        printResult(result);
        expect(result, isA<Success>());
        expect(result.value, '');
      });
    });

    group('Invalid Cases:', () {});
  });
}

// void printResult(Result result) {
//   switch (result) {
//     case Success():
//       print('Success: ${result.value}');
//     case Failure(
//       buffer: final buffer,
//       message: final message,
//       position: final position,
//     ):
//       final rBuffer = StringBuffer();
//       rBuffer.write(buffer);
//       rBuffer.write('\n');
//       for (var i = 0; i < position; i++) {
//         rBuffer.write(' ');
//       }
//       rBuffer.write('^');
//       rBuffer.write(' $message');

//       final error = rBuffer.toString();
//       print(error);
//   }
// }

void printResult(Result result) {
  switch (result) {
    case Success():
      print('Success: ${result.value}');
    case Failure(
      buffer: final buffer,
      message: final message,
      position: final position,
    ):
      final lines = buffer.split('\n');
      var currentPosition = 0;
      var lineNumber = 0;
      var errorLine = '';
      var column = 0;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (currentPosition + line.length + 1 > position) {
          errorLine = line;
          lineNumber = i + 1;
          column = position - currentPosition;
          break;
        }

        currentPosition += line.length + 1;
      }

      final rBuffer = StringBuffer();
      rBuffer.writeln('Failure at line $lineNumber, column $column:');
      if (errorLine.isNotEmpty) {
        rBuffer
          ..writeln('  $errorLine')
          ..write('  ');
        for (var i = 0; i < column; i++) {
          rBuffer.write(' ');
        }

        rBuffer.writeln('^');
      }

      rBuffer.writeln('Message: $message');

      final error = rBuffer.toString();
      print(error);
  }
}
