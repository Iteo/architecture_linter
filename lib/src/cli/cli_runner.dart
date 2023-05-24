import 'dart:io';

import 'package:architecture_linter/src/cli/commands/analyze_command.dart';
import 'package:architecture_linter/src/cli/models/exit_codes.dart';
import 'package:architecture_linter/src/cli/printer/printer.dart';
import 'package:args/command_runner.dart';

class CliRunner extends CommandRunner<void> {
  CliRunner() : super('analyzer', 'Analyze your project architecture') {
    addCommand(AnalyzeCommand(printer));
  }

  final Printer printer = Printer(stdout);

  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      printer
        ..write(e.message)
        ..write(e.usage);

      exit(ExitCodes.error);
    } catch (e) {
      printer.write('Analyze has exited unexpectedly: "$e"');

      exit(ExitCodes.unknownError);
    }
    exit(ExitCodes.success);
  }
}
