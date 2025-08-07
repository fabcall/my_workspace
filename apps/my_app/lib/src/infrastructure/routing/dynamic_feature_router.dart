import 'dart:async';
import 'package:core_framework/core_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/infrastructure/routing/dynamic_routing_config.dart';
import 'package:my_app/src/ui/screens/error/not_found_screen.dart';

/// Dynamic router that works with features
class DynamicFeatureRouter implements AppRouter {
  DynamicFeatureRouter({
    required FeatureRegistry featureRegistry,
    required String initialRoute,
    List<RouteBase> globalRoutes = const [],
    Widget Function(BuildContext, GoRouterState)? errorBuilder,
    List<NavigatorObserver> observers = const [],
  }) : _initialRoute = initialRoute,
       _globalRoutes = globalRoutes,
       _errorBuilder = errorBuilder,
       _observers = observers,
       _navigatorKey = GlobalKey<NavigatorState>() {
    // Create dynamic configuration
    _routingConfig = DynamicRoutingConfig(
      featureRegistry: featureRegistry,
      globalRoutes: globalRoutes,
      initialRoute: initialRoute,
      errorBuilder: errorBuilder,
      redirect: _handleRedirect,
    );

    // Create GoRouter with dynamic configuration
    _router = GoRouter.routingConfig(
      routingConfig: _routingConfig,
      navigatorKey: _navigatorKey,
      initialLocation: initialRoute,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
      observers: observers,
      debugLogDiagnostics: kDebugMode,
    );

    Logger.debug(
      'DynamicFeatureRouter created with GoRouter.routingConfig',
      tag: 'Router',
    );
  }

  final String _initialRoute;
  final List<RouteBase> _globalRoutes;
  final Widget Function(BuildContext, GoRouterState)? _errorBuilder;
  final List<NavigatorObserver> _observers;
  final GlobalKey<NavigatorState> _navigatorKey;

  late final GoRouter _router;
  late final DynamicRoutingConfig _routingConfig;
  bool _isAppInitialized = false;

  // AppRouter interface
  @override
  GoRouter get router => _router;
  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  @override
  List<RouteBase> get globalRoutes => List.unmodifiable(_globalRoutes);
  @override
  String get initialRoute => _initialRoute;
  @override
  List<NavigatorObserver> get observers => List.unmodifiable(_observers);
  @override
  Widget Function(BuildContext, GoRouterState)? get errorBuilder =>
      _errorBuilder;

  /// Getter to check if app has been initialized
  bool get isInitialized => _isAppInitialized;

  /// Redirect handler with Global Guards
  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentPath = state.matchedLocation;

    // 1. MAXIMUM PRIORITY: App not initialized → splash
    if (!_isAppInitialized && currentPath != '/splash') {
      final splashUrl = _buildSplashUrl(currentPath, state);
      Logger.debug(
        'App not initialized, redirecting to splash',
        tag: 'Router',
        data: {
          'currentPath': currentPath,
          'splashUrl': splashUrl,
        },
      );
      return splashUrl;
    }

    // 2. App initialized + on splash → final destination
    if (_isAppInitialized && currentPath == '/splash') {
      final destinationUrl = _buildDestinationUrl(state);
      Logger.debug(
        'App initialized, leaving splash',
        tag: 'Router',
        data: {
          'destinationUrl': destinationUrl,
        },
      );
      return destinationUrl;
    }

    // 3. NEW: Global guards (only if app initialized)
    if (_isAppInitialized) {
      final guardRedirect = await GuardRegistry.executeGlobalGuards(
        context,
        state,
      );
      if (guardRedirect != null) {
        Logger.debug(
          'Global guard triggered redirect',
          tag: 'Router',
          data: {
            'from': currentPath,
            'to': guardRedirect,
          },
        );
      }
      return guardRedirect;
    }

    // 4. No redirection necessary
    return null;
  }

  /// Builds splash URL with redirection
  String _buildSplashUrl(String currentPath, GoRouterState state) {
    if (currentPath != '/' && currentPath.isNotEmpty) {
      final redirect = Uri.encodeComponent(currentPath);
      final query = state.uri.query.isNotEmpty ? '&${state.uri.query}' : '';
      return '/splash?redirectTo=$redirect$query';
    }
    return '/splash';
  }

  /// Builds destination URL after initialization
  String _buildDestinationUrl(GoRouterState state) {
    final target = state.uri.queryParameters['redirectTo'] ?? _initialRoute;
    final params = Map<String, String>.from(state.uri.queryParameters)
      ..remove('redirectTo');

    if (params.isNotEmpty) {
      final query = params.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      return '$target?$query';
    }

    return target;
  }

  /// Default error builder
  Widget _defaultErrorBuilder(BuildContext context, GoRouterState state) {
    Logger.warning(
      'Route not found, showing 404 screen',
      tag: 'Router',
      data: {
        'path': state.uri.toString(),
        'matchedLocation': state.matchedLocation,
      },
    );

    return const NotFoundScreen();
  }

  /// Marks the application as fully initialized
  @override
  void markAsInitialized() {
    if (!_isAppInitialized) {
      Logger.info('Marking app as initialized', tag: 'Router');

      _isAppInitialized = true;

      // Force refresh configuration
      _routingConfig.refresh();

      Logger.info('App initialized - routes are now available!', tag: 'Router');
    }
  }

  /// Rebuilds the router with current routes from FeatureRegistry
  @override
  void refreshRouter() {
    Logger.debug('Manual router refresh requested', tag: 'Router');
    _routingConfig.refresh();
  }

  @override
  void navigateTo(String route, {Object? extra}) {
    Logger.debug(
      'Navigating to route',
      tag: 'Router',
      data: {
        'route': route,
        'hasExtra': extra != null,
      },
    );
    _router.go(route, extra: extra);
  }

  @override
  void replaceTo<T>(String route, {Object? extra}) {
    Logger.debug(
      'Replacing current route',
      tag: 'Router',
      data: {
        'route': route,
        'hasExtra': extra != null,
      },
    );
    _router.replace<T>(route, extra: extra);
  }

  @override
  Future<T?> pushTo<T>(String route, {Object? extra}) {
    Logger.debug(
      'Pushing route',
      tag: 'Router',
      data: {
        'route': route,
        'hasExtra': extra != null,
      },
    );
    return _router.push<T>(route, extra: extra);
  }

  @override
  void goBack() {
    Logger.debug('Going back', tag: 'Router');
    _router.pop();
  }

  @override
  String get currentRoute => _router.state.uri.toString();

  @override
  String get currentMatchedRoute => _router.state.matchedLocation;

  @override
  Map<String, String> get currentParams => _router.state.pathParameters;

  @override
  Map<String, String> get currentQueryParams =>
      _router.state.uri.queryParameters;

  @override
  Object? get currentExtra => _router.state.extra;

  /// Releases resources used by the router
  @override
  void dispose() {
    Logger.debug('Disposing router', tag: 'Router');

    _routingConfig.dispose();

    Logger.debug('Router disposed', tag: 'Router');
  }
}
