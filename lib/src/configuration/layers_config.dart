import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';

class LayerConfig {
  const LayerConfig({
    required this.severity,
    required this.layer,
  });

  final Layer layer;
  final LintSeverity severity;

  factory LayerConfig.fromMap(Map<dynamic, dynamic> map) {
    final layer = Layer.fromMap(map['layer']);
    final severity = lintSeverityFromString(map['severity']);

    return LayerConfig(
      severity: severity,
      layer: layer,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LayerConfig &&
        other.layer == layer &&
        other.severity == severity;
  }

  @override
  int get hashCode => Object.hash(
        layer,
        severity,
      );
}
