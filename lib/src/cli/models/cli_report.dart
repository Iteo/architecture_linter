import 'package:architecture_linter/src/cli/models/cli_severity.dart';

class CliReport {
  const CliReport({
    required this.cliSeverity,
    required this.stringReport,
  });

  final CliSeverity cliSeverity;
  final String stringReport;
}
