import 'dart:io';

import 'package:collection/collection.dart';

import '../core/exceptions.dart';

Env env = Env.instance;


final class Env {

  Env._() : _caseSensitive = !Platform.isWindows {
    _envVars = CanonicalizedMap(
      (key) => _caseSensitive ? key : key.toUpperCase(),
    );

    final vars = Platform.environment;
    for (final entry in vars.entries) {
      _envVars.putIfAbsent(entry.key, () => entry.value);
    }
  }

  static Env instance = Env._();

  bool get isCaseSensitive => _caseSensitive;
  final bool _caseSensitive;

  late final Map<String, String> _envVars;

  String? operator [](String key) => _envVars[key];

  bool exists(String key) => _envVars.containsKey(key);

  List<String> get _path {
    final pathEnv = this['PATH'] ?? '';
    return pathEnv.split(':');
  }

  /// Returns the value of the `PATH` environment variable.
  /// Throws a [CliException] if the variable is not found.
  String get home {
    final homeKey = Platform.isWindows ? 'APPDATA' : 'HOME';
    final home = this[homeKey];

    if (home == null) {
      throw CliException('Environment variable $homeKey not found.');
    }

    return home;
  }
}
