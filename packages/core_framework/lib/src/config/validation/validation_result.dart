import 'package:flutter/foundation.dart';

/// Result of a validation operation containing any errors found
///
/// This class encapsulates the result of validating configuration values,
/// providing both a simple boolean check for validity and detailed error
/// information for debugging and user feedback.
@immutable
class ValidationResult {
  final List<String> _errors;

  /// Creates a validation result with the specified errors
  ///
  /// [errors] List of validation error messages. Empty list indicates success.
  const ValidationResult(this._errors);

  /// Whether the validation passed (no errors found)
  bool get isValid => _errors.isEmpty;

  /// Whether the validation failed (has errors)
  bool get hasErrors => _errors.isNotEmpty;

  /// List of validation error messages
  ///
  /// Returns an unmodifiable view of the error list to prevent external modification.
  List<String> get errors => List.unmodifiable(_errors);

  /// Number of validation errors found
  int get errorCount => _errors.length;

  /// Formats all validation errors into a human-readable string
  ///
  /// Creates a well-formatted error message suitable for logging or
  /// displaying to users during application startup failures.
  ///
  /// Returns a formatted string containing:
  /// - Header indicating configuration errors were found
  /// - Bulleted list of all error messages
  /// - Footer with troubleshooting hint
  ///
  /// Example output:
  /// ```
  /// ❌ Configuration errors found:
  ///
  /// • DISPLAY_NAME is required and cannot be empty
  /// • BASE_URL must be a valid URL starting with http:// or https://
  ///
  /// 💡 Check your environment variables and --dart-define-from-file command.
  /// ```
  String formatErrors() {
    if (isValid) {
      return 'No validation errors';
    }

    final buffer = StringBuffer()
      ..writeln('❌ Configuration errors found:')
      ..writeln();

    for (final error in _errors) {
      buffer.writeln('• $error');
    }

    buffer
      ..writeln()
      ..writeln(
        '💡 Check your environment variables and --dart-define-from-file command.',
      );

    return buffer.toString().trim();
  }

  /// Returns the first error message, or null if no errors
  ///
  /// Useful when you only need to display a single error message
  /// and want to show the most important (first) one.
  String? get firstError => _errors.isNotEmpty ? _errors.first : null;

  /// Combines this validation result with another one
  ///
  /// Creates a new ValidationResult that contains errors from both
  /// this result and the [other] result. Useful for combining
  /// validation results from different validators.
  ///
  /// [other] Another validation result to combine with this one
  /// Returns a new ValidationResult with combined errors
  ValidationResult combine(ValidationResult other) {
    return ValidationResult([..._errors, ...other._errors]);
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errorCount: $errorCount)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          _listEquals(_errors, other._errors);

  @override
  int get hashCode =>
      _errors.fold(0, (prev, element) => prev ^ element.hashCode);

  /// Helper method to compare two lists for equality
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
