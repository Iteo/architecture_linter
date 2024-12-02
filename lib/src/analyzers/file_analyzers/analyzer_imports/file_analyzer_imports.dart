import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/lints.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/file_analyzer.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:architecture_linter/src/utils/import_directive_utils.dart';

class FileAnalyzerImports implements FileAnalyzer {
  const FileAnalyzerImports({
    this.isCli = false,
  });

  final bool isCli;

  @override
  String get lintCode => 'architecture_linter_banned_layer';

  @override
  Iterable<AnalysisError> analyzeFile(
    ResolvedUnitResult unitResult,
    ProjectConfiguration config,
  ) sync* {
    final path = unitResult.path;
    final currentLayer = _returnCurrentLayerFromPath(
      path,
      config,
    );

    if (currentLayer == null) return;

    final importDirectives =
        unitResult.unit.directives.whereType<ImportDirective>().toList();

    for (final import in importDirectives) {
      final bannedLayers = config.bannedImports[currentLayer];

      if (bannedLayers == null) return;

      if (!resolvedAsBannedImport(import, path, bannedLayers)) {
        return;
      }

      final layerConfig = ImportDirectiveUtils.getConfigFromLastInPath(
        config.layersConfig,
        import.uri.stringValue,
      );
      final severity = _getNearestSeverity(
        layerConfig?.severity,
        config.lintSeverity,
        config.bannedImportSeverities[currentLayer],
      );

      yield unitResult.getBannedLayerLint(
        import,
        currentLayer.displayName,
        lintCode,
        severity,
        showCode: !isCli,
      );
    }

    return;
  }

  Layer? _returnCurrentLayerFromPath(
    String path,
    ProjectConfiguration config,
  ) {
    for (final layer in config.layers) {
      final isLayerNameInPath = RegExp(layer.path).hasMatch(path);
      if (isLayerNameInPath) return layer;
    }
    return null;
  }

  LintSeverity _getNearestSeverity(
    LintSeverity? layerConfigSeverity,
    LintSeverity configLintSeverity,
    LintSeverity? bannedImportSeverity,
  ) {
    if (bannedImportSeverity != null) {
      return bannedImportSeverity;
    }

    return layerConfigSeverity ?? configLintSeverity;
  }

  bool resolvedAsBannedImport(
    ImportDirective import,
    String path,
    Set<Layer> bannedLayers,
  ) {
    if (ImportDirectiveUtils.isRelative(import.uri.stringValue)) {
      return ImportDirectiveUtils.existsInBannedLayers(
        path,
        bannedLayers,
        import.uri.stringValue,
      );
    } else {
      return ImportDirectiveUtils.containsBannedLayer(
        bannedLayers,
        import.uri.stringValue,
      );
    }
  }
}
