/// Feedly Cloud API v3 remote data source.
///
/// Implements Feedly's REST API for RSS feed synchronization.
/// Documentation: https://developers.feedly.com/
library;

import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

/// Feedly Cloud API v3 client.
///
/// Provides methods to interact with Feedly's REST API endpoints.
class FeedlyRemoteDataSource {
  /// Base URL for Feedly Cloud API v3.
  static const String _baseUrl = 'https://cloud.feedly.com/v3';

  /// Dio client instance.
  final Dio _dio;

  /// OAuth access token.
  String? _accessToken;

  /// Creates a new FeedlyRemoteDataSource instance.
  FeedlyRemoteDataSource() : _dio = DioClient.instance.dio;

  /// Sets the OAuth access token for authentication.
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clears the stored access token.
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Returns the authorization header with Bearer token.
  Map<String, String> get _authHeaders {
    if (_accessToken == null) {
      throw Exception('Access token not set. Call setAccessToken() first.');
    }
    return {'Authorization': 'Bearer $_accessToken'};
  }

  /// Gets all subscriptions from Feedly.
  ///
  /// GET /subscriptions
  Future<List<FeedlySubscription>> getSubscriptions() async {
    final response = await _dio.get(
      '$_baseUrl/subscriptions',
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((json) => FeedlySubscription.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch subscriptions: ${response.statusCode}');
  }

  /// Adds a new subscription to Feedly.
  ///
  /// POST /subscriptions
  Future<FeedlySubscription> addSubscription({
    required String feedUrl,
    String? title,
    String? categoryId,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/subscriptions',
      data: [
        {
          'id': 'feed/$feedUrl',
          'title': title,
          'categories': categoryId != null
              ? [
                  {
                    'id': categoryId,
                  }
                ]
              : [],
        }
      ],
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode == 200 && response.data != null) {
      return FeedlySubscription.fromJson(response.data[0]);
    }
    throw Exception('Failed to add subscription: ${response.statusCode}');
  }

  /// Removes a subscription from Feedly.
  ///
  /// DELETE /subscriptions/{subscriptionId}
  Future<void> removeSubscription(String subscriptionId) async {
    final response = await _dio.delete(
      '$_baseUrl/subscriptions/$subscriptionId',
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove subscription: ${response.statusCode}');
    }
  }

  /// Gets stream contents (articles) from Feedly.
  ///
  /// GET /streams/contents?streamId={streamId}&count={count}&newerThan={timestamp}
  Future<FeedlyStreamContents> getStreamContents({
    required String streamId,
    int? count,
    int? newerThan,
    bool? continuation,
  }) async {
    final queryParams = <String, dynamic>{
      'streamId': streamId,
    };

    if (count != null) {
      queryParams['count'] = count;
    }
    if (newerThan != null) {
      queryParams['newerThan'] = newerThan;
    }
    if (continuation != null) {
      queryParams['continuation'] = continuation;
    }

    final response = await _dio.get(
      '$_baseUrl/streams/contents',
      queryParameters: queryParams,
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode == 200 && response.data != null) {
      return FeedlyStreamContents.fromJson(response.data);
    }
    throw Exception('Failed to fetch stream contents: ${response.statusCode}');
  }

  /// Gets stream IDs from Feedly.
  ///
  /// GET /streams/ids?streamId={streamId}&count={count}&newerThan={timestamp}
  Future<FeedlyStreamIds> getStreamIds({
    required String streamId,
    int? count,
    int? newerThan,
    bool? unreadOnly,
    bool? markedAsRead,
  }) async {
    final queryParams = <String, dynamic>{
      'streamId': streamId,
    };

    if (count != null) {
      queryParams['count'] = count;
    }
    if (newerThan != null) {
      queryParams['newerThan'] = newerThan;
    }
    if (unreadOnly != null) {
      queryParams['unreadOnly'] = unreadOnly;
    }
    if (markedAsRead != null) {
      queryParams['markedAsRead'] = markedAsRead;
    }

    final response = await _dio.get(
      '$_baseUrl/streams/ids',
      queryParameters: queryParams,
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode == 200 && response.data != null) {
      return FeedlyStreamIds.fromJson(response.data);
    }
    throw Exception('Failed to fetch stream IDs: ${response.statusCode}');
  }

  /// Gets unread counts from Feedly.
  ///
  /// GET /markers/counts
  Future<FeedlyUnreadCounts> getUnreadCounts() async {
    final response = await _dio.get(
      '$_baseUrl/markers/counts',
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode == 200 && response.data != null) {
      return FeedlyUnreadCounts.fromJson(response.data);
    }
    throw Exception('Failed to fetch unread counts: ${response.statusCode}');
  }

  /// Marks entries as read, unread, saved, or unsaved.
  ///
  /// POST /markers
  Future<void> markEntries({
    required String action,
    required List<String> entryIds,
    String? type,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/markers',
      data: {
        'action': action,
        'type': type ?? 'entries',
        'entryIds': entryIds,
      },
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark entries: ${response.statusCode}');
    }
  }

  /// Gets all categories from Feedly.
  ///
  /// GET /categories
  Future<List<FeedlyCategory>> getCategories() async {
    final response = await _dio.get(
      '$_baseUrl/categories',
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((json) => FeedlyCategory.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch categories: ${response.statusCode}');
  }

  /// Deletes a category from Feedly.
  ///
  /// DELETE /categories/{categoryId}
  Future<void> deleteCategory(String categoryId) async {
    final response = await _dio.delete(
      '$_baseUrl/categories/$categoryId',
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.statusCode}');
    }
  }

  /// Renames a category in Feedly.
  ///
  /// POST /categories/{categoryId}
  Future<void> renameCategory(String categoryId, String newName) async {
    final response = await _dio.post(
      '$_baseUrl/categories/$categoryId',
      data: {'label': newName},
      options: Options(headers: _authHeaders),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to rename category: ${response.statusCode}');
    }
  }
}

/// Feedly subscription model.
class FeedlySubscription {
  final String id;
  final String title;
  final String? description;
  final String website;
  final String? iconUrl;
  final List<FeedlyCategoryReference> categories;

  FeedlySubscription({
    required this.id,
    required this.title,
    this.description,
    required this.website,
    this.iconUrl,
    required this.categories,
  });

  factory FeedlySubscription.fromJson(Map<String, dynamic> json) {
    return FeedlySubscription(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['id'] as String,
      description: json['description'] as String?,
      website: json['website'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      categories: (json['categories'] as List?)
              ?.map((cat) => FeedlyCategoryReference.fromJson(cat))
              .toList() ??
          [],
    );
  }

  /// Gets the feed URL from the subscription ID.
  /// Feedly IDs are formatted as "feed/{url}".
  String get feedUrl {
    if (id.startsWith('feed/')) {
      return id.substring(5);
    }
    return id;
  }
}

/// Feedly category reference (used in subscriptions).
class FeedlyCategoryReference {
  final String id;
  final String? label;

  FeedlyCategoryReference({
    required this.id,
    this.label,
  });

  factory FeedlyCategoryReference.fromJson(Map<String, dynamic> json) {
    return FeedlyCategoryReference(
      id: json['id'] as String,
      label: json['label'] as String?,
    );
  }
}

/// Feedly category model.
class FeedlyCategory {
  final String id;
  final String label;

  FeedlyCategory({
    required this.id,
    required this.label,
  });

  factory FeedlyCategory.fromJson(Map<String, dynamic> json) {
    return FeedlyCategory(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

/// Feedly stream contents response.
class FeedlyStreamContents {
  final List<FeedlyEntry> items;
  final String? continuation;

  FeedlyStreamContents({
    required this.items,
    this.continuation,
  });

  factory FeedlyStreamContents.fromJson(Map<String, dynamic> json) {
    return FeedlyStreamContents(
      items: (json['items'] as List?)
              ?.map((item) => FeedlyEntry.fromJson(item))
              .toList() ??
          [],
      continuation: json['continuation'] as String?,
    );
  }
}

/// Feedly stream IDs response.
class FeedlyStreamIds {
  final List<String> ids;
  final String? continuation;

  FeedlyStreamIds({
    required this.ids,
    this.continuation,
  });

  factory FeedlyStreamIds.fromJson(Map<String, dynamic> json) {
    return FeedlyStreamIds(
      ids: (json['ids'] as List?)?.cast<String>() ?? [],
      continuation: json['continuation'] as String?,
    );
  }
}

/// Feedly entry (article) model.
class FeedlyEntry {
  final String id;
  final String title;
  final String? summary;
  final FeedlyContent? content;
  final FeedlyOrigin origin;
  final List<FeedlyAlternate> alternate;
  final FeedlyAuthor? author;
  final int published;
  final int updated;
  final bool unread;
  final List<FeedlyEnclosure>? enclosures;
  final FeedlyThumbnail? thumbnail;

  FeedlyEntry({
    required this.id,
    required this.title,
    this.summary,
    this.content,
    required this.origin,
    required this.alternate,
    this.author,
    required this.published,
    required this.updated,
    required this.unread,
    this.enclosures,
    this.thumbnail,
  });

  factory FeedlyEntry.fromJson(Map<String, dynamic> json) {
    return FeedlyEntry(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      summary: json['summary']?['content'] as String?,
      content: json['content'] != null
          ? FeedlyContent.fromJson(json['content'])
          : null,
      origin: FeedlyOrigin.fromJson(json['origin']),
      alternate: (json['alternate'] as List?)
              ?.map((alt) => FeedlyAlternate.fromJson(alt))
              .toList() ??
          [],
      author: json['author'] != null
          ? FeedlyAuthor.fromJson(json['author'])
          : null,
      published: json['published'] as int? ?? json['crawled'] as int? ?? 0,
      updated: json['updated'] as int? ?? json['crawled'] as int? ?? 0,
      unread: json['unread'] as bool? ?? false,
      enclosures: (json['enclosure'] as List?)
          ?.map((enc) => FeedlyEnclosure.fromJson(enc))
          .toList(),
      thumbnail: json['thumbnail'] != null
          ? FeedlyThumbnail.fromJson(json['thumbnail'])
          : null,
    );
  }

  /// Gets the article URL from alternate links.
  String? get url {
    if (alternate.isNotEmpty) {
      return alternate[0].href;
    }
    return null;
  }

  /// Gets the article author name.
  String? get authorName {
    return author?.name;
  }

  /// Gets the article content HTML.
  String? get contentHtml {
    return content?.content ?? summary;
  }
}

/// Feedly entry origin (feed information).
class FeedlyOrigin {
  final String streamId;
  final String title;
  final String? htmlUrl;

  FeedlyOrigin({
    required this.streamId,
    required this.title,
    this.htmlUrl,
  });

  factory FeedlyOrigin.fromJson(Map<String, dynamic> json) {
    return FeedlyOrigin(
      streamId: json['streamId'] as String,
      title: json['title'] as String? ?? '',
      htmlUrl: json['htmlUrl'] as String?,
    );
  }

  /// Gets the feed ID from the stream ID.
  /// Feedly stream IDs are formatted as "feed/{url}".
  String get feedId {
    if (streamId.startsWith('feed/')) {
      return streamId;
    }
    return streamId;
  }
}

/// Feedly alternate link.
class FeedlyAlternate {
  final String href;
  final String? type;

  FeedlyAlternate({
    required this.href,
    this.type,
  });

  factory FeedlyAlternate.fromJson(Map<String, dynamic> json) {
    return FeedlyAlternate(
      href: json['href'] as String,
      type: json['type'] as String?,
    );
  }
}

/// Feedly author information.
class FeedlyAuthor {
  final String? name;

  FeedlyAuthor({
    this.name,
  });

  factory FeedlyAuthor.fromJson(Map<String, dynamic> json) {
    return FeedlyAuthor(
      name: json['name'] as String?,
    );
  }
}

/// Feedly content model.
class FeedlyContent {
  final String content;
  final String? direction;

  FeedlyContent({
    required this.content,
    this.direction,
  });

  factory FeedlyContent.fromJson(Map<String, dynamic> json) {
    return FeedlyContent(
      content: json['content'] as String,
      direction: json['direction'] as String?,
    );
  }
}

/// Feedly enclosure (media attachment).
class FeedlyEnclosure {
  final String href;
  final String? type;
  final int? length;

  FeedlyEnclosure({
    required this.href,
    this.type,
    this.length,
  });

  factory FeedlyEnclosure.fromJson(Map<String, dynamic> json) {
    return FeedlyEnclosure(
      href: json['href'] as String,
      type: json['type'] as String?,
      length: json['length'] as int?,
    );
  }

  /// Checks if this is an audio enclosure.
  bool get isAudio => type?.startsWith('audio/') ?? false;

  /// Checks if this is a video enclosure.
  bool get isVideo => type?.startsWith('video/') ?? false;
}

/// Feedly thumbnail image.
class FeedlyThumbnail {
  final String url;
  final int? width;
  final int? height;

  FeedlyThumbnail({
    required this.url,
    this.width,
    this.height,
  });

  factory FeedlyThumbnail.fromJson(List<dynamic> json) {
    if (json.isEmpty) {
      throw ArgumentError('Thumbnail list is empty');
    }
    final thumb = json[0] as Map<String, dynamic>;
    return FeedlyThumbnail(
      url: thumb['url'] as String,
      width: thumb['width'] as int?,
      height: thumb['height'] as int?,
    );
  }
}

/// Feedly unread counts response.
class FeedlyUnreadCounts {
  final List<FeedlyUnreadCount> unreadcounts;

  FeedlyUnreadCounts({
    required this.unreadcounts,
  });

  factory FeedlyUnreadCounts.fromJson(Map<String, dynamic> json) {
    return FeedlyUnreadCounts(
      unreadcounts: (json['unreadcounts'] as List?)
              ?.map((count) => FeedlyUnreadCount.fromJson(count))
              .toList() ??
          [],
    );
  }
}

/// Feedly unread count for a stream.
class FeedlyUnreadCount {
  final String id;
  final int count;
  final int? updated;

  FeedlyUnreadCount({
    required this.id,
    required this.count,
    this.updated,
  });

  factory FeedlyUnreadCount.fromJson(Map<String, dynamic> json) {
    return FeedlyUnreadCount(
      id: json['id'] as String,
      count: json['count'] as int? ?? 0,
      updated: json['updated'] as int?,
    );
  }
}
