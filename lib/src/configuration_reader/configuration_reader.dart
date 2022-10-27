import 'dart:io';
import 'package:path/path.dart' as path;

import '../configuration/project_configuration.dart';
import 'package:yaml/yaml.dart';

class ConfigurationReader {
  Future<bool> pubspecFileExist(String inputPath) async {
    final pubspecFilePath =
        path.normalize(path.join(inputPath, 'pubspec.yaml'));
    final pubspecFile = File(pubspecFilePath);
    return pubspecFile.exists();
  }

  Future<bool> architectureFileExist(
      String inputPath, String configurationFileName) async {
    final architectureFilePath =
        path.normalize(path.join(inputPath, configurationFileName));
    final configurationFile = File(architectureFilePath);
    return configurationFile.exists();
  }

  Future<ProjectConfiguration> readConfiguration(
      String input, String architectureConfigFileName) async {
    final architectureFilePath =
        path.normalize(path.join(input, architectureConfigFileName));
    final architectureFile = File(architectureFilePath);
    final architectureFileContent = await architectureFile.readAsString();
    var doc = loadYaml(architectureFileContent);
    return ProjectConfiguration.fromMap(doc.value);
  }
}
