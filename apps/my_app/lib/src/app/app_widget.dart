import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_app/src/ui/widgets/di_container_provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({
    super.key,
    required this.container,
    required this.featureRegistry,
    required this.eventBus,
    required this.router,
    required this.config,
  });

  final DIContainer container;
  final FeatureRegistry featureRegistry;
  final EventBus eventBus;
  final AppRouter router;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return DIContainerProvider(
      container: container,
      child: MaterialApp.router(
        title: config.displayName,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router.router,
        localizationsDelegates: [
          ...featureRegistry.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: config.supportedLocales,
      ),
    );
  }
}
