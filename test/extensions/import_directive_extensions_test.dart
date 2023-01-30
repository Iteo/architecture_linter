import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';
import 'package:architecture_linter/src/extensions/import_directive_extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class TestImportDirective extends Mock implements ImportDirective {}

class TestStringLiteral extends Mock implements StringLiteral {}

class TestLayerConfig extends Mock implements LayerConfig {}

void main() {
  group('containsBannedLayer', () {
    test('Test if returns false for empty set parameter', () {
      final emptySet = <Layer>{};
      final importDirective = TestImportDirective();

      final result = importDirective.containsBannedLayer(emptySet);

      expect(result, false);
    });

    test('Test if returns false for layer with empty path', () {
      final emptySet = <Layer>{};
      final importDirective = TestImportDirective();
      when(() => importDirective.uri.stringValue).thenReturn('');

      final result = importDirective.containsBannedLayer(emptySet);

      expect(result, false);
    });

    test('Test if returns false for null import', () {
      final infrastructureLayer = <Layer>{Layer('', '')};
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.containsBannedLayer(infrastructureLayer);

      expect(result, false);
    });

    test('Test if returns false for layer that is blank', () {
      final infrastructureLayer = <Layer>{Layer('', '')};
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.containsBannedLayer(infrastructureLayer);

      expect(result, false);
    });

    test('Test if returns false for layer that is not banned', () {
      final infrastructureLayer = <Layer>{Layer('Infra', 'infrastructure')};
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.containsBannedLayer(infrastructureLayer);

      expect(result, false);
    });

    test('Test if returns true for layer that is banned', () {
      final domainLayer = <Layer>{Layer('Domain', 'domain')};
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.containsBannedLayer(domainLayer);

      expect(result, true);
    });
  });

  group('getConfigFromLastInPath', () {
    test('Test if returns null for empty list of layer configurations', () {
      final emptyList = <LayerConfig>[];

      final result = TestImportDirective().getConfigFromLastInPath(emptyList);

      expect(result, null);
    });

    test('Test if returns null for null import', () {
      final domainConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Domain', 'domain'),
        ),
      ];
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.getConfigFromLastInPath(domainConfig);

      expect(result, null);
    });

    test('Test if returns null for empty layer path', () {
      final blankConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('', ''),
        ),
      ];
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.getConfigFromLastInPath(blankConfig);

      expect(result, null);
    });

    test('Test if returns null for import path that is not banned', () {
      final infrastructureConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Infra', 'infrastructure'),
        ),
      ];
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.getConfigFromLastInPath(
        infrastructureConfig,
      );

      expect(result, null);
    });

    test('Test if returns a config for a single layer', () {
      final domainConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Domain', 'domain'),
        ),
      ];
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.getConfigFromLastInPath(domainConfig);

      expect(result, TypeMatcher<LayerConfig>());
    });

    test('Test if returns a config for the last one in path', () {
      final domainConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Domain', '(domain)'),
        ),
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Use Case', '(use_case)'),
        ),
      ];
      final importDirective = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('/domain/use_case/feature/');
      when(() => importDirective.uri).thenReturn(testUri);

      final result = importDirective.getConfigFromLastInPath(domainConfig);

      expect(
        result,
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Use Case', '(use_case)'),
        ),
      );
    });
  });
}
