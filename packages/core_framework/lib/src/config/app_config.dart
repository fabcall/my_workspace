import 'package:core_framework/src/config/environment_variables.dart';
import 'package:core_framework/src/config/validation/app_config_validator.dart';
import 'package:flutter/widgets.dart';

/// Main application configuration class
///
/// This class provides a centralized way to access all application configuration
/// values loaded from environment variables. It includes comprehensive validation
/// to ensure all required values are present and valid.
///
/// Usage:
/// ```dart
/// final config = AppConfig.fromEnvironment();
/// print('Running in ${config.environment} mode');
/// print('API base URL: ${config.baseUrl}');
/// ```
@immutable
class AppConfig {
  final String _displayName;
  final String _baseUrl;
  final String _environment;
  final bool _enableLogging;
  final bool _enableCrashReporting;
  final List<Locale> _supportedLocales;
  final String _initialRoute;
  final String? _apiKey;
  final int _httpTimeout;
  final bool _enableAnalytics;
  final bool _enableHttpRetry;
  final String? _sentryDsn;

  const AppConfig._({
    required String displayName,
    required String baseUrl,
    required String environment,
    required bool enableLogging,
    required bool enableCrashReporting,
    required List<Locale> supportedLocales,
    required String initialRoute,
    String? apiKey,
    required int httpTimeout,
    required bool enableAnalytics,
    required bool enableHttpRetry,
    String? sentryDsn,
  }) : _displayName = displayName,
       _baseUrl = baseUrl,
       _environment = environment,
       _enableLogging = enableLogging,
       _enableCrashReporting = enableCrashReporting,
       _supportedLocales = supportedLocales,
       _initialRoute = initialRoute,
       _apiKey = apiKey,
       _httpTimeout = httpTimeout,
       _enableAnalytics = enableAnalytics,
       _enableHttpRetry = enableHttpRetry,
       _sentryDsn = sentryDsn;

  /// Creates an AppConfig instance from environment variables
  ///
  /// This factory method collects all environment variables, validates them,
  /// and creates a properly configured AppConfig instance.
  ///
  /// Throws [AppConfigException] if any required configuration is missing
  /// or invalid.
  ///
  /// Environment variables expected:
  /// - DISPLAY_NAME: Application display name (required)
  /// - BASE_URL: API base URL (required, must be valid HTTP/HTTPS URL)
  /// - ENVIRONMENT: Runtime environment (required, must be: development, staging, production)
  /// - ENABLE_LOGGING: Enable application logging (optional, defaults to false)
  /// - ENABLE_CRASH_REPORTING: Enable crash reporting (optional, defaults to false)
  /// - SUPPORTED_LOCALES: Comma-separated locale codes (optional, defaults to 'en')
  /// - INITIAL_ROUTE: Initial application route (optional, defaults to '/')
  /// - API_KEY: API authentication key (optional, min 10 chars if provided)
  /// - HTTP_TIMEOUT: HTTP request timeout in milliseconds (optional, defaults to 30000)
  /// - ENABLE_ANALYTICS: Enable analytics tracking (optional, defaults to false)
  /// - ENABLE_HTTP_RETRY: Enable automatic HTTP retry (optional, defaults to true)
  /// - SENTRY_DSN: Sentry error tracking DSN (optional)
  factory AppConfig.fromEnvironment() {
    // Collect all environment variables
    final envVars = EnvironmentVariables.collect();

    // Validate configuration
    final validationResult = AppConfigValidator.validate(envVars);

    // Throw exception if validation fails
    if (validationResult.hasErrors) {
      throw AppConfigException(validationResult.formatErrors());
    }

    // Create validated configuration
    return AppConfig._(
      displayName: envVars.displayName,
      baseUrl: envVars.baseUrl,
      environment: envVars.environment,
      enableLogging: envVars.enableLogging,
      enableCrashReporting: envVars.enableCrashReporting,
      supportedLocales: envVars.supportedLocales,
      initialRoute: envVars.initialRoute,
      apiKey: envVars.apiKey,
      httpTimeout: envVars.httpTimeout,
      enableAnalytics: envVars.enableAnalytics,
      enableHttpRetry: envVars.enableHttpRetry,
      sentryDsn: envVars.sentryDsn,
    );
  }

  // Public configuration accessors

  /// Application display name
  String get displayName => _displayName;

  /// Base URL for API requests
  String get baseUrl => _baseUrl;

  /// Current runtime environment (development, staging, production)
  String get environment => _environment;

  /// Whether application logging is enabled
  bool get enableLogging => _enableLogging;

  /// Whether crash reporting is enabled
  bool get enableCrashReporting => _enableCrashReporting;

  /// List of supported locales for the application
  List<Locale> get supportedLocales => _supportedLocales;

  /// Initial route when the application starts
  String get initialRoute => _initialRoute;

  /// API key for authentication (nullable)
  String? get apiKey => _apiKey;

  /// HTTP request timeout in milliseconds
  int get httpTimeout => _httpTimeout;

  /// Whether analytics tracking is enabled
  bool get enableAnalytics => _enableAnalytics;

  /// Whether automatic HTTP retry is enabled
  bool get enableHttpRetry => _enableHttpRetry;

  /// Sentry DSN for error tracking (nullable)
  String? get sentryDsn => _sentryDsn;

  /// Convenience getters for common environment checks
  bool get isDevelopment => _environment.toLowerCase() == 'development';
  bool get isStaging => _environment.toLowerCase() == 'staging';
  bool get isProduction => _environment.toLowerCase() == 'production';

  @override
  String toString() => 'AppConfig($_displayName, $_environment, $_baseUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfig &&
          runtimeType == other.runtimeType &&
          _displayName == other._displayName &&
          _baseUrl == other._baseUrl &&
          _environment == other._environment;

  @override
  int get hashCode =>
      _displayName.hashCode ^ _baseUrl.hashCode ^ _environment.hashCode;
}

/// Exception thrown when application configuration is invalid
@immutable
class AppConfigException implements Exception {
  /// Human-readable error message describing the configuration problem
  final String message;

  const AppConfigException(this.message);

  @override
  String toString() => 'AppConfigException: $message';
}
