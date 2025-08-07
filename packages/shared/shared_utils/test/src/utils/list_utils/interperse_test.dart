import 'package:flutter_test/flutter_test.dart';
import 'package:shared_utils/src/utils/list_utils/intersperse.dart';

void main() {
  group('intersperse', () {
    test('returns empty iterable when input is empty', () {
      final result = intersperse(2, <int>[]);
      expect(result, isEmpty);
      expect(result.toList(), equals(<int>[]));
    });

    test('returns single element when input has one element', () {
      final result = intersperse(2, [0]);
      expect(result.toList(), equals([0]));
    });

    test('intersperses element between two elements', () {
      final result = intersperse(2, [0, 0]);
      expect(result.toList(), equals([0, 2, 0]));
    });

    test('intersperses element between multiple elements', () {
      final result = intersperse(2, [1, 3, 5, 7]);
      expect(result.toList(), equals([1, 2, 3, 2, 5, 2, 7]));
    });

    test('works with string elements', () {
      final result = intersperse('-', ['a', 'b', 'c']);
      expect(result.toList(), equals(['a', '-', 'b', '-', 'c']));
    });

    test('works with different types', () {
      final result = intersperse(null, ['hello', 'world']);
      expect(result.toList(), equals(['hello', null, 'world']));
    });

    test('works with complex objects', () {
      final list = [
        {'name': 'John'},
        {'name': 'Jane'}
      ];
      final separator = {'separator': true};
      final result = intersperse(separator, list);

      expect(
          result.toList(),
          equals([
            {'name': 'John'},
            {'separator': true},
            {'name': 'Jane'}
          ]));
    });

    test('preserves original iterable when converted back', () {
      final original = [1, 2, 3, 4, 5];
      final result = intersperse(0, original);
      final resultList = result.toList();

      expect(resultList, equals([1, 0, 2, 0, 3, 0, 4, 0, 5]));
      expect(original, equals([1, 2, 3, 4, 5])); // Original unchanged
    });

    test('works with Set input', () {
      final set = {1, 2, 3};
      final result = intersperse(0, set);
      final resultList = result.toList();

      expect(resultList.length, equals(5)); // 3 elements + 2 separators
      expect(resultList.where((x) => x == 0).length, equals(2));
    });

    test('works with lazy iterables', () {
      final lazyIterable = [1, 2, 3].where((x) => x.isOdd);
      final result = intersperse(0, lazyIterable);

      expect(result.toList(), equals([1, 0, 3]));
    });

    test('intersperse element can be same as list elements', () {
      final result = intersperse(1, [1, 1, 1]);
      expect(result.toList(), equals([1, 1, 1, 1, 1]));
    });
  });

  group('intersperseOuter', () {
    test('returns empty iterable when input is empty', () {
      final result = intersperseOuter(2, <int>[]);
      expect(result, isEmpty);
      expect(result.toList(), equals(<int>[]));
    });

    test('adds element at bounds when input has one element', () {
      final result = intersperseOuter(2, [0]);
      expect(result.toList(), equals([2, 0, 2]));
    });

    test('adds element at bounds and between elements for two elements', () {
      final result = intersperseOuter(2, [0, 0]);
      expect(result.toList(), equals([2, 0, 2, 0, 2]));
    });

    test('adds element at bounds and between multiple elements', () {
      final result = intersperseOuter(2, [1, 3, 5, 7]);
      expect(result.toList(), equals([2, 1, 2, 3, 2, 5, 2, 7, 2]));
    });

    test('works with string elements', () {
      final result = intersperseOuter('|', ['a', 'b', 'c']);
      expect(result.toList(), equals(['|', 'a', '|', 'b', '|', 'c', '|']));
    });

    test('works with different types', () {
      final result = intersperseOuter(null, ['hello', 'world']);
      expect(result.toList(), equals([null, 'hello', null, 'world', null]));
    });

    test('works with complex objects', () {
      final list = [
        {'name': 'John'},
        {'name': 'Jane'}
      ];
      final separator = {'separator': true};
      final result = intersperseOuter(separator, list);

      expect(
          result.toList(),
          equals([
            {'separator': true},
            {'name': 'John'},
            {'separator': true},
            {'name': 'Jane'},
            {'separator': true}
          ]));
    });

    test('preserves original iterable when converted back', () {
      final original = [1, 2, 3];
      final result = intersperseOuter(0, original);
      final resultList = result.toList();

      expect(resultList, equals([0, 1, 0, 2, 0, 3, 0]));
      expect(original, equals([1, 2, 3])); // Original unchanged
    });

    test('works with Set input', () {
      final set = {1, 2, 3};
      final result = intersperseOuter(0, set);
      final resultList = result.toList();

      expect(resultList.length, equals(7)); // 3 elements + 4 separators
      expect(resultList.first, equals(0)); // Starts with separator
      expect(resultList.last, equals(0)); // Ends with separator
      expect(resultList.where((x) => x == 0).length, equals(4));
    });

    test('works with lazy iterables', () {
      final lazyIterable = [1, 2, 3, 4].where((x) => x.isOdd);
      final result = intersperseOuter(0, lazyIterable);

      expect(result.toList(), equals([0, 1, 0, 3, 0]));
    });

    test('outer element can be same as list elements', () {
      final result = intersperseOuter(1, [1, 1]);
      expect(result.toList(), equals([1, 1, 1, 1, 1]));
    });

    test('single element result has correct bounds', () {
      final result = intersperseOuter('X', ['Y']);
      final resultList = result.toList();

      expect(resultList, equals(['X', 'Y', 'X']));
      expect(resultList.first, equals('X'));
      expect(resultList.last, equals('X'));
    });
  });

  group('intersperse vs intersperseOuter comparison', () {
    test(
        'intersperse has 2 fewer elements than intersperseOuter for non-empty lists',
        () {
      final list = [1, 2, 3, 4];
      final inner = intersperse(0, list).toList();
      final outer = intersperseOuter(0, list).toList();

      expect(outer.length - inner.length, equals(2));
      expect(inner, equals([1, 0, 2, 0, 3, 0, 4]));
      expect(outer, equals([0, 1, 0, 2, 0, 3, 0, 4, 0]));
    });

    test('both return empty for empty input', () {
      final inner = intersperse(0, <int>[]).toList();
      final outer = intersperseOuter(0, <int>[]).toList();

      expect(inner, isEmpty);
      expect(outer, isEmpty);
      expect(inner, equals(outer));
    });

    test('intersperseOuter adds bounds to intersperse result', () {
      final list = [1, 2];
      final inner = intersperse(0, list).toList();
      final outer = intersperseOuter(0, list).toList();

      expect(inner, equals([1, 0, 2]));
      expect(outer, equals([0, 1, 0, 2, 0]));

      // outer should be like adding bounds to inner
      expect(outer, equals([0] + inner + [0]));
    });
  });

  group('Edge cases and performance', () {
    test('works with very large iterables', () {
      final largeList = List.generate(1000, (i) => i);
      final result = intersperse(-1, largeList);
      final resultList = result.toList();

      expect(resultList.length, equals(1999)); // 1000 + 999 separators
      expect(resultList.where((x) => x == -1).length, equals(999));
    });

    test('returns iterable that can be used multiple times', () {
      final list = [1, 2, 3];
      final result = intersperse(0, list);

      // First iteration
      final firstUse = result.toList();
      expect(firstUse, equals([1, 0, 2, 0, 3]));

      // Second iteration should give same result
      final secondUse = result.toList();
      expect(secondUse, equals([1, 0, 2, 0, 3]));

      expect(firstUse, equals(secondUse));
    });

    test('handles null elements correctly', () {
      final listWithNulls = [1, null, 3, null];
      final result = intersperse(0, listWithNulls);

      expect(result.toList(), equals([1, 0, null, 0, 3, 0, null]));
    });

    test('generic type is preserved', () {
      final stringResult = intersperse('x', ['a', 'b']);
      final intResult = intersperse(0, [1, 2]);

      expect(stringResult, isA<Iterable<String>>());
      expect(intResult, isA<Iterable<int>>());
    });

    test('works with iterables that implement specific behavior', () {
      // Test with a custom iterable that counts iterations
      var iterationCount = 0;
      final customIterable = [1, 2, 3].map((x) {
        iterationCount++;
        return x;
      });

      final result = intersperse(0, customIterable);
      final resultList = result.toList();

      expect(resultList, equals([1, 0, 2, 0, 3]));
      expect(iterationCount,
          equals(3)); // Should iterate through all elements once
    });
  });

  group('Practical use cases', () {
    test('joining words with spaces', () {
      final words = ['Hello', 'beautiful', 'world'];
      final result = intersperse(' ', words).join();
      expect(result, equals('Hello beautiful world'));
    });

    test('creating breadcrumb navigation', () {
      final breadcrumbs = ['Home', 'Products', 'Electronics', 'Phones'];
      final result = intersperse(' > ', breadcrumbs).join();
      expect(result, equals('Home > Products > Electronics > Phones'));
    });

    test('adding dividers between UI elements', () {
      final items = ['Item1', 'Item2', 'Item3'];
      final withDividers = intersperseOuter('|', items).toList();
      expect(withDividers,
          equals(['|', 'Item1', '|', 'Item2', '|', 'Item3', '|']));
    });

    test('formatting lists with commas', () {
      final names = ['Alice', 'Bob', 'Charlie'];
      final withCommas = intersperse(', ', names).join();
      expect(withCommas, equals('Alice, Bob, Charlie'));
    });

    test('creating separators for Flutter widgets', () {
      final widgets = ['Widget1', 'Widget2', 'Widget3'];
      final withSeparators = intersperse('Divider', widgets).toList();
      expect(withSeparators,
          equals(['Widget1', 'Divider', 'Widget2', 'Divider', 'Widget3']));
    });

    test('adding padding between elements', () {
      final elements = [1, 2, 3];
      final withPadding = intersperseOuter(0, elements).toList();
      expect(withPadding, equals([0, 1, 0, 2, 0, 3, 0]));
    });
  });
}
