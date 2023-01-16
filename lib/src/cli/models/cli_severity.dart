import 'package:architecture_linter/src/cli/models/cli_config.dart';
import 'package:architecture_linter/src/cli/models/exit_codes.dart';

enum CliSeverity {
  error(2),
  warning(1),
  info(0),
  none(-1);

  const CliSeverity(this.level);

  factory CliSeverity.fromString(String severity) {
    final safeString = severity.trim().toLowerCase();

    return CliSeverity.values
        .firstWhere((element) => element.toString().contains(safeString));
  }

  final int level;

  CliSeverity compareAndReturnSeverity(CliSeverity other) {
    final otherIsHigherLevel = other.level > level;

    return otherIsHigherLevel ? other : this;
  }

  int getExitCode(CliConfig config) {
    if (level >= config.exitOnSeverityLevel.level &&
        config.exitOnSeverityLevel.level >= 0) {
      return ExitCodes.failure;
    }
    return ExitCodes.success;
  }
}
