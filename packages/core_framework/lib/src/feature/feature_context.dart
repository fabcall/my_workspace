import 'package:core_framework/core_framework.dart';

/// Context provided to features during initialization
class FeatureContext {
  const FeatureContext({
    required this.serviceLocator,
    this.eventBus,
  });

  final EventBus? eventBus;
  final ScopedServiceLocator serviceLocator;

  /// Gets a dependency
  T get<T extends Object>({String? instanceName}) =>
      serviceLocator.get<T>(instanceName: instanceName);

  /// Checks if a dependency is registered
  bool isRegistered<T extends Object>({String? instanceName}) =>
      serviceLocator.isRegistered<T>(instanceName: instanceName);

  /// Gets a dependency from a specific scope
  T getScopedDependency<T extends Object>(String scopeName) =>
      serviceLocator.getScopedDependency<T>(scopeName);

  /// Checks if a scope is active
  bool isScopeActive(String scopeName) =>
      serviceLocator.isScopeActive(scopeName);
}
