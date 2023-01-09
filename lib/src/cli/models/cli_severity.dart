import 'package:architecture_linter/src/cli/models/cli_config.dart';

enum CliSeverity {
  error,
  warning,
  info,
  none;

  factory CliSeverity.fromString(String severity) {
    final safeString = severity.trim().toLowerCase();

    return CliSeverity.values
        .firstWhere((element) => element.toString().contains(safeString));
  }
}

extension CliSeverityExtension on CliSeverity {
  CliSeverity compareAndReturnSeverity(CliSeverity other) {
    final otherIsHigherLevel = other.level > level;

    return otherIsHigherLevel ? other : this;
  }

  int get level {
    switch (this) {
      case CliSeverity.error:
        return 2;
      case CliSeverity.warning:
        return 1;
      case CliSeverity.info:
        return 0;
      case CliSeverity.none:
        return -1;
    }
  }

  int getExitCode(CliConfig config) {
    if (level >= config.exitOnSeverityLevel.level &&
        config.exitOnSeverityLevel.level >= 0) {
      return 2;
    }
    return 0;
  }
}
