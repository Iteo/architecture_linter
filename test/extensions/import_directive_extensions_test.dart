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
      final testImport = TestImportDirective();

      final result = testImport.containsBannedLayer(emptySet);

      expect(result, false);
    });

    test('Test if returns false for layer with empty path', () {
      final emptySet = <Layer>{};
      final testImport = TestImportDirective();
      when(() => testImport.uri.stringValue).thenReturn('');

      final result = testImport.containsBannedLayer(emptySet);

      expect(result, false);
    });

    test('Test if returns false for null import', () {
      final infrastructureLayer = <Layer>{Layer('', '')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.containsBannedLayer(infrastructureLayer);

      expect(result, false);
    });

    test('Test if returns false for layer that is blank', () {
      final infrastructureLayer = <Layer>{Layer('', '')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.containsBannedLayer(infrastructureLayer);

      expect(result, false);
    });

    test('Test if returns false for layer that is not banned', () {
      final infrastructureLayer = <Layer>{Layer('Infra', 'infrastructure')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.containsBannedLayer(infrastructureLayer);

      expect(result, false);
    });

    test('Test if returns true for layer that is banned', () {
      final domainLayer = <Layer>{Layer('Domain', 'domain')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.containsBannedLayer(domainLayer);

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
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.getConfigFromLastInPath(domainConfig);

      expect(result, null);
    });

    test('Test if returns null for empty layer path', () {
      final blankConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('', ''),
        ),
      ];
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.getConfigFromLastInPath(blankConfig);

      expect(result, null);
    });

    test('Test if returns null for import path that is not banned', () {
      final infrastructureConfig = <LayerConfig>[
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Infra', 'infrastructure'),
        ),
      ];
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.getConfigFromLastInPath(
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
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('domain');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.getConfigFromLastInPath(domainConfig);

      expect(result, const TypeMatcher<LayerConfig>());
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
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('/domain/use_case/feature/');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.getConfigFromLastInPath(domainConfig);

      expect(
        result,
        LayerConfig(
          severity: LintSeverity.info,
          layer: Layer('Use Case', '(use_case)'),
        ),
      );
    });
  });

  group('isRelative', () {
    test('Returns false If the path is null', () {
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.isRelative;

      expect(result, false);
    });

    test('Returns false If the path is empty', () {
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.isRelative;

      expect(result, false);
    });

    test('Returns false If the path is an absolute variant', () {
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('package:test/test.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.isRelative;

      expect(result, false);
    });

    test('Returns true If path is exact file name', () {
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('some_file.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.isRelative;

      expect(result, true);
    });

    test('Returns true If path is a file in an upper catalog', () {
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('../some_file.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.isRelative;

      expect(result, true);
    });

    test('Returns true If path is a file in an nested catalog catalog', () {
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('../../some_file.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.isRelative;

      expect(result, true);
    });
  });

  group('existsInBannedLayers', () {
    test('Returns false If layer list is empty', () {
      final emptyList = <Layer>{};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('path');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers('', emptyList);

      expect(result, false);
    });

    test('Returns false If path is null', () {
      final domainConfig = <Layer>{Layer('Domain', 'domain')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers('', domainConfig);

      expect(result, false);
    });

    test('Returns false If path is null', () {
      final domainConfig = <Layer>{Layer('Domain', '(domain)')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers('', domainConfig);

      expect(result, false);
    });

    test('Returns false If source path is empty', () {
      final domainConfig = <Layer>{Layer('Domain', '(domain)')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn(null);
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers('', domainConfig);

      expect(result, false);
    });

    test('Returns true If path corresponds to the same layer', () {
      final domainConfig = <Layer>{Layer('Use case', '(use_cases)')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('test.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers(
        'package:src/domain/use_cases/source.dart',
        domainConfig,
      );

      expect(result, true);
    });

    test('Returns true If path corresponds to the upper banned layer', () {
      final domainConfig = <Layer>{Layer('Domain', '(domain)')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('../test.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers(
        'package:src/domain/use_cases/source.dart',
        domainConfig,
      );

      expect(result, true);
    });

    test('Returns true If path corresponds to the nested upper banned layer',
        () {
      final domainConfig = <Layer>{Layer('Domain', '(domain)')};
      final testImport = TestImportDirective();
      final testUri = TestStringLiteral();
      when(() => testUri.stringValue).thenReturn('../../test.dart');
      when(() => testImport.uri).thenReturn(testUri);

      final result = testImport.existsInBannedLayers(
        'package:src/domain/use_cases/nested/source.dart',
        domainConfig,
      );

      expect(result, true);
    });
  });
}
