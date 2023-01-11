import 'package:analyzer_plugin/protocol/protocol_common.dart';

extension AnalysisErrorExtension on AnalysisError {
  String get cliPrint => '${severity.name.toString().toUpperCase()}: $message';
}

extension IterableAnalysisErrorExtension on Iterable<AnalysisError> {
  String? getReportForFile(String filePath) {
    if (isEmpty) return null;
    final header = "\n$filePath:\n";

    String content = '';

    for (final analysisError in this) {
      content += '${analysisError.cliPrint}\n';
    }
    return '$header$content';
  }
}
