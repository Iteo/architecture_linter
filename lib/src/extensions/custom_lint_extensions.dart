import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/configuration/layer.dart';

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
}
