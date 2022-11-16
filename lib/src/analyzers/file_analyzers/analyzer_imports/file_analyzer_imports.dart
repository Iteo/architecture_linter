import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/file_analyzer.dart';
import 'package:architecture_linter/src/extensions/custom_lint_extensions.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/lints.dart';

import '../../../configuration/layer.dart';
import '../../../configuration/project_configuration.dart';

class FileAnalyzerImports implements FileAnalyzer {
  @override
  AnalysisError? analyzeFile(ResolvedUnitResult unitResult, ProjectConfiguration config) {
    final path = unitResult.path;
    final currentLayer = _returnCurrentLayerFromPath(path, config);

    if (currentLayer == null) return null;

    final importDirectives = unitResult.unit.directives.whereType<ImportDirective>().toList();

    for (final import in importDirectives) {
      final bannedLayers = config.bannedImports[currentLayer];

      if (bannedLayers == null) return null;

      if (import.containsBannedLayer(bannedLayers)) {
        return unitResult.getBannedLayerLint(import, currentLayer.displayName);
      }
    }
    return null;
  }

  Layer? _returnCurrentLayerFromPath(String path, ProjectConfiguration config) {
    for (final layer in config.layers) {
      final isLayerNameInPath = path.contains(layer.pathRegex);
      if (isLayerNameInPath) return layer;
    }
    return null;
  }
}
