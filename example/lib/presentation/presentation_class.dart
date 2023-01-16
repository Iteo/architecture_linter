import 'package:example/infrastructure/data_source/data_source_class.dart';
import 'package:example/infrastructure/repository/repository_class.dart';

class PresentationClass {
  void call() {
    final dataSourceClass = DataSourceClass();
    final repositoryClass = RepositoryClass();
  }
}
