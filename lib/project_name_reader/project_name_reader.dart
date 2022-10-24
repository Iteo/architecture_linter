import 'package:architecture_linter/component_parser/component_parser.dart';

class ProjectNameReader {
  final parser = ComponentParser();

  String readRootName(List<String>? components) {
    final packageEntryPoint = "/main";
    final packageIdPattern = r'(.+:.+\/.+)'; // A:B/C
    var rootName = "";

    if (components == null || components.isEmpty) return rootName;
    if (!parser.containsSegment(components, packageEntryPoint)) return rootName;

    // Find path variant that matches pattern 'package:root/path'
    final foundComponent = parser.findMatching(components, RegExp(packageIdPattern));
    final packageIdentifier = foundComponent.split("/").first;
    rootName = packageIdentifier.split(":").elementAt(1);

    return rootName;
  }
}

extension StringExtension on String {
  String trimTo(String phrase) {
    final end = indexOf(phrase) + phrase.length;
    return substring(0, end);
  }
}
