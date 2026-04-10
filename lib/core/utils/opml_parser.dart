import 'package:xml/xml.dart';

/// Utility class for OPML 2.0 import/export.
///
/// OPML (Outline Processor Markup Language) is the standard format
/// for exchanging RSS subscription lists between feed readers.
class OpmlParser {
  OpmlParser._();

  /// Parses an OPML string and returns a list of feed outlines.
  ///
  /// Supports nested outlines (folders containing feeds).
  static List<OpmlOutline> parse(String opmlContent) {
    final document = XmlDocument.parse(opmlContent);
    final body = document.findAllElements('body').firstOrNull;
    if (body == null) return [];

    return _parseOutlines(body.findElements('outline'));
  }

  /// Recursively parses outline elements.
  static List<OpmlOutline> _parseOutlines(Iterable<XmlElement> elements) {
    final outlines = <OpmlOutline>[];

    for (final element in elements) {
      final xmlUrl = element.getAttribute('xmlUrl');
      final title = element.getAttribute('title') ??
          element.getAttribute('text') ??
          'Untitled';
      final htmlUrl = element.getAttribute('htmlUrl');
      final type = element.getAttribute('type');

      if (xmlUrl != null && xmlUrl.isNotEmpty) {
        // This is a feed outline
        outlines.add(OpmlOutline(
          title: title,
          feedUrl: xmlUrl,
          siteUrl: htmlUrl,
          type: type,
        ));
      } else {
        // This is a folder outline
        final children = _parseOutlines(element.findElements('outline'));
        outlines.add(OpmlOutline(
          title: title,
          isFolder: true,
          children: children,
        ));
      }
    }

    return outlines;
  }

  /// Generates an OPML 2.0 string from a list of outlines.
  ///
  /// [title] is the title of the OPML document.
  /// [outlines] is the list of feed/folder outlines to export.
  static String generate({
    String title = 'Reeder Subscriptions',
    required List<OpmlOutline> outlines,
  }) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('opml', attributes: {'version': '2.0'}, nest: () {
      builder.element('head', nest: () {
        builder.element('title', nest: title);
        builder.element('dateCreated', nest: DateTime.now().toIso8601String());
        builder.element('docs',
            nest: 'http://opml.org/spec2.opml');
      });

      builder.element('body', nest: () {
        _buildOutlines(builder, outlines);
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Recursively builds outline XML elements.
  static void _buildOutlines(XmlBuilder builder, List<OpmlOutline> outlines) {
    for (final outline in outlines) {
      if (outline.isFolder) {
        builder.element('outline',
            attributes: {
              'text': outline.title,
              'title': outline.title,
            },
            nest: () {
              if (outline.children.isNotEmpty) {
                _buildOutlines(builder, outline.children);
              }
            });
      } else {
        final attributes = <String, String>{
          'type': outline.type ?? 'rss',
          'text': outline.title,
          'title': outline.title,
          'xmlUrl': outline.feedUrl ?? '',
        };

        if (outline.siteUrl != null) {
          attributes['htmlUrl'] = outline.siteUrl!;
        }

        builder.element('outline', attributes: attributes);
      }
    }
  }

  /// Flattens a nested outline structure into a flat list of feeds.
  ///
  /// Each feed retains its folder name for grouping.
  static List<FlatOpmlFeed> flatten(List<OpmlOutline> outlines,
      {String? parentFolder}) {
    final feeds = <FlatOpmlFeed>[];

    for (final outline in outlines) {
      if (outline.isFolder) {
        feeds.addAll(flatten(outline.children, parentFolder: outline.title));
      } else if (outline.feedUrl != null) {
        feeds.add(FlatOpmlFeed(
          title: outline.title,
          feedUrl: outline.feedUrl!,
          siteUrl: outline.siteUrl,
          folderName: parentFolder,
        ));
      }
    }

    return feeds;
  }
}

/// Represents an outline element in an OPML document.
///
/// Can be either a feed (has feedUrl) or a folder (has children).
class OpmlOutline {
  final String title;
  final String? feedUrl;
  final String? siteUrl;
  final String? type;
  final bool isFolder;
  final List<OpmlOutline> children;

  const OpmlOutline({
    required this.title,
    this.feedUrl,
    this.siteUrl,
    this.type,
    this.isFolder = false,
    this.children = const [],
  });
}

/// A flattened feed entry from an OPML document.
class FlatOpmlFeed {
  final String title;
  final String feedUrl;
  final String? siteUrl;
  final String? folderName;

  const FlatOpmlFeed({
    required this.title,
    required this.feedUrl,
    this.siteUrl,
    this.folderName,
  });
}
