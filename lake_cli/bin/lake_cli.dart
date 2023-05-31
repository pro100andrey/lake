import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:colorize/colorize.dart';
import 'package:lake_cli/analyzer.dart';

const String generateCmd = 'generate';

Future<void> main(List<String> args) async {
  await runZonedGuarded(
    () async => _main(args),
    (error, stack) {
      stderr
        ..writeln(error)
        ..writeln(stack);
    },
  );
}

Future<void> _main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand(
      generateCmd,
      ArgParser()
        ..addFlag(
          'verbose',
          abbr: 'v',
          negatable: false,
          help: 'Output more detailed information.',
        )
        ..addFlag(
          'watch',
          abbr: 'w',
          negatable: false,
          help: 'Watch for changes and continuously generate code.',
        ),
    );

  final result = parser.parse(args);

  if (result.command?.name case generateCmd) {
    final config = await GeneratorConfig.load();
    config.hashCode;
  }

  _printUsage(parser);
}
  
void _printUsage(ArgParser parser) {
  final help = StringBuffer()
    ..writeBold('Usage: ', 'lake <command> [arguments]')
    ..writeln()
    ..writeBold('COMMANDS')
    ..writeln()
    ..writeCmd(
      name: generateCmd,
      description: 'Generate code from yaml files for server and clients.',
      parser: parser.commands[generateCmd],
    );

  stdout.writeln(help);
}

extension _StringBufferExt on StringBuffer {
  void writeBold(String text, [String? additional]) => writeln(
        '${Colorize(text)..bold()}${additional ?? ''}',
      );

  void writeCmd({
    required String name,
    required String description,
    ArgParser? parser,
    bool last = false,
  }) {
    writeBold('$name: ', description);
    if (parser != null) {
      writeln();
      writeln(parser.usage);
    }

    if (!last) {
      writeln();
    }
  }
}
