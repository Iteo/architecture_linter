import 'package:analyzer/dart/analysis/results.dart';
import 'package:test/test.dart';

import '../../helpers/file_parse_helper.dart';
import '../../mocks/config.dart';

void main() {
  final domainPath = '/domain/';
  final config = ConfigMocks.baseConfigMock;

  test(
    "Tests exclude on file pattern",
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
          '${domainPath}domain_class.g.dart') as ResolvedUnitResult;

      final unitPath = domainClassUnit.path;
      expect(config.isPathExcluded(unitPath), true);
    },
  );

  test(
    "Tests exclude on folder pattern",
    () async {
      final domainClassUnit = await FileParseHelper.parseTestFile(
          '${domainPath}some_folder/domain_class.dart') as ResolvedUnitResult;

      final unitPath = domainClassUnit.path;
      expect(config.isPathExcluded(unitPath), true);
    },
  );
}
