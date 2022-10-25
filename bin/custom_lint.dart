import 'dart:core';
import 'dart:isolate';
import 'dart:math';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/pair.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:architecture_linter/src/configuration_reader/configuration_reader.dart';
import 'package:architecture_linter/src/extensions/layer_extensions.dart';
import 'package:architecture_linter/src/extensions/string_extensions.dart';
import 'package:architecture_linter/src/project_name_reader/project_name_reader.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/extensions/custom_lint_extensions.dart';

void main(List<String> args, SendPort port) {
  startPlugin(port, ArchitectureLinter());
}

class ArchitectureLinter extends PluginBase {
  final configReader = ConfigurationReader();
  final projectNameReader = ProjectNameReader();

  String? rootProjectName;
  ProjectConfiguration? config;

  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final analysis = resolvedUnitResult;

    _resolveRootName(resolvedUnitResult);
    if (rootProjectName == null) return;

    final path = analysis.path;
    final packagePath = path.trimTo(rootProjectName!);

    if (!path.startsWith('$packagePath/lib')) return;

    _resolveProjectConfiguration(packagePath);
    if (config == null) return;

    // TODO Remove in future
    // For now leave for debugging
    yield _getLayersLint(analysis, config!);

    final layerRuleList = config!.bannedImports;
    final layerForFile = layerRuleList.getLayerForPath(path);
    if (layerForFile == null) return;

    final lints = _getImportLints(analysis, layerForFile);
    for (final lint in lints) {
      yield lint;
    }
  }

  void _resolveRootName(ResolvedUnitResult analysis) {
    if (rootProjectName != null) return;

    final components = analysis.libraryElement.entryPoint?.location?.components;
    final rootName = projectNameReader.readRootName(components);
    if (rootName.isNotEmpty) {
      rootProjectName = rootName;
    }
  }

  Future _resolveProjectConfiguration(String packagePath) async {
    if (config != null) return;
    config = await configReader.readConfiguration(packagePath, "architecture.yaml");
  }

  Lint _getLayersLint(ResolvedUnitResult analysis, ProjectConfiguration config) {
    final layers = config.layers.map((e) => e.displayName).join(", ");
    return Lint(
      code: 'architecture_configuration',
      message: 'Your project name is $rootProjectName, and layer names = $layers',
      location: analysis.lintLocationFromOffset(
        max(0, analysis.content.length - 1),
        length: analysis.content.length,
      ),
    );
  }

  List<Lint> _getImportLints(ResolvedUnitResult analysis, Pair<Layer, Set<Layer>> layerRule) {
    final importDirectives = analysis.unit.directives.whereType<ImportDirective>().toList();
    final List<Lint> lints = [];

    for (final import in importDirectives) {
      final bannedLayers = layerRule.last;

      if (import.containsBannedLayer(bannedLayers)) {
        lints.add(
          Lint(
            code: 'architecture_linter_banned_layer',
            //TODO change message to proper one
            message: 'Bro, dont.',
            location: analysis.lintLocationFromOffset(
              import.offset,
              length: import.length,
            ),
          ),
        );
      }
    }

    return lints;
  }
}