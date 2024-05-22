import 'package:example/infrastructure/data_source/data_source_class.dart';
// ignore: always_use_package_imports
import '../infrastructure/repository/repository_class.dart';

class PresentationClass {
  void call() {
    final dataSourceClass = DataSourceClass();
    final repositoryClass = RepositoryClass();
  }
}
