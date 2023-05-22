import 'dart:isolate';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:architecture_linter/src/analyzer_plugin/analyzer_plugin.dart';

Future<void> start(Iterable<String> _, SendPort sendPort) async {
  final resourceProvider = PhysicalResourceProvider.INSTANCE;

  ServerPluginStarter(
    AnalyzerPlugin(
      resourceProvider: resourceProvider,
    ),
  ).start(sendPort);
}
