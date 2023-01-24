import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import '../configuration/layer.dart';
import '../configuration/banned_imports.dart';
import 'lint_severity.dart';

const keyLayers = 'layers';
const keyExcludes = 'excludes';
const keyBannedImports = 'banned_imports';
const keyLayersConfig = 'layers_config';
const keyLintSeverity = 'lint_severity';

class ProjectConfiguration {
  final List<Layer> layers;
  final List<Glob> excludes;
  final Map<Layer, Set<Layer>> bannedImports;
  final Map<Layer, LintSeverity> bannedImportSeverities;
  final LintSeverity lintSeverity;
  final List<LayerConfig> layersConfig;

  ProjectConfiguration(
    this.layers,
    this.excludes,
    this.bannedImports,
    this.bannedImportSeverities,
    this.lintSeverity,
    this.layersConfig,
  );

  factory ProjectConfiguration.fromMap(Map<dynamic, dynamic> map) {
    final layers = map[keyLayers] == null
        ? <Layer>[]
        : List<Layer>.from(
            (map[keyLayers] as Iterable).map((x) => Layer.fromMap(x)),
          );
    final excludes = map[keyExcludes] == null
        ? <Glob>[]
        : List<Glob>.from(
            ((map[keyExcludes] as Iterable).map((source) => Glob(source))),
          );
    final bannedImportsList = map[keyBannedImports] == null
        ? <BannedImports>[]
        : List<BannedImports>.from(
            (map[keyBannedImports] as Iterable)
                .map((x) => BannedImports.fromMap(x)),
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

    final lintSeverity = lintSeverityFromString(map[keyLintSeverity]);
    final layersConfig = map[keyLayersConfig] == null
        ? <LayerConfig>[]
        : (map[keyLayersConfig] as Iterable)
            .map((e) => LayerConfig.fromMap(e))
            .toList();

    return ProjectConfiguration(
      layers,
      excludes,
      bannedImportsMap,
      bannedImportsSeverityMap,
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
      layers.any((layer) => path.contains(RegExp(layer.path)));

  @override
  int get hashCode => Object.hash(
        lintSeverity,
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
    final isLayersConfig =
        DeepCollectionEquality().equals(layersConfig, other.layersConfig);

    return isLint &&
        isLayers &&
        isExcludes &&
        isBannedImports &&
        isLayersConfig;
  }

  bool _isSameGlobs(List<Glob> other) {
    final patternList = excludes.map((e) => e.pattern).toList();
    final otherPatternList = other.map((e) => e.pattern).toList();
    return patternList.equals(otherPatternList);
  }
}
