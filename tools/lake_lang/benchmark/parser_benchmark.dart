import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:lake_lang/src/ast/lake_ast_grammar_definition.dart';
import 'package:lake_lang/src/parser/lake_parser.dart';
import 'package:petitparser/petitparser.dart';

const benchmarkHeaders = '''
import "some_package";
namespace js App;
''';

const benchmarkDefs = '''
struct Data {
  1: required string id;
  2: optional map<string, i32> counts;
}

enum State { 
  STARTED = 1,
  STOPPED = 2,
}

service MyService {
  void doSomething(1: Data data) throws (1: Error e);
}
''';

String generateLargeInput(int multiplier) {
  final buffer = StringBuffer()..writeln(benchmarkHeaders);
  for (var i = 0; i < multiplier; i++) {
    buffer.writeln(
      benchmarkDefs
          .replaceAll('Data', 'Data$i')
          .replaceAll('State', 'State$i')
          .replaceAll('MyService', 'MyService$i'),
    );
  }
  return buffer.toString();
}

final largeInput = generateLargeInput(
  200,
); // Simulating a large file ~4000 lines

class PetitParserBenchmark extends BenchmarkBase {
  PetitParserBenchmark() : super('PetitParser');

  late final Parser parser;

  @override
  void setup() {
    const astGrammar = LakeAstGrammarDefinition();
    parser = astGrammar.build();
  }

  @override
  void run() {
    final result = parser.parse(largeInput);
    if (result is Failure) {
      throw Exception('PetitParser failed: ${result.message}');
    }
  }
}

class NewParserBenchmark extends BenchmarkBase {
  NewParserBenchmark() : super('NewRecursiveDescentParser');

  @override
  void run() {
    LakeParser(largeInput).parseDocument();
  }
}

void main() {
  stdout
    ..writeln('--- Lake Parser Benchmark ---')
    ..writeln('Input size: ${largeInput.length} bytes')
    ..writeln('Running PetitParser...');
  PetitParserBenchmark().report();
  stdout.writeln('Running NewRecursiveDescentParser...');
  NewParserBenchmark().report();
}
