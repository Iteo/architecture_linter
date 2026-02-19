// Test case for bug where banned imports after external package imports were not detected
// Simulating real-world scenario with Flutter/package imports

import 'package:test/test.dart'; // External package import
import '../presentation/presentation_class.dart'; // Banned import

class DomainClassWithPackageImportFirst {
  final PresentationClass presentationClass = PresentationClass();

  void runTest() {
    expect(presentationClass, isNotNull);
  }
}
