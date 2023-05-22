import 'package:test/test.dart';

import 'commands/base_command_test.dart' as base_command_test;
import 'models/cli_models_test.dart' as model_test;

void main() {
  group('Cli model tests', model_test.main);
  group('Base command tests', base_command_test.main);
}
