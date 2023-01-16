import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/cli/models/cli_report.dart';
import 'package:architecture_linter/src/cli/models/cli_severity.dart';

extension AnalysisErrorExtension on AnalysisError {
  String get cliPrint => '${severity.name.toString().toUpperCase()}: $message';
}

extension IterableAnalysisErrorExtension on Iterable<AnalysisError> {
  CliReport? getReportForFile(String filePath) {
    if (isEmpty) return null;

    return CliReport(
      cliSeverity: cliSeverity,
      stringReport: getStringReport(filePath),
    );
  }

  String getStringReport(String filePath) {
    final header = "\n$filePath:\n";

    String content = '';

    for (final analysisError in this) {
      content += '${analysisError.cliPrint}\n';
    }
    return '$header$content';
  }

  CliSeverity get cliSeverity {
    CliSeverity cliSeverity = CliSeverity.info;

    for (final analysisError in this) {
      final severity = analysisError.severity;
      if (severity == AnalysisErrorSeverity.ERROR) {
        cliSeverity = CliSeverity.error;
        break;
      } else if (severity == AnalysisErrorSeverity.WARNING) {
        cliSeverity = CliSeverity.warning;
      } else {
        cliSeverity = CliSeverity.info;
      }
    }

    return cliSeverity;
  }
}
