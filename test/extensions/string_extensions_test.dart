import 'package:architecture_linter/src/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('trimTo', () {
    test('Returns empty result for blank base', () {
      // Given
      final content = '';
      // When
      final result = content.trimTo('');
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns empty result for blank argument', () {
      // Given
      final content = '';
      // When
      final result = content.trimTo('test');
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns empty result for unknown phrase in string', () {
      // Given
      final content = 'This is mine';
      // When
      final result = content.trimTo('test');
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns substring till first occurrence of phrase in string', () {
      // Given
      final content = 'This test is test';
      // When
      final result = content.trimTo('test');
      // Then
      expect(result, 'This test');
    });

    test('Returns whole string when it ends with phrase', () {
      // Given
      final content = 'This sentence is test';
      // When
      final result = content.trimTo('test');
      // Then
      expect(result, content);
    });
  });
}
