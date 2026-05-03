import 'dart:io';

/// Checks if the path is a file.
/// If the path is a file, it returns true. Otherwise, it returns false.
/// If the path is empty, it throws an [ArgumentError].
bool isFile(String path) {
  if (path.isEmpty) {
    throw ArgumentError('path must not be empty.');
  }

  final fromType = FileSystemEntity.typeSync(path);
  final isFile = fromType == FileSystemEntityType.file;

  return isFile;
}

/// Checks if the path is a directory.
/// If the path is a directory, it returns true. Otherwise, it returns false.
/// If the path is empty, it throws an [ArgumentError].
bool isDirectory(String path) {
  if (path.isEmpty) {
    throw ArgumentError('path must not be empty.');
  }

  final fromType = FileSystemEntity.typeSync(path);
  final result = fromType == FileSystemEntityType.directory;

  return result;
}

/// Checks if the path is a symbolic link.
/// If the path is a link, it returns true. Otherwise, it returns false.
/// If the path is empty, it throws an [ArgumentError].
bool isLink(String path) {
  if (path.isEmpty) {
    throw ArgumentError('path must not be empty.');
  }

  final fromType = FileSystemEntity.typeSync(path, followLinks: false);
  final isLink = fromType == FileSystemEntityType.link;

  return isLink;
}

/// Checks if the path exists.
/// If the path exists, it returns true. Otherwise, it returns false.
/// If the path is empty, it throws an [ArgumentError].
/// The [followLinks] parameter determines whether to follow symbolic links.
/// If [followLinks] is true, it follows symbolic links. Otherwise, it does not.
/// The default value is true.
bool isExists(String path, {bool followLinks = true}) {
  if (path.isEmpty) {
    throw ArgumentError('path must not be empty.');
  }

  final isExists =
      FileSystemEntity.typeSync(path, followLinks: followLinks) !=
      FileSystemEntityType.notFound;

  return isExists;
}

/// Checks if the directory is empty.
/// If the directory is empty, it returns true. Otherwise, it returns false.
/// If the path is empty, it throws an [ArgumentError].
bool isEmptyDirectory(String pathToDirectory) {
  if (pathToDirectory.isEmpty) {
    throw ArgumentError('path must not be empty.');
  }

  final isEmptyDirectory = Directory(
    pathToDirectory,
  ).listSync(followLinks: false).isEmpty;

  return isEmptyDirectory;
}
