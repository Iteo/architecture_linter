import '../configuration/layer.dart';
import '../configuration/banned_class_name.dart';
import '../configuration/banned_imports.dart';
import '../configuration/regex.dart';

class ProjectConfiguration {
  final List<Layer> layers;
  final List<RegExp> excludePaths;
  final Map<Layer, Set<Layer>> bannedImports;
  final Map<Layer, Set<RegExp>> bannedClassNames;

  ProjectConfiguration(
    this.layers,
    this.excludePaths,
    this.bannedImports,
    this.bannedClassNames,
  );

  factory ProjectConfiguration.fromMap(Map<dynamic, dynamic> map) {
    final layers = map['layers'] == null
        ? <Layer>[]
        : List<Layer>.from(
            (map['layers'] as Iterable).map((x) => Layer.fromMap(x)),
          );
    final excludePaths = map['excludePaths'] == null
        ? <RegExp>[]
        : List<RegExp>.from(
            ((map['excludePaths'] as Iterable).map((x) => Regex.fromMap(x))),
          );
    final bannedImportsList = map['bannedImports'] == null
        ? <BannedImports>[]
        : List<BannedImports>.from(
            (map['bannedImports'] as Iterable).map((x) => BannedImports.fromMap(x)),
          );
    final bannedClassNamesList = map['bannedClassNames'] == null
        ? <BannedClassName>[]
        : List<BannedClassName>.from(
            (map['bannedClassNames'] as Iterable).map((x) => BannedClassName.fromMap(x)),
          );

    final bannedImportsMap = <Layer, Set<Layer>>{};
    for (final bannedConnection in bannedImportsList) {
      bannedImportsMap[bannedConnection.layer] = bannedConnection.cannotImportFrom.toSet();
    }

    final bannedClassNamesMap = <Layer, Set<RegExp>>{};
    for (final bannedClassName in bannedClassNamesList) {
      bannedClassNamesMap[bannedClassName.layer] = bannedClassName.bannedClassNames.toSet();
    }

    return ProjectConfiguration(
      layers,
      excludePaths,
      bannedImportsMap,
      bannedClassNamesMap,
    );
  }
}
