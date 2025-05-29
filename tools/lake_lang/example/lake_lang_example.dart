// ignore_for_file: avoid_print

import 'dart:io';

import 'package:lake_lang/lake_lang.dart';
import 'package:petitparser/petitparser.dart';
import 'package:source_span/source_span.dart';

void main(List<String> args) {
  print('\r');

  final filePath = () {
    if (args.isNotEmpty) {
      return args[0];
    } else {
      final currentDir = Directory.current.path;
      final schemaDir = '$currentDir/schema';
      final exampleLakeFilePath = '$schemaDir/example.lake';
      return exampleLakeFilePath;
    }
  }();

  final sourceCode = loadLakeFile(filePath);
  final sourceFile = SourceFile.fromString(sourceCode, url: filePath);
  final grammar = LakeAstGrammarDefinition(sourceFile);
  final parser = grammar.build();

  final timer = ExecutionTimer()..start();

  late Result parseResult;
  timer
    ..measure('Parser parse', () {
      parseResult = parser.parse(sourceCode);
    })
    ..stop()
    ..printSummary()
    ..reset();

  switch (parseResult) {
    case Success():
      break;

    case Failure():
      printParseResult(parseResult);

      return;
  }

  late AstPrettyPrinterVisitor printer;
  timer
    ..measure('Printer creation', () {
      printer = AstPrettyPrinterVisitor();
    })
    ..measure('Printer visit', () {
      (parseResult.value as DocumentNode).accept(printer);
    })
    ..stop()
    ..printSummary();

  printParseResult(parseResult);
}

String loadLakeFile(String filePath) {
  final file = File(filePath);
  if (file.existsSync()) {
    return file.readAsStringSync();
  } else {
    throw Exception('File not found: $filePath');
  }
}

/// A utility class for measuring and reporting execution times of various
/// operations.
class ExecutionTimer {
  final Map<String, int> _stepTimings = {};
  final Stopwatch _overallWatch = Stopwatch();

  /// Starts the overall timer for the entire process.
  void start() {
    _overallWatch.start();
  }

  /// Stops the overall timer.
  void stop() {
    _overallWatch.stop();
  }

  /// Resets the timer and clears all recorded step timings.
  void reset() {
    _stepTimings.clear();
    _overallWatch.reset();
  }

  /// Executes an operation and measures its time, storing it by description.
  /// Prints the individual step time.
  ///
  /// Returns the elapsed microseconds for the operation.
  int measure(String description, void Function() operation) {
    final watch = Stopwatch()..start();
    operation();
    watch.stop();
    final elapsed = watch.elapsedMicroseconds;
    _stepTimings[description] = elapsed;

    return elapsed;
  }

  /// Prints a summary of all measured step timings and the total overall time.
  void printSummary() {
    print('--- Total Timing Summary ---');
    _stepTimings.forEach((key, value) {
      print('$key: $value microseconds');
    });

    print(
      'Total execution time: ${_overallWatch.elapsedMicroseconds} microseconds',
    );

    print('----------------------------');
  }
}
