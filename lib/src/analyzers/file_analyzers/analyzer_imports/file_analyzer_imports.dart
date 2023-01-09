import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/file_analyzer.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:architecture_linter/src/extensions/custom_lint_extensions.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/lints.dart';

class FileAnalyzerImports implements FileAnalyzer {
  const FileAnalyzerImports({
    this.isCli = false,
  });

  final bool isCli;

  @override
  String get lintCode => "architecture_linter_banned_layer";

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

      if (import.containsBannedLayer(bannedLayers)) {
        final layerConfig = import.getConfigFromLastInPath(config.layersConfig);
        final severity = layerConfig?.severity ?? config.lintSeverity;

        yield unitResult.getBannedLayerLint(
          import,
          currentLayer.displayName,
          lintCode,
          severity,
          !isCli,
        );
      }
    }
    return;
  }

  Layer? _returnCurrentLayerFromPath(
    String path,
    ProjectConfiguration config,
  ) {
    for (final layer in config.layers) {
      final isLayerNameInPath = path.contains(layer.pathRegex);
      if (isLayerNameInPath) return layer;
    }
    return null;
  }
}
