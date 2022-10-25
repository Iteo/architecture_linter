extension StringExtensions on String {
  /// Returns substring from start that ends with first [phrase] in sentence.
  ///
  /// Example:
  /// ```dart
  /// final string = 'This is longer sentence';
  /// print(string.trimTo('longer')); // This is longer
  /// ```
  String trimTo(String phrase) {
    if (phrase.isEmpty) return '';

    final indexOfPhrase = indexOf(phrase);
    if (indexOfPhrase < 0) return '';

    final end = indexOfPhrase + phrase.length;
    return substring(0, end);
  }
}
