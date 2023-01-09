import 'dart:io';

class Printer {
  Printer(this.output);

  final IOSink output;

  void write(String message) {
    output.write(message);
  }
}
