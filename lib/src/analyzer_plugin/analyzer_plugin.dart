import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:architecture_linter/src/analyzers/architecture_analyzer/architecture_analyzer.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';
import 'package:architecture_linter/src/utils/analyzer_utils.dart';

import '../configuration/configuration_lints.dart';
import '../configuration/project_configuration.dart';

class AnalyzerPlugin extends ServerPlugin {
  AnalyzerPlugin({
    required super.resourceProvider,
  });

  final _configs = <String, ProjectConfiguration>{};

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'architecture_linter';

  @override
  String get version => '1.0.0-alpha.0';

  @override
  Future<void> afterNewContextCollection({
    required AnalysisContextCollection contextCollection,
  }) async {
    for (final context in contextCollection.contexts) {
      await setConfig(context);
    }

    return super.afterNewContextCollection(
      contextCollection: contextCollection,
    );
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    final analysisErrors = await analyzeFileForAnalysisErrors(
      analysisContext: analysisContext,
      path: path,
    );
    channel.sendNotification(
      AnalysisErrorsParams(
        path,
        analysisErrors.toList(),
      ).toNotification(),
    );
  }

  Future<Iterable<AnalysisError>> analyzeFileForAnalysisErrors({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    final isAnalyzed = analysisContext.contextRoot.isAnalyzed(path);
    final rootPath = analysisContext.contextRoot.root.path;
    final config = _configs[rootPath];

    if (config == null || !isAnalyzed) return [];

    final resolvedUnit =
        await analysisContext.currentSession.getResolvedUnit(path);

    if (resolvedUnit is ResolvedUnitResult) {
      final unitUri = resolvedUnit.path;

      final isUnitExcluded = config.isPathExcluded(unitUri);
      final isPathLayer = config.isPathLayer(unitUri);

      if (isUnitExcluded || !isPathLayer) return [];

      final currentFileAnalyzers = [FileAnalyzerImports()];
      final architectureAnalyzer =
          ArchitectureAnalyzer(currentFileAnalyzers: currentFileAnalyzers);
      return architectureAnalyzer.generateAnalysisErrors(resolvedUnit, config);
    }
    return [];
  }

  Future<void> setConfig(AnalysisContext analysisContext) async {
    final rootPath = analysisContext.contextRoot.root.path;
    final optionsFile = analysisContext.contextRoot.optionsFile;

    try {
      final config = await createConfig(analysisContext);
      if (config == null) return;
      _configs[rootPath] = config;

      /// If config is not null, then so is optionFile
      _validateConfig(config, optionsFile!.path);
    } catch (_) {
      channel.sendNotification(
        AnalysisErrorsParams(
          optionsFile?.path ?? '',
          [
            ConfigurationLints.configurationErrorLint(optionsFile?.path ?? ''),
          ],
        ).toNotification(),
      );
    }
  }

  void _validateConfig(ProjectConfiguration config, String path) {
    final result = <AnalysisError>[];

    if (config.layers.isEmpty) {
      result.add(
        ConfigurationLints.configurationNoLayersLint(path),
      );
    }

    if (config.bannedImports.isEmpty) {
      result.add(
        ConfigurationLints.configurationNoBannedImportsLint(path),
      );
    }

    if (result.isEmpty) return;

    channel.sendNotification(
      AnalysisErrorsParams(
        path,
        result,
      ).toNotification(),
    );
  }
}
