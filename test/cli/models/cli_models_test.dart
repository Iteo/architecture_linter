import 'package:architecture_linter/src/cli/models/cli_severity.dart';
import 'package:test/test.dart';

import '../../mocks/cli/cli_config.dart';

void main() {
  test(
    'Tests CliSeverity comparison',
    () {
      final comparison =
          CliSeverity.info.compareAndReturnSeverity(CliSeverity.error);

      expect(comparison, CliSeverity.error);
    },
  );

  test(
    "Tests if whether the correct exit code is being returned",
    () {
      final config = CliConfigMocks.severityNoneCliConfig;
      final severity = CliSeverity.error;
      final exitCode = severity.getExitCode(config);

      expect(exitCode, 0);
    },
  );

  test("Tests CliSeverity fromString factory", () {
    final cliSeverityString = " Warning";

    final severity = CliSeverity.fromString(cliSeverityString);

    expect(severity, CliSeverity.warning);
  });
}
