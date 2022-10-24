import 'dart:async';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:architecture_linter/configuration_reader/configuration_reader.dart';
import 'package:architecture_linter/extensions/string_extensions.dart';
import 'package:architecture_linter/project_name_reader/project_name_reader.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

void main(List<String> args, SendPort port) {
  startPlugin(port, _LintPlugin());
}

// TODO Handle tests (/test)
class _LintPlugin extends PluginBase {
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
  }
}
