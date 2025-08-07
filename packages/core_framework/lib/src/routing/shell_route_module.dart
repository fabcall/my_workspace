import 'package:core_framework/core_framework.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Route module for StatefulShellRoute
abstract class ShellRouteModule {
  /// Shell name
  String get name;

  /// Generates StatefulShellRoute with automatic branch discovery
  StatefulShellRoute generateShellRoute({
    required Widget Function(BuildContext, GoRouterState, Widget) builder,
    required FeatureRegistry featureRegistry,
  }) {
    final branches = _discoverBranches(featureRegistry);

    return StatefulShellRoute.indexedStack(
      builder: builder,
      branches: branches
          .map(
            (branch) => StatefulShellBranch(
              routes: branch.routes,
              initialLocation: branch.initialLocation,
            ),
          )
          .toList(),
    );
  }

  /// Discovers branches based on registered features
  List<ShellBranch> _discoverBranches(FeatureRegistry featureRegistry) {
    final branches = <ShellBranch>[];

    final childFeatures = featureRegistry.features
        .whereType<Feature>()
        .where((f) => f.parentShellName == name)
        .toList();

    for (final feature in childFeatures) {
      if (feature.routeModule != null) {
        final branch = ShellBranch(
          name: feature.name,
          routes: feature.routeModule!.routes,
          initialLocation: _findInitialLocation(feature.routeModule!.routes),
        );
        branches.add(branch);
      }
    }

    return branches;
  }

  /// Finds initial location of the first route
  String? _findInitialLocation(List<RouteBase> routes) {
    if (routes.isEmpty) return null;

    final firstRoute = routes.first;
    if (firstRoute is GoRoute) {
      return firstRoute.path;
    }

    return null;
  }
}

/// Represents a StatefulShellRoute branch
class ShellBranch {
  const ShellBranch({
    required this.name,
    required this.routes,
    this.initialLocation,
  });

  final String name;
  final List<RouteBase> routes;
  final String? initialLocation;
}
