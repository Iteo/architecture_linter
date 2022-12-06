import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';

extension ImportLints on ResolvedUnitResult {
  AnalysisError getBannedLayerLint(
    ImportDirective import,
    String layerName,
    String lintCode,
    LintSeverity lintSeverity,
  ) {
    final charLocation = lineInfo.getLocation(import.offset);

    return AnalysisError(
      lintSeverity.analysisErrorSeverity,
      AnalysisErrorType.LINT,
      Location(
        path,
        import.offset,
        import.length,
        charLocation.lineNumber,
        charLocation.columnNumber,
      ),
      'Layer $layerName '
      'cannot have ${import.uri}',
      lintCode,
    );
  }
}
