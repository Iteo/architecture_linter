import 'package:custom_lint_builder/custom_lint_builder.dart';

class ArchitectureFileConfiguration {
  ArchitectureFileConfiguration({
    this.filePath = 'architecture.yaml',
    this.checkSeverity = LintSeverity.values,
  });

  final String filePath;
  final List<LintSeverity> checkSeverity;

  // TODO Correct names

  get allowsError => checkSeverity.contains(LintSeverity.error);

  get allowsWarning => checkSeverity.contains(LintSeverity.warning);

  get allowsInfo => checkSeverity.contains(LintSeverity.info);
}