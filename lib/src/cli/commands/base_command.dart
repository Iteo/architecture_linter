//ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:architecture_linter/src/cli/exceptions/invalid_argument_exception.dart';
import 'package:architecture_linter/src/cli/models/exit_codes.dart';
import 'package:architecture_linter/src/cli/models/flag_names.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart';

abstract class BaseCommand extends Command<void> {
  @override
  ArgResults get argResults {
    final results = super.argResults;
    if (results == null) {
      throw StateError('Unexpected empty args parse result');
    }

    return results;
  }

  @override
  Future<void> run() => _validateThenRun();

  Future<void> runCommand();

  String get rootFolderPath => argResults[FlagNames.rootFolder] as String;

  Future<void> _validateThenRun() async {
    try {
      validateRootFolderExist();
      validateSdkPath();
      validateTargetDirectoriesOrFiles();
    } on InvalidArgumentException catch (e) {
      throw usageException(e.message);
    }
    return runCommand();
  }

  void validateRootFolderExist() {
    if (!Directory(rootFolderPath).existsSync()) {
      final exceptionMessage =
          'Root folder $rootFolderPath does not exist or not a directory.';

      throw InvalidArgumentException(exceptionMessage);
    }
  }

  void validateSdkPath() {
    final sdkPath = argResults[FlagNames.sdkPath] as String?;
    if (sdkPath != null && !Directory(sdkPath).existsSync()) {
      final exceptionMessage =
          'Dart SDK path $sdkPath does not exist or not a directory.';

      throw InvalidArgumentException(exceptionMessage);
    }
  }

  void validateTargetDirectoriesOrFiles() {
    if (argResults.rest.isEmpty) {
      const exceptionMessage =
          'Invalid number of directories or files. At least one must be specified.';

      throw InvalidArgumentException(exceptionMessage);
    }

    for (final relativePath in argResults.rest) {
      final absolutePath = join(rootFolderPath, relativePath);
      if (!Directory(absolutePath).existsSync() &&
          !File(absolutePath).existsSync()) {
        final exceptionMessage =
            "$absolutePath doesn't exist or isn't a directory or a file.";

        throw InvalidArgumentException(exceptionMessage);
      }
    }
  }

  void addCommonFlags() {
    usesRootFolderOption();
    usesSdkPathOption();
    usesExitOnSeverityLevel();
  }

  void usesRootFolderOption() {
    argParser
      ..addSeparator('')
      ..addOption(
        FlagNames.rootFolder,
        help: 'Root folder.',
        valueHelp: './',
        defaultsTo: Directory.current.path,
      );
  }

  void usesExitOnSeverityLevel() {
    argParser
      ..addSeparator('')
      ..addOption(
        FlagNames.setExitOnSeverityLevel,
        allowed: ['error', 'warning', 'info', 'none'],
        valueHelp: 'warning',
        help:
            'Set exit code ${ExitCodes.failure} if severities same or higher level than selected are detected.',
      );
  }

  void usesSdkPathOption() {
    argParser.addOption(
      FlagNames.sdkPath,
      help:
          'Dart SDK directory path. Should be provided only when you run the application as compiled executable(https://dart.dev/tools/dart-compile#exe) and automatic Dart SDK path detection fails.',
      valueHelp: 'directory-path',
    );
  }
}
