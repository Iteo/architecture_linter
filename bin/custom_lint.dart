import 'dart:core';
import 'dart:isolate';
import 'dart:math';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:architecture_linter/src/configuration_reader/configuration_reader.dart';
import 'package:architecture_linter/src/extensions/string_extensions.dart';
import 'package:architecture_linter/src/project_name_reader/project_name_reader.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:architecture_linter/src/configuration/layer.dart';

void main(List<String> args, SendPort port) {
  startPlugin(port, ArchitectureLinter());
}

class ArchitectureLinter extends PluginBase {
  final configReader = ConfigurationReader();
  final projectNameReader = ProjectNameReader();

  String? rootProjectName;

  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final analysis = resolvedUnitResult;

    _resolveRootName(resolvedUnitResult);
    if (rootProjectName == null) return;

    final path = analysis.path;
    final packagePath = path.trimTo(rootProjectName!);

    if (!path.startsWith('$packagePath/lib')) return;

    final config = await configReader.readConfiguration(packagePath, "architecture.yaml");

    // TODO Remove in future
    // For now leave for debugging
    yield _getLayersLint(analysis, config);

    final layerRuleList = config.bannedImports;
    final layerForFile = layerRuleList.getLayerForPath(path);
    if (layerForFile == null) return;

    final unit = analysis.unit;
    final importDirectives = unit.directives.whereType<ImportDirective>().toList();

    for (final element in importDirectives) {
      if (element.containsBannedLayer(layerRuleList[layerForFile]!)) {
        yield Lint(
          code: 'architecture_linter_banned_layer',
          //TODO change message to proper one
          message: 'Bro, dont.',
          location: resolvedUnitResult.lintLocationFromOffset(
            element.offset,
            length: element.length,
          ),
        );
      }
    }
  }

  void _resolveRootName(ResolvedUnitResult analysis) {
    final components = analysis.libraryElement.entryPoint?.location?.components;
    final rootName = projectNameReader.readRootName(components);
    if (rootName.isNotEmpty) {
      rootProjectName = rootName;
    }
  }

  Lint _getLayersLint(ResolvedUnitResult analysis, ProjectConfiguration config) {
    final layers = config.layers.map((e) => e.displayName).join(", ");
    return Lint(
        code: 'This message shows only for lib classes',
        message: 'Your project name is $rootProjectName, and layer names = $layers',
        location: analysis.lintLocationFromOffset(analysis.content.length - 1, length: analysis.content.length),
    );
  }
}

extension on Map<Layer, Set<Layer>> {
  Layer? getLayerForPath(String currentPath) {
    try {
      return keys.firstWhere((layer) => layer.pathRegex.hasMatch(currentPath));
    } catch (_) {
      return null;
    }
  }
}

extension on ImportDirective {
  bool containsBannedLayer(Set<Layer> rules) {
    for (final bannedLayer in rules) {
      final containsLayer = toString().contains('${bannedLayer.displayName}/');
      if (containsLayer) return true;
    }
    return false;
  }
}
