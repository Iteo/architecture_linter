import 'package:analyzer/dart/analysis/results.dart';
import 'package:test/test.dart';

import '../../helpers/file_parse_helper.dart';
import '../../mocks/architecture_analyzer.dart';
import '../../mocks/config.dart';

void main() {
  const domainPath = '/domain/';

  final architectureAnalyzerImports =
      ArchitectureAnalyzerMocks.baseArchitectureAnalyzer;
  final config = ConfigMocks.baseConfigMock;

  test('Test if other type than dart will be analyzed', () async {
    final htmlFileUnit =
        await FileParseHelper.parseTestFile('${domainPath}html_file.html')
            as ResolvedUnitResult;

    final lints = architectureAnalyzerImports.runAnalysis(
      htmlFileUnit,
      config,
    );
    expect(lints.length, 0);
  });
}
