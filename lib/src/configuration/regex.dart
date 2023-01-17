// TODO Delete or refactor usage in project
class Regex {
  static RegExp fromMap(Map<dynamic, dynamic> map) {
    return RegExp(
      map['source'],
      caseSensitive: map['caseSensitive'] ?? true,
      dotAll: map['dotAll'] ?? false,
      multiLine: map['multiLine'] ?? false,
      unicode: map['unicode'] ?? false,
    );
  }
}
