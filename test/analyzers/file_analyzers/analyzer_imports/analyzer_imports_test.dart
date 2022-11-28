import 'package:analyzer/dart/analysis/results.dart';
import 'package:architecture_linter/src/analyzers/architecture_analyzer/architecture_analyzer.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';
import 'package:test/test.dart';

import '../../helpers/file_parse_helper.dart';
import '../../mocks/imports_mock/import_mocks_config.dart';

void main() {
  final domainPath = '/imports_mock/domain/';

  final architectureAnalyzerImports =
      ArchitectureAnalyzer(currentFileAnalyzers: [FileAnalyzerImports()]);

  test(
    'Tests if analyzer will return two lints for domain_class.dart',
    () async {
      final domainClassUnit =
          await FileParseHelper.parseTestFile('${domainPath}domain_class.dart')
              as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        ImportMocksConfig.presentationDomainFlutterBannedLayers,
      );
      expect(lints.length, 2);
    },
  );

  test(
    'Tests if analyzer will respect // ignore and return one lint',
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
          '${domainPath}domain_class_ignore.dart') as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        ImportMocksConfig.presentationDomainFlutterBannedLayers,
      );
      expect(lints.length, 1);
    },
  );

  test(
    'Tests if analyzer will respect // ignore_for_file and return 0 lints',
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
              '${domainPath}domain_class_ignore_for_file.dart')
          as ResolvedUnitResult;

      final lints = architectureAnalyzerImports.runAnalysis(
        domainClassUnit,
        ImportMocksConfig.presentationDomainFlutterBannedLayers,
      );
      expect(lints.length, 0);
    },
  );
}
