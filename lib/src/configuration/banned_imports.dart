import 'package:architecture_linter/src/configuration/lint_severity.dart';

import '../configuration/layer.dart';

class BannedImports {
  final Layer layer;
  final LintSeverity? severity;
  final List<Layer> cannotImportFrom;

  BannedImports(
    this.layer,
    this.severity,
    this.cannotImportFrom,
  );

  factory BannedImports.fromMap(Map<dynamic, dynamic> map) {
    return BannedImports(
      Layer.fromMap(map['layer']),
      map['severity'] != null ? lintSeverityFromString(map['severity']) : null,
      List<Layer>.from(map['banned']?.map((x) => Layer.fromMap(x))),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BannedImports &&
        other.layer == layer &&
        other.cannotImportFrom == cannotImportFrom;
  }

  @override
  int get hashCode => layer.hashCode ^ cannotImportFrom.hashCode;
}
