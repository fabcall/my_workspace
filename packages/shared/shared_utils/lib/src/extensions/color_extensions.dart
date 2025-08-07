import 'dart:ui';

/// Extension that provides methods to manipulate color brightness.
///
/// These methods allow you to create darker or lighter variations of existing colors,
/// which is commonly used for hover states, shadows, or theme variations.
extension ColorExt on Color {
  /// Creates a darker version of the color by reducing its brightness.
  ///
  /// The [percent] parameter controls how much darker the color becomes:
  /// - 1% = slightly darker
  /// - 50% = significantly darker
  /// - 100% = completely black
  ///
  /// The alpha channel is preserved from the original color.
  ///
  /// @param percent The percentage to darken (1-100). Defaults to 10%.
  /// @returns A new [Color] instance that is darker than the original
  /// @throws AssertionError if percent is not between 1 and 100
  ///
  /// @example
  /// ```dart
  /// const blue = Color(0xFF2196F3);
  /// final darkBlue = blue.darken(20);        // 20% darker
  /// final slightlyDark = blue.darken();      // 10% darker (default)
  /// final veryDark = blue.darken(80);        // 80% darker
  ///
  /// // Usage in Flutter widgets
  /// Container(
  ///   color: Theme.of(context).primaryColor.darken(15),
  ///   child: Text('Darker background'),
  /// )
  /// ```
  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100, 'Percent must be between 1 and 100');
    final f = 1 - percent / 100;
    final alphaValue = (a * 255.0).round() & 0xff;
    final redValue = (r * 255.0).round() & 0xff;
    final greenValue = (g * 255.0).round() & 0xff;
    final blueValue = (b * 255.0).round() & 0xff;

    return Color.fromARGB(
      alphaValue,
      (redValue * f).round(),
      (greenValue * f).round(),
      (blueValue * f).round(),
    );
  }

  /// Creates a lighter version of the color by increasing its brightness.
  ///
  /// The [percent] parameter controls how much lighter the color becomes:
  /// - 1% = slightly lighter
  /// - 50% = significantly lighter
  /// - 100% = completely white
  ///
  /// The alpha channel is preserved from the original color.
  ///
  /// @param percent The percentage to lighten (1-100). Defaults to 10%.
  /// @returns A new [Color] instance that is lighter than the original
  /// @throws AssertionError if percent is not between 1 and 100
  ///
  /// @example
  /// ```dart
  /// const red = Color(0xFFE53E3E);
  /// final lightRed = red.lighten(30);        // 30% lighter
  /// final slightlyLight = red.lighten();     // 10% lighter (default)
  /// final veryLight = red.lighten(90);       // 90% lighter
  ///
  /// // Usage for hover effects
  /// Material(
  ///   color: isHovered
  ///     ? buttonColor.lighten(15)
  ///     : buttonColor,
  ///   child: Text('Hover me'),
  /// )
  /// ```
  Color lighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100, 'Percent must be between 1 and 100');
    final p = percent / 100;
    final alphaValue = (a * 255.0).round() & 0xff;
    final redValue = (r * 255.0).round() & 0xff;
    final greenValue = (g * 255.0).round() & 0xff;
    final blueValue = (b * 255.0).round() & 0xff;

    return Color.fromARGB(
      alphaValue,
      redValue + ((255 - redValue) * p).round(),
      greenValue + ((255 - greenValue) * p).round(),
      blueValue + ((255 - blueValue) * p).round(),
    );
  }
}
