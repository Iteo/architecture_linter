//ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:architecture_linter/src/analyzers/architecture_analyzer/architecture_analyzer.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';
import 'package:architecture_linter/src/cli/commands/base_command.dart';
import 'package:architecture_linter/src/extensions/analysis_error_extensions.dart';
import 'package:architecture_linter/src/cli/models/cli_config.dart';
import 'package:architecture_linter/src/cli/models/cli_severity.dart';
import 'package:architecture_linter/src/cli/printer/printer.dart';
import 'package:architecture_linter/src/utils/analyzer_utils.dart';
import 'package:path/path.dart';

class AnalyzeCommand extends BaseCommand {
  AnalyzeCommand(this.printer) {
    addCommonFlags();
  }

  final Printer printer;

  @override
  String get description => "Analyze project for architecture inconsistencies";

  @override
  String get name => "analyze";

  @override
  Future<void> runCommand() async {
    final cliConfig = CliConfig.fromArgsMap(argResults);

    final folders = argResults.rest;

    final includedPaths =
        folders.map((path) => normalize(join(rootFolderPath, path))).toList();
    final resourceProvider = prepareAnalysisOptions(includedPaths);

    final contextCollection = AnalysisContextCollection(
      includedPaths: includedPaths,
      resourceProvider: resourceProvider,
    );

    final analyzer = ArchitectureAnalyzer(
      currentFileAnalyzers: [
        FileAnalyzerImports(isCli: true),
      ],
    );

    CliSeverity severity = CliSeverity.none;
    int lintCount = 0;

    for (final context in contextCollection.contexts) {
      final config = await createConfig(context);
      if (config == null) {
        usageException("Configuration not found");
      }

      final filePaths = getFilePaths(
        folders,
        context,
        context.contextRoot.root.path,
        config.excludes,
      );

      final analyzedFiles =
          filePaths.intersection(context.contextRoot.analyzedFiles().toSet());

      for (final filePath in analyzedFiles) {
        final unit = await context.currentSession.getResolvedUnit(filePath);

        if (unit is ResolvedUnitResult) {
          final errors = analyzer.runAnalysis(unit, config);
          final fileReport = errors.getReportForFile(unit.path);
          lintCount += errors.length;
          if (fileReport != null) {
            severity =
                severity.compareAndReturnSeverity(fileReport.cliSeverity);
            printer.write(fileReport.stringReport);
          }
        }
      }
    }
    final exitCode = severity.getExitCode(cliConfig);

    final exitMessage = _getExitMessage(lintCount);
    printer.write(exitMessage);
    exit(exitCode);
  }

  _getExitMessage(int lintCount) {
    if (lintCount == 0) {
      return '\nAnalyzer has ended with 0 inconsistencies';
    }

    return '\nAnalyzer has found $lintCount architecture inconsistencies.';
  }
}
