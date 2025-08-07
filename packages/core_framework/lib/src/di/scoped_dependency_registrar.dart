import 'package:core_framework/core_framework.dart';

/// Interface for dependency registration with scope support
abstract class ScopedDependencyRegistrar extends DependencyRegistrar {
  /// Creates a new scope
  void createScope(String scopeName);

  /// Closes a scope
  void closeScope(String scopeName);

  /// Registers a singleton in the specified scope
  void registerScopedSingleton<T extends Object>(String scopeName, T instance);

  /// Registers a factory in the specified scope
  void registerScopedFactory<T extends Object>(
    String scopeName,
    T Function() factory,
  );

  /// Registers a lazy singleton in the specified scope
  void registerScopedLazySingleton<T extends Object>(
    String scopeName,
    T Function() factory,
  );
}
