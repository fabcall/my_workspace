import 'package:core_framework/core_framework.dart';

/// Abstract base class that defines the minimum contract for all features.
/// Always inherit from `Feature` or `ShellFeature` instead of this class directly.
abstract class BaseFeature {
  /// Unique name of the feature within the application
  String get name;

  /// Initializes the feature with application context.
  /// Called during app startup after all features are registered.
  /// Use for registering services and initializing resources.
  Future<void> initialize({required FeatureContext context}) async {}

  /// Releases resources used by the feature.
  /// Called during app shutdown or when feature is removed.
  /// Use for closing connections and cleaning up resources.
  Future<void> dispose() async {}
}
