import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:architecture_linter/src/configuration_reader/configuration_reader.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

const _pathToMocks = 'test/mocks/';

class FileParseHelper {
  static Future<SomeResolvedUnitResult> parseTestFile(String pathFromMocks) =>
      resolveFile2(
        path: path.normalize(
          path.absolute(
            '$_pathToMocks$pathFromMocks',
          ),
        ),
      );

  static Future<Map<dynamic, dynamic>> parseYamlFile(
      String pathFromMocks) async {
    final unit = await FileParseHelper.parseTestFile(pathFromMocks)
        as ResolvedUnitResult;

    final yamlMap = loadYaml(unit.content) as YamlMap;
    return yamlMapToDartMap(yamlMap);
  }
}
