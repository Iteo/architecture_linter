import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:collection/collection.dart';

extension ImportDirectiveExtension on ImportDirective {
  // TODO Supply unit test
  bool containsBannedLayer(Set<Layer> bannedLayers) {
    for (final banned in bannedLayers) {
      if (uri.stringValue != null &&
          banned.pathRegex.hasMatch(uri.stringValue!)) {
        return true;
      }
    }
    return false;
  }

  LayerConfig? getConfigFromLastInPath(List<LayerConfig> configs) {
    final configMap = <int, LayerConfig>{};

    for (final config in configs) {
      final gotConfigForPath = uri.stringValue != null &&
          config.layer.pathRegex.hasMatch(uri.stringValue!);
      if (gotConfigForPath) {
        final index = uri.stringValue!.indexOf(config.layer.pathRegex);
        configMap[index] = config;
      }
    }
    if (configMap.keys.isEmpty) return null;
    final biggestIndex = configMap.keys.max;

    return configMap[biggestIndex];
  }
}
