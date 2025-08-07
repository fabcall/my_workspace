import 'package:core_framework/src/feature/feature.dart';
import 'package:core_framework/src/feature/feature_registry.dart';
import 'package:core_framework/src/feature/shell_feature.dart';
import 'package:go_router/go_router.dart';

/// Route cache focused on organization and code clarity
class RouteCache {
  List<RouteBase>? _cachedRoutes;

  /// Gets all routes, using cache when available
  List<RouteBase> getRoutes(FeatureRegistry registry) {
    return _cachedRoutes ??= _buildAllRoutes(registry);
  }

  /// Invalidates the cache (called when features change)
  void invalidate() {
    _cachedRoutes = null;
  }

  /// Builds all routes from scratch
  List<RouteBase> _buildAllRoutes(FeatureRegistry registry) {
    final routes = <RouteBase>[
      ..._buildShellRoutes(registry),
      ..._buildStandaloneRoutes(registry),
    ];

    return List.unmodifiable(routes);
  }

  /// Builds shell routes
  List<RouteBase> _buildShellRoutes(FeatureRegistry registry) {
    final shellRoutes = <RouteBase>[];

    for (final shell in registry.features.whereType<ShellFeature>()) {
      final shellRoute = shell.shellRouteModule.generateShellRoute(
        builder: shell.shellBuilder,
        featureRegistry: registry,
      );
      shellRoutes.add(shellRoute);
    }

    return shellRoutes;
  }

  /// Builds standalone routes
  List<RouteBase> _buildStandaloneRoutes(FeatureRegistry registry) {
    final standaloneRoutes = <RouteBase>[];

    for (final feature in registry.features.whereType<Feature>()) {
      if (feature.routeModule != null && feature.parentShellName == null) {
        standaloneRoutes.addAll(feature.routeModule!.routes);
      }
    }

    return standaloneRoutes;
  }
}
