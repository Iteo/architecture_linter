import 'package:architecture_linter/component_parser/component_parser.dart';

class ProjectNameReader {
  final parser = ComponentParser();

  String readRootName(List<String>? components, {entryPoint = 'main'}) {
    final packageIdPattern = r'(.+:.+\/' + '$entryPoint' + ')'; // A:B/C
    var rootName = "";

    if (components == null || components.isEmpty) return rootName;
    if (!parser.containsSegment(components, entryPoint)) return rootName;

    // Find path variant that matches pattern 'package:root/path'
    final foundComponent = parser.findMatching(components, RegExp(packageIdPattern));
    if (foundComponent == null) return rootName;

    final packageIdentifier = foundComponent.split("/").first;
    rootName = packageIdentifier.split(":").elementAt(1);

    return rootName;
  }
}
