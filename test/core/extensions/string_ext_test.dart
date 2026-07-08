import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/extensions/string_ext.dart';

void main() {
  group('StringExt.truncate', () {
    test('returns string unchanged when short enough', () {
      expect('hello'.truncate(10), 'hello');
    });

    test('truncates and appends ellipsis', () {
      expect('hello world'.truncate(5), 'hello…');
    });

    test('does not split a surrogate pair', () {
      // '😀' is a surrogate pair (2 UTF-16 code units). Truncating at an odd
      // boundary must not leave a lone (broken) surrogate.
      final s = 'ab😀cd';
      final result = s.truncate(3); // would land between the surrogate halves
      // The last kept character must be the complete 'b', not half an emoji.
      expect(result, 'ab…');
      // Result (minus ellipsis) must be valid UTF-16 (no lone surrogate).
      final body = result.substring(0, result.length - 1);
      for (final unit in body.codeUnits) {
        expect(unit >= 0xD800 && unit <= 0xDBFF, isFalse,
            reason: 'lone high surrogate leaked into truncated output');
      }
    });
  });

  group('StringExt.stripHtml', () {
    test('removes tags', () {
      expect('<p>Hello <b>world</b></p>'.stripHtml, 'Hello world');
    });
  });

  group('StringExt.normalizeWhitespace', () {
    test('collapses runs of whitespace and trims', () {
      expect('  a   b\n\tc  '.normalizeWhitespace, 'a b c');
    });
  });

  group('StringExt.isValidEmail', () {
    test('accepts a valid address', () {
      expect('user@example.com'.isValidEmail, isTrue);
    });

    test('rejects an invalid address', () {
      expect('not-an-email'.isValidEmail, isFalse);
    });
  });

  group('StringExt.isValidUrl', () {
    test('accepts http/https', () {
      expect('https://example.com'.isValidUrl, isTrue);
    });

    test('rejects missing scheme', () {
      expect('example.com'.isValidUrl, isFalse);
    });
  });
}
