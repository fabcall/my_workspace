import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';

/// Abstract interface for accessing DIContainer via BuildContext
abstract class DIContextAccessor {
  static DIContextAccessor? _instance;

  /// Initializes the accessor with a specific implementation
  static void initialize(DIContextAccessor accessor) {
    _instance = accessor;
  }

  /// Gets the DIContainer through BuildContext
  static ScopedServiceLocator of(BuildContext context) {
    if (_instance == null) {
      throw Exception(
        'DIContextAccessor has not been initialized. '
        'Call DIContextAccessor.initialize() during application boot.',
      );
    }
    return _instance!.getDIContainer(context);
  }

  /// Checks if the accessor has been initialized
  static bool get isInitialized => _instance != null;

  /// Resets the accessor (useful for testing)
  static void reset() {
    _instance = null;
  }

  /// Abstract method that must be implemented by concrete implementations
  ScopedServiceLocator getDIContainer(BuildContext context);
}
