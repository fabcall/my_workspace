/// Interface for dependency registration only
abstract class DependencyRegistrar {
  /// Registers an instance as singleton
  void registerSingleton<T extends Object>(T instance, {String? instanceName});

  /// Registers a factory for type T
  void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  });

  /// Registers a lazy singleton for type T
  void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  });

  /// Removes a registration
  void unregister<T extends Object>({String? instanceName});
}
