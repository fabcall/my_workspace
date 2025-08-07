import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  /// Current router
  GoRouter get router;

  /// Navigator key
  GlobalKey<NavigatorState> get navigatorKey;

  /// Global routes
  List<RouteBase> get globalRoutes;

  /// Initial route
  String get initialRoute;

  /// Navigation observers
  List<NavigatorObserver> get observers;

  /// Error builder
  Widget Function(BuildContext, GoRouterState)? get errorBuilder;

  /// Marks as initialized
  void markAsInitialized();

  /// Forces manual router refresh
  void refreshRouter();

  /// Navigation methods
  void navigateTo(String route, {Object? extra});
  void replaceTo<T>(String route, {Object? extra});
  Future<T?> pushTo<T>(String route, {Object? extra});
  void goBack();

  /// Current state information
  String get currentRoute;
  String get currentMatchedRoute;
  Map<String, String> get currentParams;
  Map<String, String> get currentQueryParams;
  Object? get currentExtra;

  /// Cleanup
  void dispose();
}
