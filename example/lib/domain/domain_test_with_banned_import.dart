// This file demonstrates a banned import violation
// Domain layer should NOT import from Presentation layer
// Testing bug: when first import is valid, banned imports after it are not detected

import 'package:example/domain/domain_class.dart'; // Valid import (same layer)
import 'package:example/presentation/presentation_class.dart'; // BANNED import

class DomainTestClass {
  void performAction() {
    // Valid usage
    final domain = DomainClass();

    // This violates the architecture rules:
    // Domain layer is importing from Presentation layer
    final presentation = PresentationClass();
    presentation.call();
  }
}
