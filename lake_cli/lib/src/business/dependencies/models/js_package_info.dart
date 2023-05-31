import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'js_package_info.g.dart';

@JsonSerializable()
class JsPackageInfo {
  const JsPackageInfo({
    required this.version,
  });

  factory JsPackageInfo.prisma(String source) => JsPackageInfo.fromJson(
        _packageInfo('prisma', source),
      );

  factory JsPackageInfo.fromJson(Map<String, dynamic> json) =>
      _$JsPackageInfoFromJson(json);

  final String version;

  Map<String, dynamic> toJson() => _$JsPackageInfoToJson(this);
}

Map<String, dynamic> _packageInfo(String name, String source) {
  final data = json.decode(source) as Map<String, dynamic>;
  final dependencies = data['dependencies'] as Map<String, dynamic>;
  final packageInfo = dependencies[name] as Map<String, dynamic>;

  return packageInfo;
}
