import 'package:test/test.dart';
import 'configuration_read/configuration_read_test.dart' as configuration_read;
import 'exclude/exclude_test.dart' as exclude;
import 'severity/severity_test.dart' as severity;

void main() {
  group("Project configuration read tests", configuration_read.main);
  group("Exclude tests", exclude.main);
  group("Severity tests", severity.main);
}
