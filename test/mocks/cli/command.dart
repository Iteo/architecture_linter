import 'dart:io';

import 'package:architecture_linter/src/cli/commands/base_command.dart';
import 'package:args/args.dart';
import 'package:mocktail/mocktail.dart';

class DirectoryMock extends Mock implements Directory {}

class ArgResultsMock extends Mock implements ArgResults {}

class TestCommand extends BaseCommand {
  final ArgResults _results;

  TestCommand(this._results);

  @override
  ArgResults get argResults => _results;

  @override
  String get name => 'test';

  @override
  String get description => 'empty';

  @override
  Future<void> runCommand() {
    throw UnimplementedError();
  }
}
