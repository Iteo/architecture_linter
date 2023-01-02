import 'file_analyzers/analyzer_imports/analyzer_imports_test.dart'
    as file_analyzer_imports;
import 'package:test/test.dart';
import 'file_type/file_type_tests.dart' as file_type;

void main() {
  group("AnalyzerImports tests", file_analyzer_imports.main);
  group("File type tests", file_type.main);
}
