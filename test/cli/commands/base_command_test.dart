import 'dart:io';

import 'package:architecture_linter/src/cli/exceptions/invalid_argument_exception.dart';
import 'package:architecture_linter/src/cli/models/flag_names.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../mocks/cli/command.dart';

void main() {
  final result = ArgResultsMock();
  final command = TestCommand(result);

  test('Tests if invalid number of directories exception is thrown', () {
    when(() => result.rest).thenReturn([]);

    expect(
      command.validateTargetDirectoriesOrFiles,
      throwsA(
        predicate(
          (e) =>
              e is InvalidArgumentException &&
              e.message ==
                  'Invalid number of directories or files. At least one must be specified.',
        ),
      ),
    );
  });

  test("Tests if exception is thrown when path doesn't exist", () {
    when(() => result.rest).thenReturn(['bil']);
    when(() => result[FlagNames.rootFolder] as String).thenReturn('./');

    expect(
      command.validateTargetDirectoriesOrFiles,
      throwsA(
        predicate(
          (e) =>
              e is InvalidArgumentException &&
              e.message ==
                  "./bil doesn't exist or isn't a directory or a file.",
        ),
      ),
    );
  });

  test(
    "Test if exception is thrown when sdk-path is specified but doesn't exists",
    () {
      when(() => result[FlagNames.sdkPath] as String).thenReturn('SDK_PATH');
      IOOverrides.runZoned(
        () {
          expect(
            command.validateSdkPath,
            throwsA(
              predicate(
                (e) =>
                    e is InvalidArgumentException &&
                    e.message ==
                        'Dart SDK path SDK_PATH does not exist or not a directory.',
              ),
            ),
          );
        },
        createDirectory: (path) {
          final directory = DirectoryMock();
          when(directory.existsSync).thenReturn(false);

          return directory;
        },
      );
    },
  );
}
