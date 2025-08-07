import 'dart:async';
import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef AppRouterRedirect =
    FutureOr<String?> Function(
      BuildContext context,
      GoRouterState state,
    );

/// Configuração de rotas dinâmica que implementa ValueListenable
class DynamicRoutingConfig extends ValueNotifier<RoutingConfig> {
  DynamicRoutingConfig({
    required this.featureRegistry,
    required this.globalRoutes,
    required this.initialRoute,
    required this.errorBuilder,
    required this.redirect,
  }) : super(
         _buildInitialConfig(
           globalRoutes: globalRoutes,
           featureRoutes: featureRegistry.routes,
           redirect: redirect,
         ),
       ) {
    // Escuta mudanças no FeatureRegistry
    _listenToFeatureChanges();
  }

  final FeatureRegistry featureRegistry;
  final List<RouteBase> globalRoutes;
  final String initialRoute;
  final Widget Function(BuildContext, GoRouterState)? errorBuilder;
  final AppRouterRedirect? redirect;

  StreamSubscription<BaseFeature>? _featureRegistrationSub;

  /// Cria configuração inicial
  static RoutingConfig _buildInitialConfig({
    required List<RouteBase> globalRoutes,
    required List<RouteBase> featureRoutes,
    required AppRouterRedirect? redirect,
  }) {
    return RoutingConfig(
      routes: [
        ...globalRoutes,
        ...featureRoutes,
      ],
      redirect: redirect!,
    );
  }

  /// Atualiza configuração com novas rotas
  void _updateRoutingTable() {
    final newConfig = RoutingConfig(
      routes: [
        ...globalRoutes,
        ...featureRegistry.routes, // Sempre pega rotas atuais do registry
      ],
      redirect: redirect!,
    );

    // Notifica mudança - GoRouter vai rebuildar automaticamente!
    value = newConfig;

    final totalRoutes = globalRoutes.length + featureRegistry.routes.length;
    Logger.info(
      'Configuração de rotas atualizada com $totalRoutes rotas',
      tag: 'DynamicRouting',
    );
  }

  /// Escuta mudanças no FeatureRegistry
  void _listenToFeatureChanges() {
    _featureRegistrationSub = featureRegistry.onFeatureRegistered.listen((
      feature,
    ) {
      // Atualiza quando qualquer feature é registrada (Shell ou Feature)
      final type = feature is ShellFeature ? 'Shell' : 'Feature';
      Logger.debug(
        '$type registrada: ${feature.name}',
        tag: 'DynamicRouting',
      );
      _updateRoutingTable();
    });
  }

  /// Força atualização manual da configuração
  void refresh() {
    Logger.info(
      'Refresh manual da configuração de rotas solicitado',
      tag: 'DynamicRouting',
    );
    _updateRoutingTable();
  }

  @override
  void dispose() {
    Logger.info(
      'Fazendo dispose da configuração de rotas',
      tag: 'DynamicRouting',
    );

    _featureRegistrationSub?.cancel();
    super.dispose();
  }
}
