import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:test/test.dart';

import '../../helpers/file_parse_helper.dart';
import '../../mocks/config.dart';

void main() {
  test(
    "Test if configuration is read properly ",
    () async {
      final map = await FileParseHelper.parseYamlFile("base_config.yaml");
      final configMap = map["architecture_linter"];
      final config =
          ProjectConfiguration.fromMap(configMap as Map<dynamic, dynamic>);

      expect(
        config,
        ConfigMocks.baseConfigMock,
      );
    },
  );
}
