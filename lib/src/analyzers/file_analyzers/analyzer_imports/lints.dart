import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

extension ImportLints on ResolvedUnitResult {
  AnalysisError getBannedLayerLint(ImportDirective import, String layerName) {
    final charLocation = lineInfo.getLocation(import.offset);

    return AnalysisError(
      AnalysisErrorSeverity.INFO,
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
      'architecture_linter_banned_layer',
    );
  }
}
