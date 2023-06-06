import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';

@freezed
class GeneratorConfig with _$GeneratorConfig {
  factory GeneratorConfig() = _GeneratorConfig;
}
