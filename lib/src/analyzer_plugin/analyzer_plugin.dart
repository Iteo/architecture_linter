import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:architecture_linter/src/analyzers/architecture_analyzer/architecture_analyzer.dart';

import '../configuration/configuration_lints.dart';
import '../configuration/project_configuration.dart';
import '../configuration_reader/configuration_reader.dart';

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
      _createConfig(context);
    }

    return super.afterNewContextCollection(contextCollection: contextCollection);
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    final isAnalyzed = analysisContext.contextRoot.isAnalyzed(path);
    final rootPath = analysisContext.contextRoot.root.path;
    final config = _configs[rootPath];

    if (config == null || !isAnalyzed) return;

    if (!config.layers.any((element) => path.contains(element.pathRegex))) return;

    final resolvedUnit = await analysisContext.currentSession.getResolvedUnit(path);

    if (resolvedUnit is ResolvedUnitResult) {
      channel.sendNotification(
        AnalysisErrorsParams(
          path,
          ArchitectureAnalyzer.generateAnalysisErrors(resolvedUnit, config).toList(),
        ).toNotification(),
      );
    }
  }

  void _createConfig(AnalysisContext analysisContext) {
    final rootPath = analysisContext.contextRoot.root.path;
    final optionsFile = analysisContext.contextRoot.optionsFile;

    if (optionsFile != null && optionsFile.exists) {
      try {
        final config = ConfigurationReader().readConfiguration(optionsFile);
        _configs[rootPath] = config;
        _validateConfig(config, optionsFile.path);
      } catch (_) {
        channel.sendNotification(
          AnalysisErrorsParams(
            optionsFile.path,
            [
              ConfigurationLints.configurationErrorLint(optionsFile.path),
            ],
          ).toNotification(),
        );
      }
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
