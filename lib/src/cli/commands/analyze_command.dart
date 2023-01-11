import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:architecture_linter/src/analyzers/architecture_analyzer/architecture_analyzer.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';
import 'package:architecture_linter/src/cli/commands/base_command.dart';
import 'package:architecture_linter/src/cli/extensions/analysis_error_extensions.dart';
import 'package:architecture_linter/src/cli/printer/printer.dart';
import 'package:architecture_linter/src/utils/analyzer_utils.dart';
import 'package:path/path.dart';

class AnalyzeCommand extends BaseCommand {
  AnalyzeCommand() {
    addCommonFlags();
  }

  @override
  String get description => "Analyze project for ";

  @override
  String get name => "analyze";

  final printer = Printer(stdout);

  @override
  Future<void> runCommand() async {
    final folders = argResults.rest;

    final includedPaths = folders.map((path) => normalize(join(rootFolderPath, path))).toList();
    final resourceProvider = _prepareAnalysisOptions(includedPaths);

    final contextCollection = AnalysisContextCollection(
      includedPaths: includedPaths,
      resourceProvider: resourceProvider,
    );

    final analyzer = ArchitectureAnalyzer(
      currentFileAnalyzers: [
        FileAnalyzerImports(isCli: true),
      ],
    );

    for (final context in contextCollection.contexts) {
      final filePaths = getFilePaths(
        folders,
        context,
        context.contextRoot.root.path,
        [],
      );

      final analyzedFiles = filePaths.intersection(context.contextRoot.analyzedFiles().toSet());

      final config = await createConfig(context);

      for (final filePath in analyzedFiles) {
        final unit = await context.currentSession.getResolvedUnit(filePath);

        if (unit is ResolvedUnitResult) {
          if (config != null) {
            final errors = analyzer.runAnalysis(unit, config);
            final fileReport = errors.getReportForFile(unit.path);
            if (fileReport != null) {
              printer.write(fileReport);
            }
          } else {
            usageException("Configuration not found");
          }
        }
      }
    }
  }
}

ResourceProvider _prepareAnalysisOptions(List<String> includedPaths) {
  final resourceProvider = OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);

  final contextLocator = ContextLocator(resourceProvider: resourceProvider);
  final roots = contextLocator.locateRoots(includedPaths: includedPaths);

  for (final root in roots) {
    final path = root.optionsFile?.path;
    if (path != null) {
      resourceProvider.setOverlay(
        path,
        content: '',
        modificationStamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  return resourceProvider;
}
