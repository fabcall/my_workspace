import 'dart:ui';

import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';

/// Implementação padrão do handler de erros
class CrashlyticsErrorHandler implements ErrorHandler {
  const CrashlyticsErrorHandler();

  @override
  void setupGlobalErrorHandling(AppConfig config, DIContainer container) {
    // Tratamento de erros do Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      // Loga o erro
      FlutterError.presentError(details);

      // Implementação para relatório de erros (ex: Crashlytics)
      if (config.enableCrashReporting) {
        // Exemplo: container.get<CrashReportingService>().recordError(...);
      }
    };

    // Captura erros assíncronos não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      print('ERROR: $error');
      print('STACK: $stack');

      if (config.enableCrashReporting) {
        // Exemplo: container.get<CrashReportingService>().recordError(...);
      }

      return true; // Previne que o erro seja propagado
    };
  }

  @override
  void handleStartupError(Object error, StackTrace stackTrace) {
    print('STARTUP ERROR: $error');
    print('STACK: $stackTrace');
  }
}
