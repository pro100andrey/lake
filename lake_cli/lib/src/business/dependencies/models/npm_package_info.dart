import 'package:json_annotation/json_annotation.dart';

part 'npm_package_info.g.dart';

@JsonSerializable()
class NpmPackageInfo {
  const NpmPackageInfo({
    required this.name,
  });

  final String name;
}
