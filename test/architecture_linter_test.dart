import 'package:test/test.dart';
import 'analyzers/analyzers_test.dart' as analyzers_test;
import 'project_name_reader/project_name_reader_test.dart'
    as project_name_reader_test;

void main() {
  group("Analyzers tests", analyzers_test.main);
  group("Project name reader test", project_name_reader_test.main);
}
