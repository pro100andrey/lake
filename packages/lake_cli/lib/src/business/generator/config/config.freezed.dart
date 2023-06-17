// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Config {
  String get lakeInstallDir => throw _privateConstructorUsedError;
  String get lakeUserDir => throw _privateConstructorUsedError;
  String get generatePath => throw _privateConstructorUsedError;
  Logger get logger => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConfigCopyWith<Config> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigCopyWith<$Res> {
  factory $ConfigCopyWith(Config value, $Res Function(Config) then) =
      _$ConfigCopyWithImpl<$Res, Config>;
  @useResult
  $Res call(
      {String lakeInstallDir,
      String lakeUserDir,
      String generatePath,
      Logger logger});
}

/// @nodoc
class _$ConfigCopyWithImpl<$Res, $Val extends Config>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lakeInstallDir = null,
    Object? lakeUserDir = null,
    Object? generatePath = null,
    Object? logger = null,
  }) {
    return _then(_value.copyWith(
      lakeInstallDir: null == lakeInstallDir
          ? _value.lakeInstallDir
          : lakeInstallDir // ignore: cast_nullable_to_non_nullable
              as String,
      lakeUserDir: null == lakeUserDir
          ? _value.lakeUserDir
          : lakeUserDir // ignore: cast_nullable_to_non_nullable
              as String,
      generatePath: null == generatePath
          ? _value.generatePath
          : generatePath // ignore: cast_nullable_to_non_nullable
              as String,
      logger: null == logger
          ? _value.logger
          : logger // ignore: cast_nullable_to_non_nullable
              as Logger,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$$_ConfigCopyWith(_$_Config value, $Res Function(_$_Config) then) =
      __$$_ConfigCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String lakeInstallDir,
      String lakeUserDir,
      String generatePath,
      Logger logger});
}

/// @nodoc
class __$$_ConfigCopyWithImpl<$Res>
    extends _$ConfigCopyWithImpl<$Res, _$_Config>
    implements _$$_ConfigCopyWith<$Res> {
  __$$_ConfigCopyWithImpl(_$_Config _value, $Res Function(_$_Config) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lakeInstallDir = null,
    Object? lakeUserDir = null,
    Object? generatePath = null,
    Object? logger = null,
  }) {
    return _then(_$_Config(
      lakeInstallDir: null == lakeInstallDir
          ? _value.lakeInstallDir
          : lakeInstallDir // ignore: cast_nullable_to_non_nullable
              as String,
      lakeUserDir: null == lakeUserDir
          ? _value.lakeUserDir
          : lakeUserDir // ignore: cast_nullable_to_non_nullable
              as String,
      generatePath: null == generatePath
          ? _value.generatePath
          : generatePath // ignore: cast_nullable_to_non_nullable
              as String,
      logger: null == logger
          ? _value.logger
          : logger // ignore: cast_nullable_to_non_nullable
              as Logger,
    ));
  }
}

/// @nodoc

class _$_Config implements _Config {
  _$_Config(
      {required this.lakeInstallDir,
      required this.lakeUserDir,
      required this.generatePath,
      required this.logger});

  @override
  final String lakeInstallDir;
  @override
  final String lakeUserDir;
  @override
  final String generatePath;
  @override
  final Logger logger;

  @override
  String toString() {
    return 'Config(lakeInstallDir: $lakeInstallDir, lakeUserDir: $lakeUserDir, generatePath: $generatePath, logger: $logger)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Config &&
            (identical(other.lakeInstallDir, lakeInstallDir) ||
                other.lakeInstallDir == lakeInstallDir) &&
            (identical(other.lakeUserDir, lakeUserDir) ||
                other.lakeUserDir == lakeUserDir) &&
            (identical(other.generatePath, generatePath) ||
                other.generatePath == generatePath) &&
            (identical(other.logger, logger) || other.logger == logger));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, lakeInstallDir, lakeUserDir, generatePath, logger);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ConfigCopyWith<_$_Config> get copyWith =>
      __$$_ConfigCopyWithImpl<_$_Config>(this, _$identity);
}

abstract class _Config implements Config {
  factory _Config(
      {required final String lakeInstallDir,
      required final String lakeUserDir,
      required final String generatePath,
      required final Logger logger}) = _$_Config;

  @override
  String get lakeInstallDir;
  @override
  String get lakeUserDir;
  @override
  String get generatePath;
  @override
  Logger get logger;
  @override
  @JsonKey(ignore: true)
  _$$_ConfigCopyWith<_$_Config> get copyWith =>
      throw _privateConstructorUsedError;
}
