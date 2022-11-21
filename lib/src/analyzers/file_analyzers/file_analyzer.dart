import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

import '../../configuration/project_configuration.dart';

abstract class FileAnalyzer {
  AnalysisError? analyzeFile(
      ResolvedUnitResult unitResult, ProjectConfiguration config);
}
