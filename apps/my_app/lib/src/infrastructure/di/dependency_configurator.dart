import 'package:core_framework/core_framework.dart';
import 'package:my_app/src/infrastructure/http/dio_http_client.dart';
import 'package:my_app/src/infrastructure/platform/app_info_service_impl.dart';

/// Application dependency configurator
class DependencyConfigurator {
  final DIContainer _container;
  final AppConfig _config;

  const DependencyConfigurator(this._container, this._config);

  /// Configures all dependencies with improved error handling and logging
  Future<void> configureAll() async {
    Logger.info(
      'Configuring dependencies for ${_config.environment}...',
      tag: 'Setup',
    );

    try {
      await configureAppInfo();
      Logger.info('App info configured', tag: 'Setup');

      configureNavigation();
      Logger.info('Navigation configured', tag: 'Setup');

      configureHttp();
      Logger.info('HTTP configured', tag: 'Setup');

      configureAnalytics();
      Logger.info('Analytics configured', tag: 'Setup');

      Logger.info('All dependencies configured successfully!', tag: 'Setup');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to configure dependencies',
        tag: 'Setup',
        error: e,
        data: {'stackTrace': stackTrace.toString()},
      );
      rethrow;
    }
  }

  /// Configure app info service
  Future<void> configureAppInfo() async {
    final appInfoService = AppInfoServiceImpl();
    await appInfoService.initialize();
    _container.registerSingleton<AppInfoService>(appInfoService);
  }

  /// Configure navigation with environment-based configuration
  void configureNavigation() {
    final redirectService = RedirectService(
      defaultDestination: _getDefaultDestination(),
      excludedRoutes: _getExcludedRoutes(),
    );

    _container.registerSingleton<RedirectService>(redirectService);

    Logger.info(
      'RedirectService configured',
      tag: 'Setup',
      data: {
        'defaultDestination': redirectService.defaultDestinationAfterLogin,
        'excludedRoutes': _getExcludedRoutes().length,
      },
    );
  }

  /// Configure HTTP client with improved logging
  void configureHttp() {
    final appInfoService = _container.get<AppInfoService>();

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': '${_config.displayName}/${appInfoService.getAppVersion()}',
      'X-App-Version': appInfoService.getAppVersion(),
      'X-Build-Number': appInfoService.getBuildNumber(),
      'X-Package-Name': appInfoService.getPackageName(),
      'X-Environment': _config.environment,
    };

    final httpClient = DioHttpClient(
      baseUrl: _config.baseUrl,
      enableLogging: _config.enableLogging,
      defaultTimeout: _config.httpTimeout,
      defaultHeaders: defaultHeaders,
    );

    _container.registerSingleton<HttpClient>(httpClient);

    Logger.info(
      'HTTP client configured',
      tag: 'Setup',
      data: {
        'baseUrl': _config.baseUrl,
        'timeout': _config.httpTimeout,
        'loggingEnabled': _config.enableLogging,
        'headersCount': defaultHeaders.length,
      },
    );
  }

  /// Configure analytics with improved control
  void configureAnalytics() {
    if (_config.enableAnalytics) {
      // TODO: Implement analytics
      Logger.info('Analytics enabled but not implemented yet', tag: 'Setup');
    } else {
      Logger.debug('Analytics disabled', tag: 'Setup');
    }
  }

  /// Helper: Default destination based on environment
  String _getDefaultDestination() {
    return switch (_config.environment) {
      'development' => '/dev-dashboard',
      'staging' => '/staging-home',
      'production' => '/dashboard',
      _ => '/home',
    };
  }

  /// Helper: Excluded routes based on environment
  List<String> _getExcludedRoutes() {
    final baseRoutes = ['/', '/login', '/register', '/forgot-password'];

    if (_config.environment == 'development') {
      return [...baseRoutes, '/debug', '/test', '/storybook'];
    }

    return baseRoutes;
  }
}
