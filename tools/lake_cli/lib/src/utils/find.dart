import 'dart:io';

import 'package:path/path.dart';

import '../core/exceptions.dart';
import 'is.dart';
import 'truepath.dart';

typedef FindProgressCallback = bool Function(FindItem item);

void find(
  String pattern, {
  required FindProgressCallback progress,
  bool caseSensitive = false,
  bool reverse = false,
  String workingDirectory = '.',
  List<FileSystemEntityType> types = const [Find.file],
  bool includeHidden = false,
}) {
  Find()._find(
    pattern,
    progress: progress,
    caseSensitive: caseSensitive,
    reverse: reverse,
    workingDirectory: workingDirectory,
    types: types,
    includeHidden: includeHidden,
  );
}

final class FindItem {
  const FindItem(this.path, this.type);

  /// The path of the file or directory.
  final String path;

  /// The type of the file system entity.
  final FileSystemEntityType type;
}

final class Find {
  static const file = FileSystemEntityType.file;

  static const directory = FileSystemEntityType.directory;

  static const link = FileSystemEntityType.link;

  void _find(
    String pattern, {
    required FindProgressCallback progress,
    bool caseSensitive = false,
    bool reverse = false,
    String workingDirectory = '.',
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden = false,
  }) {
    final config = FindConfig.build(
      pattern: pattern,
      workingDirectory: workingDirectory,
      includeHidden: includeHidden,
      caseSensitive: caseSensitive,
    );

    final next = List<FileSystemEntity?>.filled(100, null, growable: true);
    final single = List<FileSystemEntity?>.filled(100, null, growable: true);
    final children = List<FileSystemEntity?>.filled(100, null, growable: true);

    final dir = Directory(config.workingDirectory);
    final list = dir.listSync(followLinks: false);

    const nextIndex = 0;

    for (final entity in list) {
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
    }
  }
}

class FindException extends CliException {
  FindException(super.message);
}

/// A class that represents the configuration for the find command.
final class FindConfig {
  const FindConfig({
    required this.workingDirectory,
    required this.pattern,
    required this.includeHidden,
    required this.caseSensitive,
    required this.matcher,
  });

  factory FindConfig.build({
    required String pattern,
    required String workingDirectory,
    required bool includeHidden,
    required bool caseSensitive,
  }) {
    final directoryPart = dirname(pattern);

    if (directoryPart != '.') {
      workingDirectory = join(workingDirectory, directoryPart);
    }

    if (!isExists(workingDirectory)) {
      throw FindException(
        'The directory ${truePath(workingDirectory)} does not exist.',
      );
    }

    pattern = basename(pattern);

    final matcher = PatternMatcher.build(
      pattern: pattern,
      caseSensitive: caseSensitive,
      workingDirectory: workingDirectory,
    );

    workingDirectory =
        workingDirectory == '.'
            ? Directory.current.path
            : truePath(workingDirectory);

    includeHidden = basename(pattern).startsWith('.');

    return FindConfig(
      workingDirectory: workingDirectory,
      pattern: pattern,
      includeHidden: includeHidden,
      caseSensitive: caseSensitive,
      matcher: matcher,
    );
  }

  final String workingDirectory;
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
