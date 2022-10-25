import 'regex.dart';

class Layer {
  final String displayName;
  final RegExp pathRegex;

  Layer(
    this.displayName,
    this.pathRegex,
  );

  factory Layer.fromMap(Map<dynamic, dynamic> map) {
    return Layer(
      map['name'],
      Regex.fromMap(map['pathRegex']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Layer &&
        other.displayName == displayName &&
        other.pathRegex == pathRegex;
  }

  @override
  int get hashCode => displayName.hashCode ^ pathRegex.hashCode;
}
