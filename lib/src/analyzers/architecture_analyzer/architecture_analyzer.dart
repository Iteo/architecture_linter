import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:architecture_linter/src/analyzers/file_analyzers/file_analyzer.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';

class ArchitectureAnalyzer {
  ArchitectureAnalyzer({required this.currentFileAnalyzers});

  List<AnalysisError> runAnalysis(
    ResolvedUnitResult unit,
    ProjectConfiguration config,
  ) =>
      generateAnalysisErrors(
        unit,
        config,
      ).toList();

  final List<FileAnalyzer> currentFileAnalyzers;

  Iterable<AnalysisError> generateAnalysisErrors(
    ResolvedUnitResult unit,
    ProjectConfiguration config,
  ) sync* {
    final ignoredCodesForFile = _getIgnoredCodesForFile(unit.content);

    for (final fileAnalyzer in currentFileAnalyzers) {
      if (ignoredCodesForFile.contains(fileAnalyzer.lintCode)) return;

      final errors = fileAnalyzer.analyzeFile(
        unit,
        config,
      );

      if (errors.isNotEmpty) {
        for (final error in errors) {
          final isIgnored = _isIgnored(
            lint: error,
            lineInfo: unit.lineInfo,
            source: unit.content,
          );

          if (!isIgnored) yield error;
        }
      }
    }
  }

  final _ignoreForFileRegex = RegExp(
    r'//\s*ignore_for_file\s*:(.+)$',
    multiLine: true,
  );
  final _ignoreRegex = RegExp(
    r'//\s*ignore\s*:(.+)$',
    multiLine: true,
  );

  Iterable<String> _getIgnoredCodesForFile(String source) {
    return _ignoreForFileRegex
        .allMatches(source)
        .map((e) => e.group(1)!)
        .expand((e) => e.split(','))
        .map((e) => e.trim());
  }

  bool _isIgnored({
    required AnalysisError lint,
    required LineInfo lineInfo,
    required String source,
  }) {
    final line = lint.location.startLine - 1;

    if (line == 0) return false;

    final previousLine = source.substring(
      lineInfo.getOffsetOfLine(line - 1),
      lint.location.offset - 1,
    );

    final codeContent = _ignoreRegex.firstMatch(previousLine)?.group(1);
    if (codeContent == null) return false;

    final codes = codeContent.split(',').map((e) => e.trim());

    return codes.contains(lint.code);
  }
}
