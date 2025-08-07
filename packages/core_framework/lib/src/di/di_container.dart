import 'package:core_framework/core_framework.dart';

/// Complete interface for dependency injection container
/// Combines reading and writing for internal framework use
abstract class DIContainer
    implements ScopedServiceLocator, ScopedDependencyRegistrar {
  /// Resets the container
  void reset();

  /// Lists all registered types
  List<Type> get registeredTypes;
}
