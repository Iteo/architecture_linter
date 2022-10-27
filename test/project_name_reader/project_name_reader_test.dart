import 'package:architecture_linter/src/project_name_reader/project_name_reader.dart';
import 'package:test/test.dart';

void main() {
  group('readRootName', () {
    test('Returns empty phrase for null list of components', () {
      // Given
      final reader = ProjectNameReader();
      final components = null;
      // When
      final result = reader.readRootName(components);
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns empty phrase for empty list of components', () {
      // Given
      final reader = ProjectNameReader();
      final components = List<String>.empty();
      // When
      final result = reader.readRootName(components);
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns empty phrase for components not matching package pattern', () {
      // Given
      final reader = ProjectNameReader();
      final components = ['package', 'package:', '/main', '/main/lib', 'package:text'];
      // When
      final result = reader.readRootName(components);
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns empty phrase for components not matching entry point', () {
      // Given
      final reader = ProjectNameReader();
      final components = ['package:test/bin.dart'];
      // When
      final result = reader.readRootName(components, entryPoint: 'main');
      // Then
      expect(result.isEmpty, true);
    });

    test('Returns root phrase for at least one matching patter component', () {
      // Given
      final reader = ProjectNameReader();
      final components = ['package:test/bin.dart', 'package:test1/main.dart'];
      // When
      final result = reader.readRootName(components, entryPoint: 'main');
      // Then
      expect(result, 'test1');
    });
  });
}
