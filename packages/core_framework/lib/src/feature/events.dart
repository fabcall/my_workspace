import 'package:core_framework/core_framework.dart';

/// Feature Registry events
class FeatureRegisteredEvent {
  final Feature feature;

  const FeatureRegisteredEvent(this.feature);

  @override
  String toString() => 'FeatureRegisteredEvent(feature: ${feature.name})';
}

/// Event fired when a feature is unregistered
class FeatureUnregisteredEvent {
  final Feature feature;

  const FeatureUnregisteredEvent(this.feature);

  @override
  String toString() => 'FeatureUnregisteredEvent(feature: ${feature.name})';
}

class AppInitializationCompletedEvent {
  AppInitializationCompletedEvent();
}

class AppInitializationErrorEvent {
  final Object error;
  final StackTrace stackTrace;

  AppInitializationErrorEvent(this.error, this.stackTrace);
}
