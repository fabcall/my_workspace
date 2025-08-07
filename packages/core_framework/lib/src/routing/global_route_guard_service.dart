import 'package:core_framework/src/routing/route_guard_service.dart';

/// Separate interface for global guards
abstract class GlobalRouteGuardService extends RouteGuardService {
  /// Priority of the global guard (lower = higher priority)
  int get priority => 0;

  /// Paths that should be excluded from global protection
  List<String> get excludedPaths => const [];

  /// Regex patterns for excluded paths
  List<String> get excludedPathPatterns => const [];

  /// Checks if the path should be protected
  bool shouldProtectPath(String path) {
    // Check exact exclusions
    if (excludedPaths.contains(path)) {
      return false;
    }

    // Check regex patterns
    for (final pattern in excludedPathPatterns) {
      if (RegExp(pattern).hasMatch(path)) {
        return false;
      }
    }

    return true;
  }
}
