import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';

import '../../configuration/project_configuration.dart';
import '../file_analyzers/file_analyzer.dart';

class ArchitectureAnalyzer {
  static List<AnalysisError> runAnalysis(ResolvedUnitResult unit, ProjectConfiguration config) {
    return generateAnalysisErrors(unit, config).toList();
  }

  static final List<FileAnalyzer> currentFileAnalyzers = [
    FileAnalyzerImports(),
  ];

  static Iterable<AnalysisError> generateAnalysisErrors(ResolvedUnitResult unit, ProjectConfiguration config) sync* {
    for (final fileAnalyzer in currentFileAnalyzers) {
      final error = fileAnalyzer.analyzeFile(unit, config);
      if (error != null) yield error;
    }
  }
}
