import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';

const _keyBanned = 'banned';
const _keySeverity = 'severity';

class BannedImports {
  BannedImports(
    this.layer,
    this.severity,
    this.cannotImportFrom,
  );

  factory BannedImports.fromMap(Map<dynamic, dynamic> map) {
    final bannedLayers = map[_keyBanned] == null
        ? <Layer>[]
        : List<Layer>.from(
            (map[_keyBanned] as Iterable).map(
              (x) => Layer.fromMap(x as Map),
            ),
          );

    return BannedImports(
      Layer.fromMap(map['layer'] as Map),
      map[_keySeverity] != null
          ? lintSeverityFromString(map[_keySeverity] as String)
          : null,
      bannedLayers,
    );
  }

  final Layer layer;
  final LintSeverity? severity;
  final List<Layer> cannotImportFrom;

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
