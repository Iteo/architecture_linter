import 'package:analyzer_plugin/utilities/pair.dart';
import 'package:architecture_linter/src/configuration/layer.dart';

extension LayerExtension on Map<Layer, Set<Layer>> {

  // TODO Supply unit test
  Pair<Layer, Set<Layer>>? getLayerForPath(String currentPath) {
    try {
      final foundLayer = keys.firstWhere((layer) => layer.pathRegex.hasMatch(currentPath));
      return Pair(foundLayer, this[foundLayer] ?? {});
    } catch (_) {
      return null;
    }
  }
}