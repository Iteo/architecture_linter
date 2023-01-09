import 'dart:io';

class Printer {
  Printer(this._output);

  final IOSink _output;

  void write(String message) => _output.write(message);
}
