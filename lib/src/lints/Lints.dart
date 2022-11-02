import 'dart:math';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

extension Lints on ResolvedUnitResult {
  Lint getBannedLayerLint(ImportDirective import, String layerName) => Lint(
        severity: LintSeverity.warning,
        code: 'architecture_linter_banned_layer',
        message: 'Layer $layerName '
            'cannot have ${import.uri}',
        location: lintLocationFromOffset(
          import.offset,
          length: import.length,
        ),
      );

  Lint getConfigurationNotFoundLint(String filePath) => Lint(
        severity: LintSeverity.error,
        code: 'architecture_linter_configuration_not_found',
        message: 'There is no $filePath in project to read',
        location: lintLocationFromOffset(
          max(0, content.length - 1),
          length: content.length,
        ),
      );

  Lint getLayersNotFoundLint() => Lint(
        severity: LintSeverity.warning,
        code: 'architecture_linter_layers_not_found',
        message: 'Configuration file does not have layers declared',
        correction: "Make sure that the architecture config file contains"
            " section `layers:` with at least one entry. Check README "
            "for more information how to declare proper config. structure.",
        location: lintLocationFromOffset(
          max(0, content.length - 1),
          length: content.length,
        ),
      );

  Lint getBannedImportsNotFoundLint() => Lint(
        severity: LintSeverity.info,
        code: 'architecture_linter_banned_imports_not_found',
        message: 'Configuration file does not have banned imports declared',
        correction: "Make sure that the architecture config file contains"
            " section `bannedImports:` with at least one entry. Check README "
            "for more information how to declare proper config. structure.",
        location: lintLocationFromOffset(
          max(0, content.length - 1),
          length: content.length,
        ),
      );
}
