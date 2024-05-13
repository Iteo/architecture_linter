import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

class ImportDirectiveUtils {
  static bool containsBannedLayer(
    Set<Layer> bannedLayers,
    String? importUri,
  ) {
    final directoryName = path.dirname(importUri ?? '');

    for (final banned in bannedLayers) {
      if (importUri != null && RegExp(banned.path).hasMatch(directoryName)) {
        return true;
      }
    }
    return false;
  }

  static LayerConfig? getConfigFromLastInPath(
    List<LayerConfig> configs,
    String? importUri,
  ) {
    final configMap = <int, LayerConfig>{};

    for (final config in configs) {
      final gotConfigForPath = importUri != null &&
          config.layer.path.isNotEmpty &&
          RegExp(config.layer.path).hasMatch(importUri);
      if (gotConfigForPath) {
        final index = importUri.indexOf(config.layer.path);
        configMap[index] = config;
      }
    }

    if (configMap.keys.isEmpty) return null;
    final biggestIndex = configMap.keys.max;

    return configMap[biggestIndex];
  }

  static bool isRelative(String? importUri) {
    if (importUri == null) return false;
    if (importUri.isEmpty) return false;
    if (Uri.parse(importUri).isAbsolute) return false;
    return true;
  }

  static bool existsInBannedLayers(
    String sourceFile,
    Set<Layer> layers,
    String? importUri,
  ) {
    if (importUri == null) return false;
    if (importUri.isEmpty) return false;
    if (sourceFile.isEmpty) return false;

    final absoluteImport = path.normalize(
      path.join(sourceFile, '../', importUri),
    );

    for (final layer in layers) {
      // Always check path (/STH) in order to avoid matching file_STH_a.dart
      final segment = '/${layer.path}';
      if (RegExp(segment).hasMatch(absoluteImport)) {
        return true;
      }
    }

    return false;
  }
}
