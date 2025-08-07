import 'dart:async';

import 'package:core_framework/core_framework.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Manages application feature registration
class FeatureRegistry {
  final List<BaseFeature> _features = [];
  final DIContainer _container;
  final EventBus _eventBus;

  // Streams for events
  final StreamController<BaseFeature> _featureRegisteredController =
      StreamController<BaseFeature>.broadcast();

  // Route cache
  final RouteCache _routeCache = RouteCache();

  FeatureRegistry({
    required DIContainer container,
    required EventBus eventBus,
  }) : _container = container,
       _eventBus = eventBus;

  /// Stream of registered features
  Stream<BaseFeature> get onFeatureRegistered =>
      _featureRegisteredController.stream;

  /// Registers a feature
  Future<void> registerFeature(BaseFeature feature) async {
    if (_features.any((f) => f.name == feature.name)) {
      throw Exception('Feature "${feature.name}" is already registered.');
    }

    _features.add(feature);

    // Register DI if it exists
    if (feature is Feature && feature.injectionModule != null) {
      feature.injectionModule!.register(_container);
    }

    // Initialize the feature
    final context = FeatureContext(
      eventBus: _eventBus,
      serviceLocator: _container,
    );
    await feature.initialize(context: context);

    // Invalidate cache
    _routeCache.invalidate();

    // Publish event
    _featureRegisteredController.add(feature);
  }

  /// Gets all features
  List<BaseFeature> get features => List.unmodifiable(_features);

  /// Gets all routes
  List<RouteBase> get routes => _routeCache.getRoutes(this);

  /// Gets localization delegates
  List<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    return _features
        .whereType<Feature>()
        .where((f) => f.localizationsDelegate != null)
        .map((f) => f.localizationsDelegate!)
        .toList();
  }

  /// Closes resources
  void dispose() {
    _featureRegisteredController.close();
  }

  /// Gets the EventBus
  EventBus get eventBus => _eventBus;
}
