import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

/// Feedbin REST API v2 client.
///
/// Provides methods to interact with Feedbin's API endpoints:
/// - Subscriptions management
/// - Entries/articles retrieval
/// - Unread/starred state management
/// - Taggings (folders) management
///
/// API documentation: https://github.com/feedbin/feedbin-api
class FeedbinRemoteDataSource {
  /// Feedbin API v2 base URL.
  static const String _baseUrl = 'https://api.feedbin.com/v2';

  /// Dio instance for HTTP requests.
  final Dio _dio;

  /// Creates a new FeedbinRemoteDataSource instance.
  FeedbinRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  /// Sets Basic Auth credentials for subsequent requests.
  ///
  /// [username] - Feedbin account email
  /// [password] - Feedbin account password or API key
  void setCredentials(String username, String password) {
    _dio.options.headers['Authorization'] =
        'Basic ${_basicAuthHeader(username, password)}';
  }

  /// Clears authentication headers.
  void clearCredentials() {
    _dio.options.headers.remove('Authorization');
  }

  /// Generates Basic Auth header value.
  String _basicAuthHeader(String username, String password) {
    final credentials = '$username:$password';
    final encoded = Uri.encodeComponent(credentials);
    return 'Basic $encoded';
  }

  /// Makes an authenticated GET request.
  Future<Response<T>> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final url = '$_baseUrl$path';
    return _dio.get<T>(url, queryParameters: queryParameters);
  }

  /// Makes an authenticated POST request.
  Future<Response<T>> _post<T>(
    String path, {
    dynamic data,
  }) async {
    final url = '$_baseUrl$path';
    return _dio.post<T>(url, data: data);
  }

  /// Makes an authenticated DELETE request.
  Future<Response<T>> _delete<T>(
    String path, {
    dynamic data,
  }) async {
    final url = '$_baseUrl$path';
    return _dio.delete<T>(url, data: data);
  }

  /// Makes an authenticated PATCH request.
  Future<Response<T>> _patch<T>(
    String path, {
    dynamic data,
  }) async {
    final url = '$_baseUrl$path';
    return _dio.patch<T>(url, data: data);
  }

  // ─── Subscriptions ─────────────────────────────────────────────────────

  /// Gets all feed subscriptions.
  ///
  /// GET /subscriptions.json
  Future<List<FeedbinSubscription>> getSubscriptions() async {
    final response = await _get<List<dynamic>>('/subscriptions.json');
    return (response.data as List)
        .map((json) => FeedbinSubscription.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new subscription.
  ///
  /// POST /subscriptions.json
  /// Body: { "feed_url": "https://example.com/feed.xml", "title": "Optional Title" }
  Future<FeedbinSubscription> createSubscription({
    required String feedUrl,
    String? title,
  }) async {
    final data = <String, dynamic>{'feed_url': feedUrl};
    if (title != null) {
      data['title'] = title;
    }
    final response = await _post<Map<String, dynamic>>('/subscriptions.json', data: data);
    return FeedbinSubscription.fromJson(response.data!);
  }

  /// Deletes a subscription.
  ///
  /// DELETE /subscriptions/{id}.json
  Future<void> deleteSubscription(String subscriptionId) async {
    await _delete('/subscriptions/$subscriptionId.json');
  }

  /// Updates a subscription.
  ///
  /// PATCH /subscriptions/{id}.json
  /// Body: { "title": "New Title" }
  Future<FeedbinSubscription> updateSubscription({
    required String subscriptionId,
    String? title,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) {
      data['title'] = title;
    }
    final response = await _patch<Map<String, dynamic>>(
      '/subscriptions/$subscriptionId.json',
      data: data,
    );
    return FeedbinSubscription.fromJson(response.data!);
  }

  // ─── Entries ────────────────────────────────────────────────────────────

  /// Gets entries (articles).
  ///
  /// GET /entries.json
  /// Query params: page (int), since (int - timestamp), per_page (int)
  Future<FeedbinEntriesResponse> getEntries({
    int? page,
    DateTime? since,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (page != null) {
      queryParameters['page'] = page;
    }
    if (since != null) {
      queryParameters['since'] = since.millisecondsSinceEpoch ~/ 1000;
    }
    if (perPage != null) {
      queryParameters['per_page'] = perPage;
    }
    final response = await _get<List<dynamic>>('/entries.json', queryParameters: queryParameters);
    return FeedbinEntriesResponse.fromJson(response.data as List);
  }

  /// Gets unread entry IDs.
  ///
  /// GET /unread_entries.json
  Future<List<String>> getUnreadEntries() async {
    final response = await _get<List<dynamic>>('/unread_entries.json');
    return (response.data as List).map((e) => e.toString()).toList();
  }

  /// Marks entries as unread.
  ///
  /// POST /unread_entries.json
  /// Body: { "unread_entries": ["id1", "id2"] }
  Future<void> markAsUnread(List<String> entryIds) async {
    await _post('/unread_entries.json', data: {'unread_entries': entryIds});
  }

  /// Marks entries as read.
  ///
  /// DELETE /unread_entries.json
  /// Body: { "unread_entries": ["id1", "id2"] }
  Future<void> markAsRead(List<String> entryIds) async {
    await _delete('/unread_entries.json', data: {'unread_entries': entryIds});
  }

  /// Gets starred entry IDs.
  ///
  /// GET /starred_entries.json
  Future<List<String>> getStarredEntries() async {
    final response = await _get<List<dynamic>>('/starred_entries.json');
    return (response.data as List).map((e) => e.toString()).toList();
  }

  /// Stars entries.
  ///
  /// POST /starred_entries.json
  /// Body: { "starred_entries": ["id1", "id2"] }
  Future<void> starEntries(List<String> entryIds) async {
    await _post('/starred_entries.json', data: {'starred_entries': entryIds});
  }

  /// Unstars entries.
  ///
  /// DELETE /starred_entries.json
  /// Body: { "starred_entries": ["id1", "id2"] }
  Future<void> unstarEntries(List<String> entryIds) async {
    await _delete('/starred_entries.json', data: {'starred_entries': entryIds});
  }

  // ─── Taggings (Folders) ─────────────────────────────────────────────────

  /// Gets all taggings.
  ///
  /// GET /taggings.json
  Future<List<FeedbinTagging>> getTaggings() async {
    final response = await _get<List<dynamic>>('/taggings.json');
    return (response.data as List)
        .map((json) => FeedbinTagging.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a tagging.
  ///
  /// POST /taggings.json
  /// Body: { "name": "Folder Name", "feed_id": 123 }
  Future<FeedbinTagging> createTagging({
    required String name,
    required int feedId,
  }) async {
    final data = {
      'name': name,
      'feed_id': feedId,
    };
    final response = await _post<Map<String, dynamic>>('/taggings.json', data: data);
    return FeedbinTagging.fromJson(response.data!);
  }

  /// Deletes a tagging.
  ///
  /// DELETE /taggings/{id}.json
  Future<void> deleteTagging(String taggingId) async {
    await _delete('/taggings/$taggingId.json');
  }

  /// Updates a tagging.
  ///
  /// PATCH /taggings/{id}.json
  /// Body: { "name": "New Name" }
  Future<FeedbinTagging> updateTagging({
    required String taggingId,
    String? name,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name;
    }
    final response = await _patch<Map<String, dynamic>>(
      '/taggings/$taggingId.json',
      data: data,
    );
    return FeedbinTagging.fromJson(response.data!);
  }
}

// ─── Feedbin Data Models ─────────────────────────────────────────────────

/// Feedbin subscription model.
class FeedbinSubscription {
  /// Subscription ID.
  final String id;

  /// Feed title.
  final String title;

  /// Feed URL.
  final String feedUrl;

  /// Website URL.
  final String? siteUrl;

  /// Feed icon URL.
  final String? iconUrl;

  /// Feed ID (numeric, converted to string).
  final String feedId;

  /// Created timestamp.
  final DateTime? createdAt;

  /// Updated timestamp.
  final DateTime? updatedAt;

  const FeedbinSubscription({
    required this.id,
    required this.title,
    required this.feedUrl,
    this.siteUrl,
    this.iconUrl,
    required this.feedId,
    this.createdAt,
    this.updatedAt,
  });

  factory FeedbinSubscription.fromJson(Map<String, dynamic> json) {
    return FeedbinSubscription(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      feedUrl: json['feed_url'] ?? '',
      siteUrl: json['site_url'],
      iconUrl: json['icon_url'],
      feedId: json['feed_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'feed_url': feedUrl,
      'site_url': siteUrl,
      'icon_url': iconUrl,
      'feed_id': feedId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Feedbin entry (article) model.
class FeedbinEntry {
  /// Entry ID.
  final String id;

  /// Entry title.
  final String title;

  /// Entry URL.
  final String url;

  /// Feed ID this entry belongs to.
  final String feedId;

  /// Author.
  final String? author;

  /// Summary/excerpt.
  final String? summary;

  /// Content (HTML).
  final String? content;

  /// Published date.
  final DateTime publishedAt;

  /// Updated date.
  final DateTime? updatedAt;

  /// Image URL.
  final String? imageUrl;

  const FeedbinEntry({
    required this.id,
    required this.title,
    required this.url,
    required this.feedId,
    this.author,
    this.summary,
    this.content,
    required this.publishedAt,
    this.updatedAt,
    this.imageUrl,
  });

  factory FeedbinEntry.fromJson(Map<String, dynamic> json) {
    return FeedbinEntry(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      feedId: json['feed_id']?.toString() ?? '',
      author: json['author'],
      summary: json['summary'],
      content: json['content'],
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      imageUrl: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'feed_id': feedId,
      'author': author,
      'summary': summary,
      'content': content,
      'published_at': publishedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image': imageUrl,
    };
  }
}

/// Feedbin entries response wrapper.
class FeedbinEntriesResponse {
  /// List of entries.
  final List<FeedbinEntry> entries;

  /// Total count of entries.
  final int totalCount;

  const FeedbinEntriesResponse({
    required this.entries,
    required this.totalCount,
  });

  factory FeedbinEntriesResponse.fromJson(List<dynamic> json) {
    final entries = json
        .map((e) => FeedbinEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return FeedbinEntriesResponse(
      entries: entries,
      totalCount: entries.length,
    );
  }
}

/// Feedbin tagging (folder) model.
class FeedbinTagging {
  /// Tagging ID.
  final String id;

  /// Tag/folder name.
  final String name;

  /// Feed ID this tagging applies to.
  final String feedId;

  /// Created timestamp.
  final DateTime? createdAt;

  const FeedbinTagging({
    required this.id,
    required this.name,
    required this.feedId,
    this.createdAt,
  });

  factory FeedbinTagging.fromJson(Map<String, dynamic> json) {
    return FeedbinTagging(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      feedId: json['feed_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'feed_id': feedId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
