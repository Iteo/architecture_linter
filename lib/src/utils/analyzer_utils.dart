import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:architecture_linter/src/configuration_reader/configuration_reader.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:file/local.dart';

Set<String> getFilePaths(
  Iterable<String> folders,
  AnalysisContext context,
  String rootFolder,
  Iterable<Glob> excludes,
) {
  final rootPath = context.contextRoot.root.path;

  final contextFolders = folders.where((path) {
    final folderPath = normalize(join(rootFolder, path));

    return folderPath == rootPath || folderPath.startsWith('$rootPath/');
  }).toList();

  return _extractDartFilesFromFolders(contextFolders, rootFolder, excludes);
}

Set<String> _extractDartFilesFromFolders(
  Iterable<String> folders,
  String rootFolder,
  Iterable<Glob> globalExcludes,
) =>
    folders
        .expand((fileSystemEntity) => (fileSystemEntity.endsWith('.dart') ? Glob(fileSystemEntity) : Glob('**/**.dart'))
            .listFileSystemSync(
              const LocalFileSystem(),
              root: rootFolder,
              followLinks: false,
            )
            .whereType<io.File>()
            .where((entity) => !isExcluded(
                  relative(entity.path, from: rootFolder),
                  globalExcludes,
                ))
            .map((entity) => normalize(entity.path)))
        .toSet();

bool isExcluded(String absolutePath, Iterable<Glob> excludes) => _hasMatch(absolutePath, excludes);

bool _hasMatch(String absolutePath, Iterable<Glob> excludes) {
  final path = absolutePath.replaceAll(r'\', '/');

  return excludes.any((exclude) => exclude.matches(path));
}

Future<ProjectConfiguration?> createConfig(AnalysisContext analysisContext) async {
  final optionsFile = analysisContext.contextRoot.optionsFile;

  if (optionsFile != null && optionsFile.exists) {
    if (optionsFile.readAsStringSync().isEmpty) {
      return await ConfigurationReader.readConfigurationFromPath(optionsFile.path);
    }

    return ConfigurationReader.readConfiguration(optionsFile);
  }
  return null;
}
