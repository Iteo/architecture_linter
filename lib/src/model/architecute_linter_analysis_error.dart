import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';

class ArchitectureLinterAnalysisError extends AnalysisError {
  ArchitectureLinterAnalysisError(
    super.severity,
    super.type,
    super.location,
    super.message,
    super.code, {
    super.correction,
  });

  factory ArchitectureLinterAnalysisError.messageWithCode(
    LintSeverity lintSeverity,
    Location location,
    String message,
    String lintCode, {
    String? correction,
  }) {
    return ArchitectureLinterAnalysisError(
      lintSeverity.analysisErrorSeverity,
      AnalysisErrorType.LINT,
      location,
      '[$lintCode]\n$message',
      lintCode,
      correction: correction,
    );
  }
}
