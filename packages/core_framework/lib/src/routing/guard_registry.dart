import 'package:core_framework/core_framework.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Centralized registry for local and global guards
class GuardRegistry {
  // Private constructor prevents instantiation
  GuardRegistry._();

  static final Map<String, RouteGuardService> _guards = {};
  static List<GlobalRouteGuardService>? _globalGuardsCache;

  /// Registers a guard (local or global detected automatically)
  static void register(RouteGuardService guard) {
    _guards[guard.name] = guard;

    if (guard is GlobalRouteGuardService) {
      _globalGuardsCache = null;
      Logger.info(
        'Global guard "${guard.name}" registered',
        tag: 'GuardRegistry',
      );
    } else {
      Logger.info(
        'Local guard "${guard.name}" registered',
        tag: 'GuardRegistry',
      );
    }
  }

  /// Gets guard by name
  static RouteGuardService? get(String name) => _guards[name];

  /// Checks if guard is registered
  static bool isRegistered(String name) => _guards.containsKey(name);

  /// Lists names of registered guards
  static List<String> get registeredGuards => _guards.keys.toList();

  /// Gets global guards ordered by priority
  static List<GlobalRouteGuardService> getGlobalGuards() {
    if (_globalGuardsCache == null) {
      final globalGuards =
          _guards.values.whereType<GlobalRouteGuardService>().toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));

      _globalGuardsCache = globalGuards;
    }
    return _globalGuardsCache!;
  }

  /// Executes global guards for a route
  static Future<String?> executeGlobalGuards(
    BuildContext context,
    GoRouterState state,
  ) async {
    final path = state.matchedLocation;

    for (final guard in getGlobalGuards()) {
      if (guard.shouldProtectPath(path)) {
        try {
          final canAccess = await guard.canAccess(context, state);
          if (!canAccess) {
            Logger.warning(
              'Access denied by global guard "${guard.name}" for $path',
              tag: 'GuardRegistry',
            );
            return guard.redirectPath;
          }
        } catch (e) {
          Logger.error(
            'Error in global guard "${guard.name}"',
            tag: 'GuardRegistry',
            error: e,
          );
          return guard.redirectPath;
        }
      }
    }
    return null;
  }

  /// Clears guards (for testing only)
  static void clear() {
    _guards.clear();
    _globalGuardsCache = null;
    Logger.debug('All guards cleared', tag: 'GuardRegistry');
  }
}
