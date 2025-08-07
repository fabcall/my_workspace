import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Extension that provides methods to format numeric values as currency
/// based on the current locale from BuildContext.
extension NumberExt on num {
  /// Formats the number as currency using the locale from [context].
  ///
  /// Uses currency codes (BRL, USD, EUR) by default.
  ///
  /// @example
  /// ```dart
  /// final price = 1234.56;
  /// Text(price.toCurrency(context));           // "BRL 1.234,56" (pt_BR) or "USD 1,234.56" (en_US)
  /// ```
  String toCurrency(
    BuildContext context, {
    String? symbol,
    int decimalDigits = 2,
    String? name,
  }) {
    final locale = Localizations.localeOf(context);

    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: symbol,
      decimalDigits: decimalDigits,
      name: name,
    );

    return formatter.format(this);
  }

  /// Formats the number as simple currency using the locale from [context].
  ///
  /// Uses currency symbols (R$, $, €) instead of currency codes.
  ///
  /// @example
  /// ```dart
  /// final price = 1234.56;
  /// Text(price.toSimpleCurrency(context));     // "R$ 1.234,56" (pt_BR) or "$1,234.56" (en_US)
  /// ```
  String toSimpleCurrency(
    BuildContext context, {
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context);

    final formatter = NumberFormat.simpleCurrency(
      locale: locale.toString(),
      decimalDigits: decimalDigits,
    );

    return formatter.format(this);
  }

  /// Formats the number as simple currency with custom locale.
  ///
  /// @param locale The locale string (e.g., 'pt_BR', 'en_US', 'fr_FR')
  /// @param decimalDigits Number of decimal places. Defaults to 2
  /// @returns A formatted string with currency symbol
  ///
  /// @example
  /// ```dart
  /// final price = 1234.56;
  ///
  /// price.toSimpleCurrencyWithLocale('pt_BR');       // "R$ 1.234,56"
  /// price.toSimpleCurrencyWithLocale('en_US');       // "$1,234.56"
  /// price.toSimpleCurrencyWithLocale('fr_FR');       // "€1 234,56"
  /// ```
  String toSimpleCurrencyWithLocale(
    String locale, {
    int decimalDigits = 2,
  }) {
    try {
      final formatter = NumberFormat.simpleCurrency(
        locale: locale,
        decimalDigits: decimalDigits,
      );

      return formatter.format(this);
    } catch (e) {
      // Fallback to default
      final formatter = NumberFormat.simpleCurrency(
        decimalDigits: decimalDigits,
      );

      return formatter.format(this);
    }
  }

  /// Formats the number as currency with custom locale string.
  ///
  /// Uses currency codes (BRL, USD, EUR) by default.
  ///
  /// @example
  /// ```dart
  /// final price = 1234.56;
  ///
  /// price.toCurrencyWithLocale('pt_BR');       // "BRL 1.234,56"
  /// price.toCurrencyWithLocale('en_US');       // "USD 1,234.56"
  /// ```
  String toCurrencyWithLocale(
    String locale, {
    String? symbol,
    int decimalDigits = 2,
    String? name,
  }) {
    try {
      final formatter = NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: decimalDigits,
        name: name,
      );

      return formatter.format(this);
    } catch (e) {
      // Fallback to default locale if specified locale is not supported
      final formatter = NumberFormat.currency(
        symbol: symbol ?? r'$',
        decimalDigits: decimalDigits,
        name: name,
      );

      return formatter.format(this);
    }
  }

  /// Formats the number as compact currency using the locale from [context].
  ///
  /// Uses currency symbols (R$, $, €) with compact notation for large values (1.2M, 1.5K).
  ///
  /// @example
  /// ```dart
  /// final price = 1234.56;
  /// Text(price.toCompactCurrency(context));    // "R$ 1,2K" or "$1.2K"
  ///
  /// final bigPrice = 1234567.89;
  /// Text(bigPrice.toCompactCurrency(context)); // "R$ 1,2M" or "$1.2M"
  /// ```
  String toCompactCurrency(
    BuildContext context, {
    String? symbol,
    String? name,
  }) {
    final locale = Localizations.localeOf(context);

    try {
      final formatter = NumberFormat.compactCurrency(
        locale: locale.toString(),
        symbol: symbol,
        name: name,
      );

      return formatter.format(this);
    } catch (e) {
      // Fallback for unsupported locales
      final formatter = NumberFormat.compactCurrency(
        symbol: symbol ?? r'$',
        name: name,
      );

      return formatter.format(this);
    }
  }

  /// Formats the number as compact currency with custom locale.
  ///
  /// @example
  /// ```dart
  /// final bigPrice = 1500000.0;
  /// bigPrice.toCompactCurrencyWithLocale('pt_BR'); // "R$ 1,5M"
  /// bigPrice.toCompactCurrencyWithLocale('en_US'); // "$1.5M"
  /// ```
  String toCompactCurrencyWithLocale(
    String locale, {
    String? symbol,
    String? name,
  }) {
    try {
      final formatter = NumberFormat.compactCurrency(
        locale: locale,
        symbol: symbol,
        name: name,
      );

      return formatter.format(this);
    } catch (e) {
      // Fallback
      final formatter = NumberFormat.compactCurrency(
        symbol: symbol ?? r'$',
        name: name,
      );

      return formatter.format(this);
    }
  }

  /// Formats the number as a percentage using the locale from [context].
  ///
  /// The number should be in decimal format (e.g., 0.15 for 15%).
  ///
  /// @example
  /// ```dart
  /// final rate = 0.1534;
  /// Text(rate.toPercentage(context));              // "15,3%" (pt_BR) or "15.3%" (en_US)
  /// ```
  String toPercentage(
    BuildContext context, {
    int decimalDigits = 1,
  }) {
    final locale = Localizations.localeOf(context);

    final formatter = NumberFormat.percentPattern(locale.toString())
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;

    return formatter.format(this);
  }

  /// Formats the number as a percentage with custom locale string.
  ///
  /// @example
  /// ```dart
  /// final rate = 0.1534;
  /// rate.toPercentageWithLocale('pt_BR');          // "15,3%"
  /// rate.toPercentageWithLocale('en_US');          // "15.3%"
  /// ```
  String toPercentageWithLocale(
    String locale, {
    int decimalDigits = 1,
  }) {
    try {
      final formatter = NumberFormat.percentPattern(locale)
        ..minimumFractionDigits = decimalDigits
        ..maximumFractionDigits = decimalDigits;

      return formatter.format(this);
    } catch (e) {
      // Fallback to simple format if locale is not supported
      final percentage = (this * 100).toStringAsFixed(decimalDigits);
      return '$percentage%';
    }
  }
}
