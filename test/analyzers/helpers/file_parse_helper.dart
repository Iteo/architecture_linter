import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as path;

const _pathToInputs = 'test/analyzers/mocks/';

class FileParseHelper {
  static Future<SomeResolvedUnitResult> parseTestFile(String pathFromMocks) =>
      resolveFile2(
        path: path.normalize(
          path.absolute(
            '$_pathToInputs$pathFromMocks',
          ),
        ),
      );
}
