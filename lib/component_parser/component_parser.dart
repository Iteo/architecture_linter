class ComponentParser {

  bool containsSegment(List<String> components, String segment) =>
    components.any((component) => component.contains(segment));

  String findMatching(List<String> components, RegExp pattern) =>
      components.firstWhere((component) => pattern.hasMatch(component));
}