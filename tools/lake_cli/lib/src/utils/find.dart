import 'dart:io';

import 'package:path/path.dart' as p;

/// A function type representing a filter predicate that takes a file path
/// and returns `true` if the path matches the filter criteria.
typedef FindFilter = bool Function(String path);

/// Finds files in the given directory and its subdirectories based on the
/// provided filter. If no filter is provided, all files are returned.
///
/// The [workingDirectory] parameter specifies the directory to search in. If
/// [workingDirectory] is null, the current working directory is used.
///
/// The [filter] parameter is a function that takes a file path as input and
/// returns true if the file should be included in the result.
///
/// Returns a **stream** of file paths that match the given filter.
Stream<String> findFiles({
  String? workingDirectory,
  FindFilter? filter,
}) async* {
  final resolvedPath = p.normalize(
    p.absolute(workingDirectory ?? Directory.current.path),
  );

  final dir = Directory(resolvedPath);
  if (!dir.existsSync()) {
    throw Exception('Directory does not exist: $resolvedPath');
  }

  await for (final entity in dir.list(recursive: true)) {
    final path = entity.path;
    if (filter?.call(path) ?? true) {
      yield path;
    }
  }
}

/// Synchronously finds files in the given directory and its subdirectories
/// based on the provided filter. If no filter is provided, all files are
/// returned.
///
/// The [workingDirectory] parameter specifies the directory to search in. If
/// [workingDirectory] is null, the current working directory is used.
///
/// The [filter] parameter is a function that takes a file path as input and
/// returns true if the file should be included in the result.
///
/// Returns an iterable of file paths that match the given filter.
/// This method is synchronous and may block the event loop if the directory
/// contains a large number of files.
Iterable<String> findFilesSync({
  String? workingDirectory,
  FindFilter? filter,
}) sync* {
  final resolvedPath = p.normalize(
    p.absolute(workingDirectory ?? Directory.current.path),
  );

  final dir = Directory(resolvedPath);
  if (!dir.existsSync()) {
    throw Exception('Directory does not exist: $resolvedPath');
  }

  for (final entity in dir.listSync(recursive: true)) {
    final path = entity.path;
    if (filter?.call(path) ?? true) {
      yield path;
    }
  }
}

/// A builder class to compose multiple file filters declaratively.
///
/// Allows the creation of complex file-matching logic using combinations
/// of conditions such as extensions, file names, paths, and custom rules.
class FindFiltersBuilder {
  final List<FindFilter> _filters = [];

  /// Adds a filter that matches files with any of the given [exts].
  ///
  /// Example:
  /// ```dart
  /// builder..extensions(['.dart', '.yaml']);
  /// ```
  void extensions(List<String> exts) =>
      _filters.add((path) => exts.contains(p.extension(path)));

  /// Adds a filter that matches files whose names contain the given [str].
  ///
  /// If [caseSensitive] is `false`, the comparison is case-insensitive.
  /// Example:
  /// ```dart
  /// builder.nameContains('test', caseSensitive: false);
  /// ```
  void nameContains(String str, {bool caseSensitive = true}) => _filters.add(
    (path) =>
        caseSensitive
            ? p.basename(path).contains(str)
            : p.basename(path).toLowerCase().contains(str.toLowerCase()),
  );

  /// Adds a filter that matches file paths against a regular expression.
  ///
  /// The [pattern] is the regular expression string.
  /// Example:
  /// ```dart
  /// builder.matchesRegex(r'.*\.temp$'); // Matches files ending with .temp
  /// ```
  void matchesRegex(String pattern, {bool caseSensitive = true}) {
    final regex = RegExp(pattern, caseSensitive: caseSensitive);
    _filters.add(regex.hasMatch);
  }

  /// Adds a filter that matches files whose full normalized path
  /// contains the given [str].
  ///
  /// Example:
  /// ```dart
  /// builder.pathContains('src/generated');
  /// ```
  void pathContains(String str) =>
      _filters.add((path) => p.normalize(path).contains(p.normalize(str)));

  /// Adds a filter that matches only regular files (not directories).
  ///
  /// Example:
  /// ```dart
  /// builder.isFile();
  /// ```
  void isFile() => _filters.add(FileSystemEntity.isFileSync);

  /// Adds a custom filter function.
  ///
  /// Use this to define any arbitrary matching logic.
  ///
  /// Example:
  /// ```dart
  /// builder.custom((path) => path.endsWith('.config'));
  /// ```
  void custom(FindFilter filter) => _filters.add(filter);

  /// Adds a group of filters combined with logical OR.
  ///
  /// Only one of the nested filters needs to match for the group to pass.
  ///
  /// Example:
  /// ```dart
  /// builder.groupOr((b) {
  ///   b.nameContains('main');
  ///   b.nameContains('test');
  /// });
  /// ```
  void groupOr(void Function(FindFiltersBuilder) fn) {
    final nested = FindFiltersBuilder();
    fn(nested);
    _filters.add((path) => nested._filters.any((f) => f(path)));
  }

  /// Builds the combined filter from all added rules using logical AND.
  ///
  /// All filters must match for a file to be included.
  ///
  /// Returns a [FindFilter] function that can be passed to [findFiles].
  FindFilter build() => (path) => _filters.every((f) => f(path));

  /// Shortcut to call the builder as a function.
  FindFilter call() => build();
}
