import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:architecture_linter/src/layer_rule.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, ArchitectureLinter());
}

class ArchitectureLinter extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final currentPath = resolvedUnitResult.path;
    final layerRuleList = _getLayerRuleList();
    final ruleForFile = layerRuleList.getRuleFromPath(currentPath);

    if (ruleForFile != null) {
      final unit = resolvedUnitResult.unit;

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

List<LayerRule> _getLayerRuleList() {
  //TODO get rules from config file
  return [
    LayerRule(
      bannedLayers: ['domain', 'data'],
      layer: 'presentation',
    ),
  ];
}

extension on List<LayerRule> {
  LayerRule? getRuleFromPath(String currentPath) {
    try {
      return firstWhere((element) => currentPath.contains(element.layer));
    } catch (_) {
      return null;
    }
  }
}

extension on ImportDirective {
  bool containsBannedLayer(LayerRule rule) {
    for (final bannedLayer in rule.bannedLayers) {
      final containsLayer = toString().contains('$bannedLayer/');
      if (containsLayer) return true;
    }
    return false;
  }
}
