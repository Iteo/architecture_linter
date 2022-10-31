import 'dart:core';
import 'dart:isolate';
import 'dart:math';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/pair.dart';
import 'package:architecture_linter/src/configuration/configuration_remark.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:architecture_linter/src/configuration_reader/configuration_reader.dart';
import 'package:architecture_linter/src/extensions/layer_extensions.dart';
import 'package:architecture_linter/src/extensions/string_extensions.dart';
import 'package:architecture_linter/src/linter_configuration/architecture_linter_config.dart';
import 'package:architecture_linter/src/linter_configuration/linter_configuration.dart';
import 'package:architecture_linter/src/project_name_reader/project_name_reader.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/extensions/custom_lint_extensions.dart';

void main(List<String> args, SendPort port) {
  startPlugin(port, ArchitectureLinter());
}

class ArchitectureLinter extends PluginBase {
  final fileConfig = ArchitectureLinterConfiguration.fileConfig;
  final configReader = ConfigurationReader();
  final projectNameReader = ProjectNameReader();

  String? rootProjectName;
  ProjectConfiguration? projectConfig;

  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final analysis = resolvedUnitResult;

    _resolveRootName(resolvedUnitResult);
    if (rootProjectName == null) return;

    final path = analysis.path;
    final packagePath = path.trimTo(rootProjectName!);

    // Till now we ignore all errors as linting is done for ALL files in project.
    // We want to check only files in scope of the main package
    if (!path.startsWith('$packagePath/lib')) return;

    _resolveProjectConfiguration(
      packagePath,
      fileConfig,
    );

    final configurationRemark = _getConfigurationRemark(analysis);
    if (isRemarkValidToShow(configurationRemark)) {
      yield configurationRemark!.lint;
    }

    if (configurationRemark?.severity == LintSeverity.error) {
      // For serious problems don't proceed with lint checking
      return;
    }

    final layerRuleList = projectConfig!.bannedImports;
    final layerForFile = layerRuleList.getLayerForPath(path);
    if (layerForFile == null) return;

    for (final lint in _getImportLints(analysis, layerForFile)) {
      yield lint;
    }
  }

  void _resolveRootName(ResolvedUnitResult analysis) {
    try {
      if (rootProjectName != null) return;

      final components =
          analysis.libraryElement.entryPoint?.location?.components;
      final rootName = projectNameReader.readRootName(components);
      if (rootName.isNotEmpty) {
        rootProjectName = rootName;
      }
    } catch (e) {
      // The analysis may find problems for unwanted files
      // so we ignore any errors here
      return;
    }
  }

  Future _resolveProjectConfiguration(
    String packagePath,
    ArchitectureFileConfiguration fileConfig,
  ) async {
    try {
      if (projectConfig != null) return;

      projectConfig = await configReader.readConfiguration(
        packagePath,
        fileConfig.filePath,
      );
    } catch (e) {
      if (fileConfig.allowsError) {
        // TODO Finish
      }
    }
  }

  Iterable<Lint> _getImportLints(
    ResolvedUnitResult analysis,
    Pair<Layer, Set<Layer>> layerRule,
  ) sync* {
    final directives = analysis.unit.directives;
    final importDirectives = directives.whereType<ImportDirective>().toList();

    for (final import in importDirectives) {
      final currentLayer = layerRule.first;
      final bannedLayers = layerRule.last;

      if (import.containsBannedLayer(bannedLayers)) {
        yield Lint(
          severity: LintSeverity.warning,
          code: 'architecture_linter_banned_layer',
          message: 'Layer ${currentLayer.displayName} '
              'cannot have ${import.uri}',
          location: analysis.lintLocationFromOffset(
            import.offset,
            length: import.length,
          ),
        );
      }
    }
  }

  ConfigurationRemark? _getConfigurationRemark(ResolvedUnitResult analysis) {
    if (projectConfig == null) {
      return ConfigurationRemark(
        Lint(
          code: 'architecture_linter_configuration_not_found',
          message: 'There is no ${fileConfig.filePath} in project to read',
          location: analysis.lintLocationFromOffset(
            max(0, analysis.content.length - 1),
            length: analysis.content.length,
          ),
        ),
        LintSeverity.error,
      );
    }

    if (projectConfig!.layers.isEmpty) {
      return ConfigurationRemark(
        Lint(
          code: 'architecture_linter_layers_not_found',
          message: 'Configuration file does not have layers declared',
          correction: "Make sure that the architecture config file contains"
              " section `layers:` with at least one entry. Check README "
              "for more information how to declare proper config. structure.",
          location: analysis.lintLocationFromOffset(
            max(0, analysis.content.length - 1),
            length: analysis.content.length,
          ),
        ),
        LintSeverity.warning,
      );
    }

    return null;
  }

  bool isRemarkValidToShow(ConfigurationRemark? remark) =>
      remark != null && fileConfig.checkSeverity.contains(remark.severity);
}
