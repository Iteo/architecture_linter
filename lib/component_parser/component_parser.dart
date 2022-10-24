import 'package:collection/collection.dart';

class ComponentParser {
  bool containsSegment(List<String> components, String segment) =>
    components.any((component) => component.contains(segment));

  String? findMatching(List<String> components, RegExp pattern) =>
      components.firstWhereOrNull((component) => pattern.hasMatch(component));
}