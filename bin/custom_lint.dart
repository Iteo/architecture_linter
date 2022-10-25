import 'dart:core';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
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

  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final analysis = resolvedUnitResult;
    final components = analysis.libraryElement.entryPoint?.location?.components;
    final rootProjectName = projectNameReader.readRootName(components);

    if (rootProjectName.isEmpty) return;

    final path = analysis.path; // Absolute path for analyzed file
    final packagePath = path.trimTo(rootProjectName); // Absolute path from start to `rootProjectName`
    final libraryPath = "$packagePath/lib";

    if (!path.startsWith(libraryPath)) {
      return;
    }

    final config = await configReader.readConfiguration(packagePath, "architecture.yaml");
    final layers = config.layers.map((e) => e.displayName).join(", ");

    yield Lint(
      code: 'This message shows only for lib classes',
      message: 'Your project name is $rootProjectName, and layer names = $layers',
      location: analysis.lintLocationFromOffset(0, length: analysis.content.length),
    );

    final layerRuleList = config.layers;
    final ruleForFile = layerRuleList.getRuleFromPath(currentPath);

    if (ruleForFile != null) {
      final unit = analysis.unit;

      final importDirectives = unit.directives.whereType<ImportDirective>().toList();

      for (final element in importDirectives) {
        if (element.containsBannedLayer(ruleForFile)) {
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
  }
}

extension on List<Layer> {
  Layer? getRuleFromPath(String currentPath) {
    try {
      return firstWhere((element) => currentPath.contains(element.layer));
    } catch (_) {
      return null;
    }
  }
}

extension on ImportDirective {
  bool containsBannedLayer(Layer rule) {
    for (final bannedLayer in rule.bannedLayers) {
      final containsLayer = toString().contains('$bannedLayer/');
      if (containsLayer) return true;
    }
    return false;
  }
}
