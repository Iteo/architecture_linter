import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';
import 'package:architecture_linter/src/model/architecute_linter_analysis_error.dart';

extension ImportLints on ResolvedUnitResult {
  AnalysisError getBannedLayerLint(
    ImportDirective import,
    String layerName,
    String lintCode,
    LintSeverity lintSeverity, {
    bool showCode = true,
  }) {
    final charLocation = lineInfo.getLocation(import.offset);

    return ArchitectureLinterAnalysisError.message(
      lintSeverity,
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
      showCode: showCode,
    );
  }
}
