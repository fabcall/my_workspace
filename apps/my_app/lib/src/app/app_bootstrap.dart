import 'dart:async';

import 'package:core_framework/core_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:my_app/src/app/app_infrastructure_initializer.dart';
import 'package:my_app/src/app/app_widget.dart';
import 'package:my_app/src/app/error_app_widget.dart';
import 'package:my_app/src/infrastructure/error_handling/crashlytics_error_handler.dart';

/// Classe base para inicialização do aplicativo
abstract class AppBootstrap {
  const AppBootstrap(this.config);

  final AppConfig config;

  // GETTERS - características da implementação
  @protected
  AppInitializer get appInitializer => const AppInfrastructureInitializer();

  @protected
  ErrorHandler get errorHandler => const CrashlyticsErrorHandler();

  @protected
  List<BaseFeature> get features;

  // Factory methods
  @protected
  Widget createRootApp(AppBootResult bootResult) => AppWidget(
    container: bootResult.container,
    featureRegistry: bootResult.featureRegistry,
    eventBus: bootResult.eventBus,
    router: bootResult.router,
    config: config,
  );

  @protected
  Widget createErrorApp(Object error, StackTrace stackTrace) => ErrorAppWidget(
    errorMessage: error.toString(),
    stackTrace: stackTrace.toString(),
    onRetry: startApp,
  );

  /// Inicializa e inicia o aplicativo
  Future<void> startApp() async {
    try {
      // Configura o binding do Flutter
      WidgetsFlutterBinding.ensureInitialized();

      // 2. CONFIGURE O LOGGER IMEDIATAMENTE (ANTES de qualquer outra coisa)
      await LoggerFactory.configureConsole(
        minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
      );

      // Agora, qualquer chamada de log subsequente funcionará
      Logger.info(
        'Iniciando o processo de inicialização da aplicação...',
        tag: 'Bootstrap',
      );

      // Inicialização
      final bootResult = await appInitializer.initialize(config);

      // Configuração global
      errorHandler.setupGlobalErrorHandling(config, bootResult.container);

      // Inicia app
      runApp(createRootApp(bootResult));

      // Registra features
      await _registerFeatures(bootResult.featureRegistry, bootResult.router);
    } catch (e, stackTrace) {
      errorHandler.handleStartupError(e, stackTrace);

      runApp(createErrorApp(e, stackTrace));

      if (kDebugMode || config.environment == 'development') {
        rethrow;
      }
    }
  }

  Future<void> _registerFeatures(
    FeatureRegistry registry,
    AppRouter router,
  ) async {
    try {
      // Registra todas as features em sequência
      for (final feature in features) {
        await registry.registerFeature(feature);
      }

      // Marca app como inicializado
      // router.markAsInitialized();

      // Publica evento de conclusão
      registry.eventBus.publish(AppInitializationCompletedEvent());
    } catch (e, stackTrace) {
      registry.eventBus.publish(AppInitializationErrorEvent(e, stackTrace));
      if (config.environment != 'production') {
        rethrow;
      }
    }
  }
}
