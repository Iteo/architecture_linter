import 'package:analyzer/dart/analysis/results.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';
import 'package:test/test.dart';

import '../../helpers/file_parse_helper.dart';
import '../../mocks/architecture_analyzer.dart';
import '../../mocks/config.dart';

void main() {
  final domainPath = '/domain/';

  final architectureAnalyzerImports =
      ArchitectureAnalyzerMocks.baseArchitectureAnalyzer;
  final config = ConfigMocks.baseConfigMock;

  test("Test if analyzer will respect severity config for lower level layer",
      () async {
    final domainClassUnit =
        await FileParseHelper.parseTestFile('${domainPath}domain_class.dart')
            as ResolvedUnitResult;

    final lints = architectureAnalyzerImports.runAnalysis(
      domainClassUnit,
      config,
    );
    final baseConfigLints = lints.where((element) =>
        element.severity == config.lintSeverity.analysisErrorSeverity);
    final loweLayerConfigLints = lints.where((element) => config.layersConfig
        .any((layerConfig) =>
            layerConfig.severity.analysisErrorSeverity == element.severity));

    expect(baseConfigLints.length, 3);
    expect(loweLayerConfigLints.length, 1);
  });
}
