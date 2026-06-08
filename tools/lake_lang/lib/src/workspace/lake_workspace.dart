import 'dart:io';

import '../parser/ast/ast_base.dart';
import '../parser/lake_parser.dart';
import 'lake_module.dart';

class LakeWorkspace {
  final Map<String, LakeModule> _cache = {};

  /// Exposes the current cache of compiled modules.
  Map<String, LakeModule> get cache => _cache;

  /// Compiles a file by its path using the zero-allocation parser.
  /// If dependencies change, dependent files in the graph can be invalidated.
  LakeModule compileFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', path);
    }

    final input = file.readAsStringSync();
    final parser = LakeParser(input);
    final ast = parser.parseDocument();

    // Flat headers search to extract imports quickly without deep traversing
    final dependencies = <String>[];
    for (final header in ast.headers) {
      if (header is ImportNode) {
        dependencies.add(header.path.value);
      }
    }

    final oldModule = _cache[path];
    if (oldModule != null) {
      var depsChanged = oldModule.dependencies.length != dependencies.length;
      if (!depsChanged) {
        for (var i = 0; i < dependencies.length; i++) {
          if (oldModule.dependencies[i] != dependencies[i]) {
            depsChanged = true;
            break;
          }
        }
      }

      if (depsChanged) {
        // Here we would invalidate dependent modules in a real IDE server 
        // scenario. For now, it signals that the dependency graph needs an 
        // update.
      }
    }

    final module = LakeModule(
      path: path,
      ast: ast,
      dependencies: dependencies,
    );
    _cache[path] = module;
    return module;
  }
}
