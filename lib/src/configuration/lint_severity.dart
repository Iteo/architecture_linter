import 'package:analyzer_plugin/protocol/protocol_common.dart';

enum LintSeverity {
  info,
  warning,
  error,
}

extension LintSeverityExtension on LintSeverity {
  AnalysisErrorSeverity get analysisErrorSeverity {
    switch (this) {
      case LintSeverity.info:
        return AnalysisErrorSeverity.INFO;
      case LintSeverity.warning:
        return AnalysisErrorSeverity.WARNING;
      case LintSeverity.error:
        return AnalysisErrorSeverity.ERROR;
    }
  }
}

LintSeverity lintSeverityFromString(String? lintSeverity) {
  final safeString = lintSeverity?.toLowerCase().trim();

  switch (safeString) {
    case 'info':
      return LintSeverity.info;
    case 'warning':
      return LintSeverity.warning;
    case 'error':
      return LintSeverity.error;
    default:
      return LintSeverity.info;
  }
}
