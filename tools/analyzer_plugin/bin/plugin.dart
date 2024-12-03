import 'dart:isolate';

import 'package:architecture_linter/src/analyzer_plugin/analyzer_starter.dart';

void main(List<String> args, SendPort port) {
  start(args, port);
}
