import 'package:path/path.dart' as path;

/// Creates an absolute and normalized path from the given parts.
///
/// This function takes a variable number of string arguments representing
/// different parts of a path. It joins them together, converts the result
/// to an absolute path, and then normalizes it. The resulting path is
/// returned as a string.
String truePath(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
]) {
  final joined = path.join(part1, part2, part3, part4, part5, part6, part7);
  final absolute = path.absolute(joined);
  final normalized = path.normalize(absolute);

  return normalized;
}

String privatePath(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
]) => '';
