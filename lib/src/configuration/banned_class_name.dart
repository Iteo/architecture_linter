import '../configuration/layer.dart';
import '../configuration/regex.dart';

class BannedClassName {
  final Layer layer;
  final List<RegExp> bannedClassNames;

  BannedClassName(
    this.layer,
    this.bannedClassNames,
  );

  factory BannedClassName.fromMap(Map<dynamic, dynamic> map) {
    return BannedClassName(
      Layer.fromMap(map['layer']),
      List<RegExp>.from(map['banned']?.map((x) => Regex.fromMap(x))),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BannedClassName &&
        other.layer == layer &&
        other.bannedClassNames == bannedClassNames;
  }

  @override
  int get hashCode => layer.hashCode ^ bannedClassNames.hashCode;
}
