import 'package:core_framework/core_framework.dart';

class AppBootResult {
  final DIContainer container;
  final EventBus eventBus;
  final FeatureRegistry featureRegistry;
  final AppRouter router;
  final AppConfig config;

  AppBootResult({
    required this.container,
    required this.eventBus,
    required this.featureRegistry,
    required this.router,
    required this.config,
  });
}
