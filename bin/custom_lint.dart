import 'dart:core';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
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
    final components = analysis.libraryElement.entryPoint?.location?.components;

    final rootName = projectNameReader.readRootName(components);
    if (rootName.isNotEmpty) {
      rootProjectName = rootName;
    }

    if (rootProjectName == null) return;

    final path = analysis.path; // Absolute path for analyzed file
    final packagePath = path.trimTo(rootProjectName!); // Absolute path from start to `rootProjectName`
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

    final layerRuleList = config.bannedImports;
    final ruleForFile = layerRuleList.getRuleFromPath(path);

    if (ruleForFile != null) {
      final unit = analysis.unit;

      final importDirectives = unit.directives.whereType<ImportDirective>().toList();

      for (final element in importDirectives) {
        if (element.containsBannedLayer(layerRuleList[ruleForFile]!)) {
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

extension on Map<Layer, Set<Layer>> {
  Layer? getRuleFromPath(String currentPath) {
    try {
      for (final entry in entries) {
        if (entry.value.any((element) => currentPath.contains(element.displayName))) {
          return entry.key;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
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
