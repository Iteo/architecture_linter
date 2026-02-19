// Test case for bug where banned imports after valid imports were not detected
// This tests that the analyzer continues checking all imports, not just the first one

import '../domain/get_user_data_use_case.dart'; // Valid import (same layer)
import '../presentation/presentation_class.dart'; // Banned import

class DomainClassWithValidImportFirst {
  final GetUserDataUseCase useCase = GetUserDataUseCase();
  final PresentationClass presentationClass = PresentationClass();
}
