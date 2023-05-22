class Layer {
  Layer(
    this.displayName,
    this.path,
  );

  factory Layer.fromMap(Map<dynamic, dynamic> map) {
    return Layer(
      map['name'] as String,
      map['path'] as String,
    );
  }

  final String displayName;
  final String path;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Layer &&
        other.displayName == displayName &&
        other.path == path;
  }

  @override
  int get hashCode => displayName.hashCode ^ path.hashCode;
}
