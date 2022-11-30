import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';

abstract class FileAnalyzer {
  String get lintCode;

  Iterable<AnalysisError> analyzeFile(
    ResolvedUnitResult unitResult,
    ProjectConfiguration config,
  );
}
