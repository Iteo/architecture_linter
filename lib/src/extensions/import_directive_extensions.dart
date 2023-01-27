import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

extension ImportDirectiveExtension on ImportDirective {
  // TODO(tomkad99): Supply unit test
  bool containsBannedLayer(Set<Layer> bannedLayers) {
    final directoryName = path.dirname(uri.stringValue ?? '');

    for (final banned in bannedLayers) {
      if (uri.stringValue != null &&
          RegExp(banned.path).hasMatch(directoryName)) {
        return true;
      }
    }
    return false;
  }

  LayerConfig? getConfigFromLastInPath(List<LayerConfig> configs) {
    final configMap = <int, LayerConfig>{};

    for (final config in configs) {
      final gotConfigForPath = uri.stringValue != null &&
          config.layer.path.isNotEmpty &&
          RegExp(config.layer.path).hasMatch(uri.stringValue!);
      if (gotConfigForPath) {
        final index = uri.stringValue!.indexOf(config.layer.path);
        configMap[index] = config;
      }
    }
    if (configMap.keys.isEmpty) return null;
    final biggestIndex = configMap.keys.max;

    return configMap[biggestIndex];
  }
}
