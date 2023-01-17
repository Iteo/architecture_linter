import 'package:architecture_linter/src/configuration/layer.dart';
import 'package:architecture_linter/src/configuration/layers_config.dart';
import 'package:architecture_linter/src/configuration/lint_severity.dart';
import 'package:architecture_linter/src/configuration/project_configuration.dart';
import 'package:glob/glob.dart';

class ConfigMocks {
  const ConfigMocks._();

  static Layer dataLayer = Layer(
    "Data",
    RegExp('data'),
  );

  static Layer domainLayer = Layer(
    "Domain",
    RegExp('domain'),
  );

  static Layer presentationLayer = Layer(
    "Presentation",
    RegExp('presentation'),
  );

  static Layer modelLayer = Layer(
    'model',
    RegExp("model"),
  );

  static List<Layer> layers = [
    dataLayer,
    domainLayer,
    presentationLayer,
    modelLayer,
  ];
  static List<Glob> excludes = [
    Glob("**.g.dart"),
    Glob("**/some_folder/**"),
  ];

  static Map<Layer, Set<Layer>> get bannedImports {
    final map = <Layer, Set<Layer>>{};

    for (final layer in layers) {
      if (layer != modelLayer) {
        map[layer] = layers
            .where((element) => element != layer && element != modelLayer)
            .toSet();
      }
    }

    return map;
  }

  static Map<Layer, LintSeverity> bannedImportsSeverities = {
    domainLayer: LintSeverity.info
  };

  static List<LayerConfig> layersConfig = [
    LayerConfig(severity: LintSeverity.error, layer: modelLayer)
  ];

  static ProjectConfiguration baseConfigMock = ProjectConfiguration(
    layers,
    excludes,
    bannedImports,
    bannedImportsSeverities,
    <Layer, Set<RegExp>>{},
    LintSeverity.warning,
    layersConfig,
  );
}
