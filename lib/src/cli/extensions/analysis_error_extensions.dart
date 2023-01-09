import 'package:analyzer_plugin/protocol/protocol_common.dart';

extension AnalysisErrorExtension on AnalysisError {
  // final messageWithoutCode = message.substring(0, message.length - code)
  String get cliPrint => '${severity.toString().toUpperCase()} $message';
}

extension IterableAnalysisErrorExtension on Iterable<AnalysisError> {
  String getReportForFile(String filePath) {
    final header = "$filePath:\n";
    final content = map((e) => '${e.cliPrint}\n').toString();
    return '$header$content';
  }
}
