import 'package:architecture_linter/src/configuration/layer.dart';
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

  static List<Layer> layers = [
    dataLayer,
    domainLayer,
    presentationLayer,
  ];
  static List<Glob> excludes = [
    Glob("**.g.dart"),
    Glob("**/some_folder/**"),
  ];

  static Map<Layer, Set<Layer>> get bannedImports {
    final map = <Layer, Set<Layer>>{};

    for (final layer in layers) {
      map[layer] = layers.where((element) => element != layer).toSet();
    }

    return map;
  }

  static ProjectConfiguration baseConfigMock = ProjectConfiguration(
    layers,
    excludes,
    bannedImports,
    <Layer, Set<RegExp>>{},
    LintSeverity.warning,
  );
}
