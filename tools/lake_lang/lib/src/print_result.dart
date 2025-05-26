// ignore_for_file: avoid_print

import 'package:petitparser/petitparser.dart';

/// Prints the result of parsing in a readable way, including the error line and
///  position if failed.
void printParseResult(Result result) {
  switch (result) {
    case Success():
      return;

    case Failure(
      buffer: final buffer,
      message: final message,
      position: final position,
    ):
      if (position < 0 || position > buffer.length) {
        print(
          'Failure: position $position is out of bounds for input of length '
          '${buffer.length}',
        );
        return;
      }

      final (lineNumber, column, errorLine) = _findErrorPosition(
        buffer,
        position,
      );

      final errorMessage = [
        'Failure at line $lineNumber, column $column:',
        if (errorLine.isNotEmpty) '  $errorLine',
        if (errorLine.isNotEmpty) '  ${'.' * column}^: $message',
      ].join('\n');

      print(errorMessage);
  }
}

/// Locates the line number, column, and the exact line content where the error
/// occurred.
(int lineNumber, int column, String errorLine) _findErrorPosition(
  String buffer,
  int position,
) {
  final lines = buffer.split('\n');
  var currentPosition = 0;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final nextPosition = currentPosition + line.length + 1; // +1 for '\n'

    if (nextPosition > position) {
      final column = position - currentPosition;
      return (i + 1, column, line);
    }

    currentPosition = nextPosition;
  }

  return (-1, -1, '');
}
