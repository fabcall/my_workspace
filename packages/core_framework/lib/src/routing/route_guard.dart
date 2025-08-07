import 'package:core_framework/src/logging/logger.dart';
import 'package:core_framework/src/routing/guard_registry.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteGuard {
  final List<String> requiredGuards;
  final String? fallbackRedirect;

  const RouteGuard(
    this.requiredGuards, {
    this.fallbackRedirect = '/landing',
  });

  /// Checks all required guards
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    for (final guardName in requiredGuards) {
      final guard = GuardRegistry.get(guardName);

      if (guard == null) {
        Logger.warning(
          'Guard "$guardName" not found. Denying access.',
          tag: 'RouteGuard',
        );
        return fallbackRedirect;
      }

      try {
        final canAccess = await guard.canAccess(context, state);
        if (!canAccess) {
          Logger.warning(
            'Access denied by guard "$guardName"',
            tag: 'RouteGuard',
          );
          return guard.redirectPath;
        }
      } catch (e) {
        Logger.error(
          'Error in guard "$guardName"',
          tag: 'RouteGuard',
          error: e,
        );
        return guard.redirectPath;
      }
    }

    return null; // All guards passed
  }
}
