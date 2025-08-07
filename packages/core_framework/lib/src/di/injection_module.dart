import 'package:core_framework/core_framework.dart';

/// Abstract module for dependency injection registration
abstract class InjectionModule {
  /// Registers dependencies in the container
  void register(DIContainer container);
}
