class DependenciesInfo {
  const DependenciesInfo({
    required this.dart,
    required this.npm,
    required this.prisma,
  });

  final String dart;

  final String npm;
  final String prisma;

  @override
  String toString() {
    final result = StringBuffer()
      ..writeln('dart: $dart')
      ..writeln('npm: $npm')
      ..writeln('prisma: $prisma');

    return result.toString();
  }
}
