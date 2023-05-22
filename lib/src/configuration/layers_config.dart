import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';

class LayerConfig {
  const LayerConfig({
    required this.severity,
    required this.layer,
  });

  factory LayerConfig.fromMap(Map<dynamic, dynamic> map) {
    final layer = Layer.fromMap(map['layer'] as Map);
    final severity = lintSeverityFromString(map['severity'] as String?);

    return LayerConfig(
      severity: severity,
      layer: layer,
    );
  }

  final Layer layer;
  final LintSeverity severity;

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
