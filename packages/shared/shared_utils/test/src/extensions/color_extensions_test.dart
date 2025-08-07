import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_utils/src/extensions/color_extensions.dart';

void main() {
  group('ColorExt', () {
    const testColor = Color(0xFF808080); // Gray

    test('darken reduces color brightness', () {
      final darker = testColor.darken(50);
      final originalRed = (testColor.r * 255.0).round() & 0xff;
      final darkerRed = (darker.r * 255.0).round() & 0xff;

      expect(darkerRed, lessThan(originalRed));
      expect((darker.a * 255.0).round() & 0xff,
          equals((testColor.a * 255.0).round() & 0xff)); // Alpha preserved
    });

    test('lighten increases color brightness', () {
      final lighter = testColor.lighten(50);
      final originalRed = (testColor.r * 255.0).round() & 0xff;
      final lighterRed = (lighter.r * 255.0).round() & 0xff;

      expect(lighterRed, greaterThan(originalRed));
      expect((lighter.a * 255.0).round() & 0xff,
          equals((testColor.a * 255.0).round() & 0xff)); // Alpha preserved
    });
  });
}
