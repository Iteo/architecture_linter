import 'package:analyzer/file_system/file_system.dart';

import '../configuration/project_configuration.dart';
import 'package:yaml/yaml.dart';

const _rootKey = "architecture_linter";

class ConfigurationReader {
  ProjectConfiguration readConfiguration(File optionsFile) {
    try {
      final node = loadYamlNode(optionsFile.readAsStringSync());
      final optionNode = node is YamlMap ? yamlMapToDartMap(node) : <String, Object>{};

      final rootConfig = optionNode[_rootKey] as Map<String, dynamic>;
      return ProjectConfiguration.fromMap(rootConfig);
    } on YamlException catch (e) {
      throw FormatException(e.message, e.span);
    }
  }
}

Map<String, Object> yamlMapToDartMap(YamlMap map) => Map.unmodifiable(Map<String, Object>.fromEntries(map.nodes.keys
    .whereType<YamlScalar>()
    .where((key) => key.value is String && map.nodes[key]?.value != null)
    .map((key) => MapEntry(
          key.value as String,
          yamlNodeToDartObject(map.nodes[key]),
        ))));

/// Convert yaml [node] to Dart [Object].
Object yamlNodeToDartObject(YamlNode? node) {
  var object = Object();

  if (node is YamlMap) {
    object = yamlMapToDartMap(node);
  } else if (node is YamlList) {
    object = yamlListToDartList(node);
  } else if (node is YamlScalar) {
    object = yamlScalarToDartObject(node);
  }

  return object;
}

List<Object> yamlListToDartList(YamlList list) => List.unmodifiable(list.nodes.map<Object>(yamlNodeToDartObject));

Object yamlScalarToDartObject(YamlScalar scalar) => scalar.value as Object;
