import 'package:custom_lint_builder/custom_lint_builder.dart';

class ArchitectureFileConfiguration {
  ArchitectureFileConfiguration._({
    required this.filePath,
    required this.checkSeverity,
  });

  static final ArchitectureFileConfiguration instance =
      ArchitectureFileConfiguration._(
    filePath: 'architecture.yaml',
    checkSeverity: LintSeverity.values,
  );

  final String filePath;
  final List<LintSeverity> checkSeverity;

  get isErrorToCheck => checkSeverity.contains(LintSeverity.error);

  get isWarningToCheck => checkSeverity.contains(LintSeverity.warning);

  get isInfoToCheck => checkSeverity.contains(LintSeverity.info);
}
