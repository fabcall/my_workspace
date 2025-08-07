import 'package:core_framework/src/config/environment_variables.dart';
import 'package:core_framework/src/config/validation/fluent_validator.dart';
import 'package:core_framework/src/config/validation/validation_result.dart';

/// Main validator for application configuration
///
/// This class orchestrates the validation of all environment variables
/// collected by [EnvironmentVariables]. It uses a fluent validation API
/// to build readable and maintainable validation rules.
class AppConfigValidator {
  /// Validates all environment variables and returns a validation result
  ///
  /// This method applies all validation rules to the provided environment
  /// variables and collects any validation errors into a [ValidationResult].
  ///
  /// The validation includes:
  /// - Required field validation
  /// - URL format validation
  /// - Environment enum validation
  /// - Range validation for numeric fields
  /// - Optional field validation
  ///
  /// [envVars] The environment variables to validate
  /// Returns a [ValidationResult] containing any validation errors
  static ValidationResult validate(EnvironmentVariables envVars) {
    final validator = FluentValidator()
      // Required string fields
      ..validateRequired('DISPLAY_NAME', envVars.displayName)
      ..validateRequired('ENVIRONMENT', envVars.environment)
      // URL validation (both required and format)
      ..validateRequired('BASE_URL', envVars.baseUrl)
      ..validateUrl('BASE_URL', envVars.baseUrl)
      // Environment enum validation
      ..validateEnum(
        'ENVIRONMENT',
        envVars.environment,
        ['development', 'staging', 'production'],
      )
      // Numeric range validations
      ..validateRange(
        'HTTP_TIMEOUT',
        envVars.httpTimeout,
        min: 1,
        max: 300000,
      )
      // Optional field validations
      ..validateOptionalMinLength(
        'API_KEY',
        envVars.apiKey,
        minLength: 10,
      );

    // Conditional validations
    if (envVars.enableCrashReporting && envVars.sentryDsn == null) {
      validator.addError(
        'SENTRY_DSN is required when ENABLE_CRASH_REPORTING is true',
      );
    }

    return ValidationResult(validator.errors);
  }
}
