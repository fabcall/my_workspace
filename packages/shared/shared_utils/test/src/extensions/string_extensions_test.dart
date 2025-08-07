import 'package:flutter_test/flutter_test.dart';
import 'package:shared_utils/shared_utils.dart';

void main() {
  group('StringExt', () {
    test('trimCharLeft removes pattern from start', () {
      expect('###hello'.trimCharLeft('#'), equals('hello'));
      expect('---test---'.trimCharLeft('-'), equals('test---'));
    });

    test('trimCharRight removes pattern from end', () {
      expect('hello###'.trimCharRight('#'), equals('hello'));
      expect('---test---'.trimCharRight('-'), equals('---test'));
    });

    test('trimChar removes pattern from both ends', () {
      expect('###hello###'.trimChar('#'), equals('hello'));
      expect('---test---'.trimChar('-'), equals('test'));
    });
  });
}
