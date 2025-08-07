import 'package:core_framework/core_framework.dart';

/// Interface for dependency reading with scope support
abstract class ScopedServiceLocator extends ServiceLocator {
  /// Gets a specific dependency from a scope
  T getScopedDependency<T extends Object>(String scopeName);

  /// Checks if a type is registered in a specific scope
  bool isScopedDependencyRegistered<T extends Object>(String scopeName);

  /// Checks if a scope is active
  bool isScopeActive(String scopeName);

  /// Lists all active scopes
  List<String> get activeScopes;
}
