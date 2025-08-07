/// Extension that provides methods to trim specific patterns from strings.
extension StringExt on String {
  /// Removes all occurrences of the specified [pattern] from the beginning of the string.
  ///
  /// Returns the original string if:
  /// - The string is empty
  /// - The pattern is empty
  /// - The pattern is longer than the string
  ///
  /// @param pattern The string pattern to remove from the beginning
  /// @returns A new string with the pattern removed from the start
  ///
  /// @example
  /// ```dart
  /// '###hello'.trimCharLeft('#');    // Returns 'hello'
  /// '---test---'.trimCharLeft('-');  // Returns 'test---'
  /// 'hello'.trimCharLeft('xyz');     // Returns 'hello' (no change)
  /// ''.trimCharLeft('#');            // Returns '' (empty string)
  /// ```
  String trimCharLeft(String pattern) {
    if (isEmpty || pattern.isEmpty || pattern.length > length) return this;
    var tmp = this;
    while (tmp.startsWith(pattern)) {
      tmp = tmp.substring(
          pattern.length); // Fixed: was using 'this' instead of 'tmp'
    }
    return tmp;
  }

  /// Removes all occurrences of the specified [pattern] from the end of the string.
  ///
  /// Returns the original string if:
  /// - The string is empty
  /// - The pattern is empty
  /// - The pattern is longer than the string
  ///
  /// @param pattern The string pattern to remove from the end
  /// @returns A new string with the pattern removed from the end
  ///
  /// @example
  /// ```dart
  /// 'hello###'.trimCharRight('#');   // Returns 'hello'
  /// '---test---'.trimCharRight('-'); // Returns '---test'
  /// 'hello'.trimCharRight('xyz');    // Returns 'hello' (no change)
  /// ''.trimCharRight('#');           // Returns '' (empty string)
  /// ```
  String trimCharRight(String pattern) {
    if (isEmpty || pattern.isEmpty || pattern.length > length) return this;
    var tmp = this;
    while (tmp.endsWith(pattern)) {
      tmp = tmp.substring(
          0,
          tmp.length -
              pattern.length); // Fixed: was using 'this' instead of 'tmp'
    }
    return tmp;
  }

  /// Removes all occurrences of the specified [pattern] from both the beginning and end of the string.
  ///
  /// This method combines [trimCharLeft] and [trimCharRight] operations.
  /// First removes the pattern from the left side, then from the right side.
  ///
  /// @param pattern The string pattern to remove from both ends
  /// @returns A new string with the pattern removed from both start and end
  ///
  /// @example
  /// ```dart
  /// '###hello###'.trimChar('#');     // Returns 'hello'
  /// '---test---'.trimChar('-');      // Returns 'test'
  /// '###hello---'.trimChar('#');     // Returns 'hello---' (only left side removed)
  /// 'hello'.trimChar('xyz');         // Returns 'hello' (no change)
  /// ''.trimChar('#');                // Returns '' (empty string)
  /// ```
  String trimChar(String pattern) {
    return trimCharLeft(pattern).trimCharRight(pattern);
  }
}
