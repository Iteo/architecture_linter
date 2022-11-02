import 'package:custom_lint_builder/custom_lint_builder.dart';

class ArchitectureFileConfiguration {
  ArchitectureFileConfiguration({
    this.filePath = 'architecture.yaml',
    this.checkSeverity = LintSeverity.values,
  });

  final String filePath;
  final List<LintSeverity> checkSeverity;

  get isErrorToCheck => checkSeverity.contains(LintSeverity.error);

  get isWarningToCheck => checkSeverity.contains(LintSeverity.warning);

  get isInfoToCheck => checkSeverity.contains(LintSeverity.info);
}
