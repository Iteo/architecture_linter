import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:architecture_linter/src/analyzer_plugin/analyzer_plugin.dart';
import 'package:architecture_linter/src/cli/commands/base_command.dart';
import 'package:architecture_linter/src/cli/extensions/analysis_error_extensions.dart';
import 'package:architecture_linter/src/cli/printer/printer.dart';
import 'package:path/path.dart';

class AnalyzeCommand extends BaseCommand {
  @override
  String get description => "Analyze project for ";

  @override
  String get name => "analyze";

  final printer = Printer(stdout);

  @override
  Future<void> runCommand() async {
    final folders = argResults.rest;

    final includedPaths = folders.map((path) => normalize(join(rootFolderPath, path))).toList();
    final contextCollection = AnalysisContextCollection(includedPaths: includedPaths);
    final resourceProvider = PhysicalResourceProvider.INSTANCE;

    final plugin = AnalyzerPlugin(resourceProvider: resourceProvider);
    await plugin.afterNewContextCollection(contextCollection: contextCollection);
    plugin.channel.listen((request) {

    });

    for (final context in contextCollection.contexts) {
      final analysisErrorList = await plugin.analyzeFileForAnalysisErrors(
        analysisContext: context,
        path: context.contextRoot.workspace.root,
      );

      final fileReport = analysisErrorList.getReportForFile(current);
      printer.write(fileReport);
    }
  }
}
