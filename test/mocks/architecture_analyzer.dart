import 'package:architecture_linter/src/analyzers/architecture_analyzer/architecture_analyzer.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/analyzer_imports/file_analyzer_imports.dart';

class ArchitectureAnalyzerMocks {
  const ArchitectureAnalyzerMocks._();

  static final baseArchitectureAnalyzer =
      ArchitectureAnalyzer(currentFileAnalyzers: [FileAnalyzerImports()]);
}
