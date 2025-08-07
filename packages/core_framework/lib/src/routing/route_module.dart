import 'package:go_router/go_router.dart';

/// Interface for route modules
abstract class RouteModule {
  /// List of routes defined by the module
  List<RouteBase> get routes;
}
