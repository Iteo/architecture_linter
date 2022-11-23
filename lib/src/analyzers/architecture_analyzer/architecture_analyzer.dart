import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';

import '../../configuration/project_configuration.dart';
import '../file_analyzers/file_analyzer.dart';

class ArchitectureAnalyzer {
  static List<AnalysisError> runAnalysis(
    ResolvedUnitResult unit,
    ProjectConfiguration config,
  ) =>
      generateAnalysisErrors(
        unit,
        config,
      ).toList();

  static final List<FileAnalyzer> currentFileAnalyzers = [
    FileAnalyzerImports(),
  ];

  static Iterable<AnalysisError> generateAnalysisErrors(
    ResolvedUnitResult unit,
    ProjectConfiguration config,
  ) sync* {
    for (final fileAnalyzer in currentFileAnalyzers) {
      final errors = fileAnalyzer.analyzeFile(
        unit,
        config,
      );
      if (errors.isNotEmpty) {
        for (final error in errors) {
          yield error;
        }
      }
    }
  }
}
