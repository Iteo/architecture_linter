import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:architecture_linter/src/cli/commands/analyze_command.dart';
import 'package:args/command_runner.dart';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class CliRunner extends CommandRunner<void> {
  CliRunner() : super("analyzer", "Analyze your project architecture") {
    addCommand(AnalyzeCommand());
  }

  @override
  Future<void> run(Iterable<String> args) async {

    try {
      await super.run(args);
    } on UsageException catch (e) {
    /*  _logger
        ..info(e.message)
        ..info(e.usage);*/

      exit(64);
    } catch (e) {
    //  _logger.error('CLI has exited unexpectedly: "$e"');

      exit(1);
    }
    exit(0);
  }
}
