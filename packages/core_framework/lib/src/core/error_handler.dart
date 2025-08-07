import 'package:core_framework/core_framework.dart';

abstract class ErrorHandler {
  void setupGlobalErrorHandling(AppConfig config, DIContainer container);

  void handleStartupError(Object error, StackTrace stackTrace);
}
