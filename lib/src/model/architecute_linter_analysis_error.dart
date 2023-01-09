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

  factory ArchitectureLinterAnalysisError.message(
    LintSeverity lintSeverity,
    Location location,
    String message,
    String lintCode, {
    String? correction,
    bool showCode = true,
  }) {
    return ArchitectureLinterAnalysisError(
      lintSeverity.analysisErrorSeverity,
      AnalysisErrorType.LINT,
      location,
      '${showCode ? '[$lintCode]\n' : ''}$message',
      lintCode,
      correction: correction,
    );
  }
}
