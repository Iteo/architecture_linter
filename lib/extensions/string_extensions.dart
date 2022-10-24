extension TrimExtension on String {
  String trimTo(String phrase) {
    final end = indexOf(phrase) + phrase.length;
    return substring(0, end);
  }
}
