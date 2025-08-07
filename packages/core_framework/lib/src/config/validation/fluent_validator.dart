/// A fluent validation API optimized for Dart's cascade operator
///
/// This class is designed to work with Dart's cascade operator (..)
/// for readable and idiomatic validation code. Methods return void
/// since the cascade operator handles the chaining.
///
/// Example usage with cascade operator:
/// ```dart
/// final validator = FluentValidator()
///   ..validateRequired('NAME', name)
///   ..validateUrl('URL', url)
///   ..validateRange('PORT', port, min: 1, max: 65535);
/// ```
class FluentValidator {
  final List<String> _errors = [];

  /// Gets the list of validation errors
  List<String> get errors => List.unmodifiable(_errors);

  /// Whether the validation has any errors
  bool get hasErrors => _errors.isNotEmpty;

  /// Whether the validation passed (no errors)
  bool get isValid => _errors.isEmpty;

  /// Number of validation errors found
  int get errorCount => _errors.length;

  /// Adds a custom error message
  ///
  /// This method allows adding custom validation errors that don't fit
  /// into the standard validation methods.
  void addError(String message) {
    _errors.add(message);
  }

  /// Validates that a required field is not null or empty
  ///
  /// [field] The name of the field being validated (for error messages)
  /// [value] The value to validate
  void validateRequired(String field, String? value) {
    if (value == null || value.isEmpty) {
      _errors.add('$field is required and cannot be empty');
    }
  }

  /// Validates that a URL is properly formatted
  ///
  /// Checks that the URL:
  /// - Can be parsed by Uri.parse()
  /// - Has a valid scheme (http or https)
  ///
  /// [field] The name of the field being validated
  /// [value] The URL string to validate
  void validateUrl(String field, String? value) {
    if (value != null && value.isNotEmpty && !_isValidUrl(value)) {
      _errors.add(
        '$field must be a valid URL starting with http:// or https:// (got: $value)',
      );
    }
  }

  /// Validates that a value is one of the allowed values
  ///
  /// Performs case-insensitive comparison against the allowed values.
  ///
  /// [field] The name of the field being validated
  /// [value] The value to validate
  /// [allowedValues] List of allowed values
  void validateEnum(
    String field,
    String? value,
    List<String> allowedValues,
  ) {
    if (value != null &&
        value.isNotEmpty &&
        !allowedValues.contains(value.toLowerCase())) {
      _errors.add(
        '$field must be one of: ${allowedValues.join(', ')} (got: $value)',
      );
    }
  }

  /// Validates that a numeric value is within the specified range
  ///
  /// [field] The name of the field being validated
  /// [value] The numeric value to validate
  /// [min] Minimum allowed value (inclusive), null means no minimum
  /// [max] Maximum allowed value (inclusive), null means no maximum
  void validateRange(
    String field,
    int? value, {
    int? min,
    int? max,
  }) {
    if (value != null) {
      if (min != null && value < min) {
        _errors.add('$field must be at least $min (got: $value)');
      }
      if (max != null && value > max) {
        _errors.add('$field must not exceed $max (got: $value)');
      }
    }
  }

  /// Validates minimum length for an optional string field
  ///
  /// Only validates if the value is not null and not empty.
  /// This is useful for optional fields that have minimum requirements
  /// when they are provided.
  ///
  /// [field] The name of the field being validated
  /// [value] The optional string to validate
  /// [minLength] Minimum required length
  void validateOptionalMinLength(
    String field,
    String? value, {
    required int minLength,
  }) {
    if (value != null && value.isNotEmpty && value.length < minLength) {
      _errors.add(
        '$field, if provided, should be at least $minLength characters long',
      );
    }
  }

  /// Validates that a string matches a regular expression pattern
  ///
  /// [field] The name of the field being validated
  /// [value] The string to validate
  /// [pattern] The regular expression pattern to match
  /// [description] Human-readable description of the pattern
  void validatePattern(
    String field,
    String? value,
    RegExp pattern,
    String description,
  ) {
    if (value != null && value.isNotEmpty && !pattern.hasMatch(value)) {
      _errors.add('$field must match $description (got: $value)');
    }
  }

  /// Validates using a custom predicate function
  ///
  /// This method allows for complex, custom validation logic that doesn't
  /// fit into the standard validation methods.
  ///
  /// [field] The name of the field being validated
  /// [value] The value to validate
  /// [predicate] Function that returns true if the value is valid
  /// [errorMessage] Error message to use if validation fails
  void validateCustom(
    String field,
    dynamic value,
    bool Function(dynamic) predicate,
    String errorMessage,
  ) {
    if (!predicate(value)) {
      _errors.add('$field: $errorMessage');
    }
  }

  /// Internal helper to validate URL format
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Creates a formatted summary of all validation errors
  ///
  /// Useful for debugging or logging validation results.
  String formatErrorSummary() {
    if (isValid) {
      return 'Validation passed - no errors found';
    }

    final buffer = StringBuffer(
      'Validation failed with $errorCount error(s):\n',
    );
    for (var i = 0; i < _errors.length; i++) {
      buffer.writeln('${i + 1}. ${_errors[i]}');
    }
    return buffer.toString().trim();
  }

  /// Combines this validator with another validator
  ///
  /// Useful for combining validation results from different sources.
  /// The errors from the other validator are added to this validator.
  ///
  /// [other] Another validator whose errors should be combined
  void combineWith(FluentValidator other) {
    _errors.addAll(other._errors);
  }

  /// Clears all validation errors
  ///
  /// Useful for reusing the same validator instance.
  void clearErrors() {
    _errors.clear();
  }

  @override
  String toString() {
    return 'FluentValidator(isValid: $isValid, errorCount: $errorCount)';
  }
}
