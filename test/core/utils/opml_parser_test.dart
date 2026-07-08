import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/utils/opml_parser.dart';

void main() {
  group('OpmlParser.parse', () {
    test('parses a flat list of feed outlines', () {
      const opml = '''
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <body>
    <outline text="Feed A" title="Feed A" type="rss"
             xmlUrl="https://a.com/feed" htmlUrl="https://a.com"/>
    <outline text="Feed B" xmlUrl="https://b.com/feed"/>
  </body>
</opml>''';

      final outlines = OpmlParser.parse(opml);

      expect(outlines, hasLength(2));
      expect(outlines[0].title, 'Feed A');
      expect(outlines[0].feedUrl, 'https://a.com/feed');
      expect(outlines[0].siteUrl, 'https://a.com');
      expect(outlines[0].isFolder, isFalse);
      expect(outlines[1].feedUrl, 'https://b.com/feed');
    });

    test('parses nested folders', () {
      const opml = '''
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <body>
    <outline text="News" title="News">
      <outline text="Feed A" xmlUrl="https://a.com/feed"/>
    </outline>
  </body>
</opml>''';

      final outlines = OpmlParser.parse(opml);

      expect(outlines, hasLength(1));
      expect(outlines[0].isFolder, isTrue);
      expect(outlines[0].title, 'News');
      expect(outlines[0].children, hasLength(1));
      expect(outlines[0].children[0].feedUrl, 'https://a.com/feed');
    });

    test('returns empty list for malformed XML instead of throwing', () {
      const malformed = '<opml><body><outline xmlUrl="a"></body>'; // unclosed

      expect(OpmlParser.parse(malformed), isEmpty);
    });

    test('returns empty list when no body element', () {
      const noBody = '<?xml version="1.0"?><opml version="2.0"></opml>';

      expect(OpmlParser.parse(noBody), isEmpty);
    });

    test('flatten produces feeds with their folder name', () {
      final outlines = [
        OpmlOutline(
          title: 'News',
          isFolder: true,
          children: const [
            OpmlOutline(title: 'A', feedUrl: 'https://a.com/feed'),
          ],
        ),
        const OpmlOutline(title: 'B', feedUrl: 'https://b.com/feed'),
      ];

      final flat = OpmlParser.flatten(outlines);

      expect(flat, hasLength(2));
      expect(flat[0].feedUrl, 'https://a.com/feed');
      expect(flat[0].folderName, 'News');
      expect(flat[1].feedUrl, 'https://b.com/feed');
      expect(flat[1].folderName, isNull);
    });
  });

  group('OpmlParser round-trip', () {
    test('generate then parse preserves feeds', () {
      final generated = OpmlParser.generate(outlines: const [
        OpmlOutline(
          title: 'Feed A',
          feedUrl: 'https://a.com/feed',
          siteUrl: 'https://a.com',
        ),
      ]);

      final parsed = OpmlParser.parse(generated);

      expect(parsed, hasLength(1));
      expect(parsed[0].feedUrl, 'https://a.com/feed');
      expect(parsed[0].siteUrl, 'https://a.com');
    });
  });
}
