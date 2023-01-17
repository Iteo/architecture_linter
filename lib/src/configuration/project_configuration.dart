import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import '../configuration/layer.dart';
import '../configuration/banned_class_name.dart';
import '../configuration/banned_imports.dart';
import 'lint_severity.dart';

class ProjectConfiguration {
  final List<Layer> layers;
  final List<Glob> excludes;
  final Map<Layer, Set<Layer>> bannedImports;
  final Map<Layer, LintSeverity> bannedImportSeverities;
  final Map<Layer, Set<RegExp>> bannedClassNames;
  final LintSeverity lintSeverity;
  final List<LayerConfig> layersConfig;

  ProjectConfiguration(
    this.layers,
    this.excludes,
    this.bannedImports,
    this.bannedImportSeverities,
    this.bannedClassNames,
    this.lintSeverity,
    this.layersConfig,
  );

  factory ProjectConfiguration.fromMap(Map<dynamic, dynamic> map) {
    final layers = map['layers'] == null
        ? <Layer>[]
        : List<Layer>.from(
            (map['layers'] as Iterable).map((x) => Layer.fromMap(x)),
          );
    final excludes = map['excludes'] == null
        ? <Glob>[]
        : List<Glob>.from(
            ((map['excludes'] as Iterable).map((source) => Glob(source))),
          );
    final bannedImportsList = map['bannedImports'] == null
        ? <BannedImports>[]
        : List<BannedImports>.from(
            (map['bannedImports'] as Iterable)
                .map((x) => BannedImports.fromMap(x)),
          );
    final bannedClassNamesList = map['bannedClassNames'] == null
        ? <BannedClassName>[]
        : List<BannedClassName>.from(
            (map['bannedClassNames'] as Iterable)
                .map((x) => BannedClassName.fromMap(x)),
          );

    final bannedImportsMap = <Layer, Set<Layer>>{};
    final bannedImportsSeverityMap = <Layer, LintSeverity>{};
    for (final bannedConnection in bannedImportsList) {
      bannedImportsMap[bannedConnection.layer] =
          bannedConnection.cannotImportFrom.toSet();
      if (bannedConnection.severity != null) {
        bannedImportsSeverityMap[bannedConnection.layer] =
            bannedConnection.severity!;
      }
    }

    final bannedClassNamesMap = <Layer, Set<RegExp>>{};
    for (final bannedClassName in bannedClassNamesList) {
      bannedClassNamesMap[bannedClassName.layer] =
          bannedClassName.bannedClassNames.toSet();
    }
    final lintSeverity = lintSeverityFromString(map['lint_severity']);
    final layersConfig = map['layers_config'] == null
        ? <LayerConfig>[]
        : (map['layers_config'] as Iterable)
            .map((e) => LayerConfig.fromMap(e))
            .toList();

    return ProjectConfiguration(
      layers,
      excludes,
      bannedImportsMap,
      bannedImportsSeverityMap,
      bannedClassNamesMap,
      lintSeverity,
      layersConfig,
    );
  }

  bool isPathExcluded(String path) => _hasMatch(path, excludes);

  bool _hasMatch(String absolutePath, Iterable<Glob> excludes) {
    final path = absolutePath.replaceAll(r'\', '/');

    return excludes.any((exclude) => exclude.matches(path));
  }

  bool isPathLayer(String path) =>
      layers.any((layer) => path.contains(layer.pathRegex));

  @override
  int get hashCode => Object.hash(
        lintSeverity,
        bannedClassNames,
        layers,
        excludes,
        bannedImports,
        layersConfig,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProjectConfiguration) return false;

    final isLint = lintSeverity == other.lintSeverity;
    final isLayers = layers.equals(other.layers);
    final isExcludes = _isSameGlobs(other.excludes);
    final isBannedImports =
        DeepCollectionEquality().equals(bannedImports, other.bannedImports);
    final isBannedClassNames = DeepCollectionEquality()
        .equals(bannedClassNames, other.bannedClassNames);
    final isLayersConfig =
        DeepCollectionEquality().equals(layersConfig, other.layersConfig);

    return isLint &&
        isLayers &&
        isExcludes &&
        isBannedImports &&
        isBannedClassNames &&
        isLayersConfig;
  }

  bool _isSameGlobs(List<Glob> other) {
    final patternList = excludes.map((e) => e.pattern).toList();
    final otherPatternList = other.map((e) => e.pattern).toList();
    return patternList.equals(otherPatternList);
  }
}
