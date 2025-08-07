import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/infrastructure/di/app_di_context_accessor.dart';
import 'package:my_app/src/infrastructure/di/dependency_configurator.dart';
import 'package:my_app/src/infrastructure/di/get_it_di_container.dart';
import 'package:my_app/src/infrastructure/messaging/event_bus_impl.dart';
import 'package:my_app/src/infrastructure/routing/dynamic_feature_router.dart';
import 'package:my_app/src/ui/screens/splash/splash_screen.dart';

class AppInfrastructureInitializer implements AppInitializer {
  const AppInfrastructureInitializer();

  @override
  Future<AppBootResult> initialize(AppConfig config) async {
    // Configura o sistema de injeção de dependência
    final container = createDIContainer()..registerSingleton<AppConfig>(config);

    // Inicializa O DIContextAccessor
    DIContextAccessor.initialize(AppDIContextAccessor());

    // Configura o sistema de mensageria
    final eventBus = createEventBus();
    container.registerSingleton<EventBus>(eventBus);

    // Configura o registro de features
    final featureRegistry = createFeatureRegistry(container, eventBus);
    container.registerSingleton<FeatureRegistry>(featureRegistry);

    // Configura o router
    final router = createRouter(featureRegistry, config);
    container.registerSingleton<AppRouter>(router);

    // Configurações adicionais específicas da implementação
    await configureDependencies(container, config);

    return AppBootResult(
      container: container,
      eventBus: eventBus,
      featureRegistry: featureRegistry,
      router: router,
      config: config,
    );
  }

  // Factory methods que podem ser sobrescritos
  DIContainer createDIContainer() => GetItDIContainer();

  EventBus createEventBus() => EventBusImpl();

  FeatureRegistry createFeatureRegistry(
    DIContainer container,
    EventBus eventBus,
  ) => FeatureRegistry(
    container: container,
    eventBus: eventBus,
  );

  AppRouter createRouter(
    FeatureRegistry featureRegistry,
    AppConfig config, {
    Widget Function(BuildContext, GoRouterState)? errorBuilder,
  }) => DynamicFeatureRouter(
    featureRegistry: featureRegistry,
    initialRoute: config.initialRoute,
    errorBuilder: errorBuilder,
    globalRoutes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          minDisplayDuration: const Duration(seconds: 3),
          onInitializationFinished: () => _notifyInitializationFinished(
            context,
          ),
        ),
      ),
    ],
  );

  void _notifyInitializationFinished(BuildContext context) {
    // Notifica o router também
    final router = DIContextAccessor.of(context).get<AppRouter>();
    if (router is DynamicFeatureRouter) {
      router.markAsInitialized();
    }
  }

  Future<void> configureDependencies(
    DIContainer container,
    AppConfig config,
  ) async {
    await DependencyConfigurator(container, config).configureAll();
  }
}
