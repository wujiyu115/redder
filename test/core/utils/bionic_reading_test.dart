import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/utils/bionic_reading.dart';

void main() {
  group('BionicReading.applyToText', () {
    test('bolds the fixation prefix of each word', () {
      // 5-letter words bold 2 chars; whitespace between words is preserved.
      expect(BionicReading.applyToText('Hello world'),
          '<b>He</b>llo <b>wo</b>rld');
    });

    test('preserves whitespace between words (regression)', () {
      // Regression: applyToText used String.split, which dropped separators
      // in Dart, collapsing all inter-word whitespace.
      final result = BionicReading.applyToText('a  b');
      expect(result.contains('  '), isTrue);
    });

    test('leaves empty input unchanged', () {
      expect(BionicReading.applyToText(''), '');
    });
  });

  group('BionicReading.applyToHtml', () {
    test('does not process content inside skip tags', () {
      const html = '<pre>keep this</pre>';
      final result = BionicReading.applyToHtml(html);
      expect(result, '<pre>keep this</pre>');
    });

    test('handles skip tags with mixed-case closing tags', () {
      // Regression: closing tag lookup used to be case-sensitive, so a
      // mixed-case closer left the skip region mis-parsed.
      const html = '<pre>keep this</PRE>after';
      final result = BionicReading.applyToHtml(html);
      // The content inside <pre>…</PRE> must be preserved verbatim.
      expect(result.contains('keep this'), isTrue);
      expect(result.contains('<b>kee</b>'), isFalse);
      // Text after the skip region is still processed ("after" → 2 bold chars).
      expect(result.contains('<b>af</b>ter'), isTrue);
    });

    test('processes text nodes but preserves tags', () {
      const html = '<p>Hello</p>';
      final result = BionicReading.applyToHtml(html);
      expect(result.startsWith('<p>'), isTrue);
      expect(result.contains('<b>He</b>llo'), isTrue);
    });
  });
}
