import 'package:flutter/widgets.dart';

/// Internal class responsible for collecting and parsing environment variables
///
/// This class acts as a data transfer object that reads all environment variables
/// using Flutter's `String.fromEnvironment()` and related methods, with appropriate
/// defaults and type conversions.
class EnvironmentVariables {
  final String displayName;
  final String baseUrl;
  final String environment;
  final bool enableLogging;
  final bool enableCrashReporting;
  final List<Locale> supportedLocales;
  final String initialRoute;
  final String? apiKey;
  final int httpTimeout;
  final bool enableAnalytics;
  final bool enableHttpRetry;
  final String? sentryDsn;

  const EnvironmentVariables._({
    required this.displayName,
    required this.baseUrl,
    required this.environment,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.supportedLocales,
    required this.initialRoute,
    this.apiKey,
    required this.httpTimeout,
    required this.enableAnalytics,
    required this.enableHttpRetry,
    this.sentryDsn,
  });

  /// Collects all environment variables with appropriate defaults and type conversion
  ///
  /// This method reads from Flutter's compile-time environment variables system.
  /// Variables should be provided via --dart-define or --dart-define-from-file.
  static EnvironmentVariables collect() {
    return EnvironmentVariables._(
      // Required string variables
      displayName: const String.fromEnvironment('DISPLAY_NAME'),
      baseUrl: const String.fromEnvironment('BASE_URL'),
      environment: const String.fromEnvironment('ENVIRONMENT'),

      // Boolean variables with defaults
      enableLogging: const bool.fromEnvironment('ENABLE_LOGGING'),
      enableCrashReporting: const bool.fromEnvironment(
        'ENABLE_CRASH_REPORTING',
      ),
      enableAnalytics: const bool.fromEnvironment('ENABLE_ANALYTICS'),
      enableHttpRetry: const bool.fromEnvironment(
        'ENABLE_HTTP_RETRY',
        defaultValue: true,
      ),

      // String variables with defaults
      initialRoute: const String.fromEnvironment(
        'INITIAL_ROUTE',
        defaultValue: '/',
      ),

      // Integer variables with defaults
      httpTimeout: const int.fromEnvironment(
        'HTTP_TIMEOUT',
        defaultValue: 30000,
      ),

      // Optional string variables (nullable)
      apiKey: _parseOptionalString(const String.fromEnvironment('API_KEY')),
      sentryDsn: _parseOptionalString(
        const String.fromEnvironment('SENTRY_DSN'),
      ),

      // Complex parsing
      supportedLocales: _parseLocales(
        const String.fromEnvironment('SUPPORTED_LOCALES', defaultValue: 'en'),
      ),
    );
  }

  /// Parses comma-separated locale string into List<Locale>
  ///
  /// Expected format: "en,pt_BR,es_ES"
  /// Returns: [Locale('en'), Locale('pt', 'BR'), Locale('es', 'ES')]
  static List<Locale> _parseLocales(String localesStr) {
    return localesStr
        .split(',')
        .map((locale) => locale.trim())
        .where((locale) => locale.isNotEmpty)
        .map(_parseLocale)
        .toList();
  }

  /// Parses a single locale string into a Locale object
  ///
  /// Supports formats:
  /// - "en" -> Locale('en')
  /// - "en_US" -> Locale('en', 'US')
  /// - "pt_BR" -> Locale('pt', 'BR')
  static Locale _parseLocale(String localeStr) {
    final parts = localeStr.split('_');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }

  /// Converts empty string to null for optional string fields
  ///
  /// This is necessary because `String.fromEnvironment()` returns an empty string
  /// when the environment variable is not set, but we want null for optional fields.
  static String? _parseOptionalString(String value) {
    return value.isEmpty ? null : value;
  }

  @override
  String toString() {
    return 'EnvironmentVariables('
        'displayName: $displayName, '
        'environment: $environment, '
        'baseUrl: $baseUrl, '
        'enableLogging: $enableLogging, '
        'supportedLocales: ${supportedLocales.length} locales'
        ')';
  }
}
