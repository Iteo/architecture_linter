import 'package:analyzer_plugin/protocol/protocol_common.dart';

class ConfigurationLints {
  const ConfigurationLints._();

  static AnalysisError configurationErrorLint(String path) => AnalysisError(
        AnalysisErrorSeverity.ERROR,
        AnalysisErrorType.SYNTACTIC_ERROR,
        Location(
          path,
          0,
          0,
          0,
          0,
        ),
        "There was an error while reading configuration.",
        'architecture_linter_config_file_error',
        correction: "Make sure that analysis_option.yaml contains architecture_linter: part",
      );

  static AnalysisError configurationNoLayersLint(String path) => AnalysisError(
        AnalysisErrorSeverity.WARNING,
        AnalysisErrorType.SYNTACTIC_ERROR,
        Location(
          path,
          0,
          0,
          0,
          0,
        ),
        "Configuration file does not have layers declared",
        'architecture_linter_layers_not_found',
        correction: "Make sure that the architecture config contains"
            " section `layers:` with at least one entry. Check README "
            "for more information how to declare proper config. structure.",
      );

  static AnalysisError configurationNoBannedImportsLint(String path) => AnalysisError(
        AnalysisErrorSeverity.WARNING,
        AnalysisErrorType.SYNTACTIC_ERROR,
        Location(
          path,
          0,
          0,
          0,
          0,
        ),
        'Configuration file does not have banned imports declared',
        'architecture_linter_banned_imports_not_found',
        correction: "Make sure that the architecture config contains"
            " section `bannedImports:` with at least one entry. Check README "
            "for more information how to declare proper config. structure.",
      );
}
