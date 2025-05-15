import 'package:path/path.dart';

import 'is.dart';

/// A class that represents the configuration for the find command.
final class FindConfig {
  const FindConfig({
    required this.workDirectory,
    required this.pattern,
    required this.includeHidden,
    required this.caseSensitive,
    required this.matcher,
  });

  factory FindConfig.build({
    required String pattern,
    required String workDirectory,
    required bool includeHidden,
    required bool caseSensitive,
  }) {
    final directoryPart = dirname(pattern);
    if (directoryPart != '.') {
      workDirectory = join(workDirectory, directoryPart);
    }

    pattern = basename(pattern);

    if (!isExists(workDirectory)) {
      throw ArgumentError('The directory $workDirectory does not exist.');
    }

    final matcher = PatternMatcher.build(
      pattern: pattern,
      caseSensitive: caseSensitive,
      workingDirectory: workDirectory,
    );

    return FindConfig(
      workDirectory: workDirectory,
      pattern: pattern,
      includeHidden: includeHidden,
      caseSensitive: caseSensitive,
      matcher: matcher,
    );
  }

  final String workDirectory;
  final String pattern;
  final bool includeHidden;
  final bool caseSensitive;
  final PatternMatcher matcher;
}

/// A class that matches a pattern against a file name.
/// It uses a regular expression to perform the matching.
/// The pattern can contain the following special characters:
/// - `*` matches any number of characters
/// - `?` matches a single character
/// - `[` and `]` match a character class
/// - `!` negates a character class
/// - `-` matches a range of characters
/// - `.` matches a literal dot
/// - `\` escapes a special character
/// The pattern is case-sensitive by default.
final class PatternMatcher {
  const PatternMatcher._({
    required this.pattern,
    required this.workingDirectory,
    required this.caseSensitive,
    required this.regExp,
  });

  factory PatternMatcher.build({
    required String pattern,
    required String workingDirectory,
    required bool caseSensitive,
  }) {
    final regExp = _buildRegExp(pattern, caseSensitive: caseSensitive);

    return PatternMatcher._(
      pattern: pattern,
      workingDirectory: workingDirectory,
      caseSensitive: caseSensitive,
      regExp: regExp,
    );
  }

  static RegExp _buildRegExp(String pattern, {required bool caseSensitive}) {
    final buffer = StringBuffer();

    for (var i = 0; i < pattern.length; i++) {
      final char = pattern[i];

      switch (char) {
        case '[':
          buffer.write('[');
        case ']':
          buffer.write(']');
        case '*':
          buffer.write('.*');
        case '?':
          buffer.write('.');
        case '-':
          buffer.write('-');
        case '!':
          buffer.write('!');
        case '.':
          buffer.write(r'\.');
        case r'\':
          buffer.write(r'\\');
        default:
          buffer.write(char);
      }
    }

    return RegExp(
      buffer.toString(),
      caseSensitive: caseSensitive,
      multiLine: true,
    );
  }

  final String pattern;
  final String workingDirectory;
  final bool caseSensitive;
  final RegExp regExp;
}
