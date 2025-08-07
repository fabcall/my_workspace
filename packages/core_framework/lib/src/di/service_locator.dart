/// Interface for dependency reading only
abstract class ServiceLocator {
  /// Gets a registered instance of type T
  T get<T extends Object>({String? instanceName});

  /// Checks if type T is registered
  bool isRegistered<T extends Object>({String? instanceName});
}
