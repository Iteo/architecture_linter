import 'package:architecture_linter/src/cli/models/cli_severity.dart';
import 'package:architecture_linter/src/cli/models/flag_names.dart';
import 'package:args/args.dart';

class CliConfig {
  const CliConfig(this.exitOnSeverityLevel);

  factory CliConfig.defaultConfig() => const CliConfig(CliSeverity.warning);

  factory CliConfig.fromArgsMap(ArgResults argResults) {
    try {
      final exitOnSeverityLevelString =
          argResults[FlagNames.setExitOnSeverityLevel] as String;
      final exitOnSeverityLevel =
          CliSeverity.fromString(exitOnSeverityLevelString);
      return CliConfig(exitOnSeverityLevel);
    } catch (_) {
      return CliConfig.defaultConfig();
    }
  }

  final CliSeverity exitOnSeverityLevel;
}
