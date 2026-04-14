import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/app_logger.dart';

/// Google Reader API client implementation.
///
/// Provides a unified interface for services that implement the
/// Google Reader API protocol (FreshRSS, Reader, Inoreader).
///
/// Reference: https://rss-sync.github.io/Open-Reader-API/
class GoogleReaderApi {
  final Dio _dio;
  final String baseUrl;
  String? _authToken;
  static const _log = AppLogger('GReaderAPI');

  GoogleReaderApi({required String baseUrl, Dio? dio})
      : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _dio = dio ?? DioClient.instance.dio;

  // ─── Authentication ─────────────────────────────────────────────────

  /// Sets the auth token for subsequent requests.
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clears the auth token.
  void clearAuthToken() {
    _authToken = null;
  }

  /// ClientLogin authentication.
  /// POST /accounts/ClientLogin
  /// Returns the Auth token string.
  Future<String> clientLogin(String email, String password) async {
    try {
      _log.info('clientLogin: email=$email');
      final loginData = 'Email=$email&Passwd=$password';
      var url = _apiUrl('/accounts/ClientLogin');

      // Manually follow redirects for POST requests because Dio's
      // followRedirects does not re-POST on 301/302 (HTTP spec converts
      // POST to GET). We retry up to 3 redirects.
      Response<dynamic> response;
      var redirectsRemaining = 3;

      while (true) {
        response = await _dio.post(
          url,
          data: loginData,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            followRedirects: false,
            validateStatus: (status) =>
                status != null && (status < 400 || status == 301 || status == 302 || status == 307 || status == 308),
          ),
        );

        final statusCode = response.statusCode ?? 0;
        if (statusCode == 301 || statusCode == 302 || statusCode == 307 || statusCode == 308) {
          final location = response.headers.value('location');
          if (location == null || redirectsRemaining <= 0) {
            throw DioException(
              requestOptions: response.requestOptions,
              type: DioExceptionType.badResponse,
              response: response,
              error: 'Server error ($statusCode). Please try again later.',
            );
          }
          // Resolve relative redirect URLs
          url = Uri.parse(url).resolve(location).toString();
          redirectsRemaining--;
          continue;
        }

        break;
      }

      final responseText = response.data as String;
      
      // Parse response for Auth= line
      final lines = responseText.split('\n');
      for (final line in lines) {
        if (line.startsWith('Auth=')) {
          final token = line.substring(5).trim();
          _authToken = token;
          _log.info('clientLogin: success');
          return token;
        }
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.unknown,
        error: 'Auth token not found in response',
      );
    } on DioException catch (e) {
      _log.error('clientLogin: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'ClientLogin failed: ${e.message}',
      );
    }
  }

  // ─── Subscription Management ────────────────────────────────────────

  /// GET /reader/api/0/subscription/list?output=json
  Future<List<GReaderSubscription>> getSubscriptionList() async {
    try {
      _log.info('getSubscriptionList: start');
      final response = await _dio.get(
        _apiUrl('/reader/api/0/subscription/list'),
        queryParameters: {'output': 'json'},
        options: _authOptions(),
      );

      final json = response.data as Map<String, dynamic>;
      final subscriptions = json['subscriptions'] as List<dynamic>? ?? [];
      _log.info('getSubscriptionList: found ${subscriptions.length} subscriptions');
      
      final result = subscriptions.map((sub) {
        final parsed = GReaderSubscription.fromJson(sub as Map<String, dynamic>);
        _log.info('getSubscriptionList: [${parsed.title}] id=${parsed.id}, url=${parsed.url}, htmlUrl=${parsed.htmlUrl}');
        return parsed;
      }).toList();
      return result;
    } on DioException catch (e) {
      _log.error('getSubscriptionList: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get subscription list: ${e.message}',
      );
    }
  }

  /// POST /reader/api/0/subscription/edit
  /// action=subscribe, feedUrl, optional title and label
  Future<void> addSubscription(
    String feedUrl, {
    String? title,
    String? label,
  }) async {
    try {
      _log.info('addSubscription: feedUrl=$feedUrl');
      final formData = <String, dynamic>{
        's': feedUrl.startsWith('feed/') ? feedUrl : 'feed/$feedUrl',
        'ac': 'subscribe',
      };

      if (title != null) {
        formData['t'] = title;
      }

      if (label != null) {
        formData['a'] = 'user/-/label/$label';
      }

      await _dio.post(
        _apiUrl('/reader/api/0/subscription/edit'),
        data: formData,
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      _log.error('addSubscription: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to add subscription: ${e.message}',
      );
    }
  }

  /// POST /reader/api/0/subscription/edit
  /// action=unsubscribe
  Future<void> removeSubscription(String streamId) async {
    try {
      _log.info('removeSubscription: streamId=$streamId');
      await _dio.post(
        _apiUrl('/reader/api/0/subscription/edit'),
        data: {
          's': streamId,
          'ac': 'unsubscribe',
        },
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      _log.error('removeSubscription: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to remove subscription: ${e.message}',
      );
    }
  }

  /// POST /reader/api/0/subscription/edit
  /// action=edit, title
  Future<void> renameSubscription(String streamId, String newTitle) async {
    try {
      _log.info('renameSubscription: streamId=$streamId, newTitle=$newTitle');
      await _dio.post(
        _apiUrl('/reader/api/0/subscription/edit'),
        data: {
          's': streamId,
          'ac': 'edit',
          't': newTitle,
        },
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      _log.error('renameSubscription: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to rename subscription: ${e.message}',
      );
    }
  }

  // ─── Tags/Labels (Folders) ──────────────────────────────────────────

  /// GET /reader/api/0/tag/list?output=json
  Future<List<GReaderTag>> getTagList() async {
    try {
      _log.info('getTagList: start');
      final response = await _dio.get(
        _apiUrl('/reader/api/0/tag/list'),
        queryParameters: {'output': 'json'},
        options: _authOptions(),
      );

      final json = response.data as Map<String, dynamic>;
      final tags = json['tags'] as List<dynamic>? ?? [];
      _log.info('getTagList: found ${tags.length} tags');
      
      return tags.map((tag) {
        return GReaderTag.fromJson(tag as Map<String, dynamic>);
      }).toList();
    } on DioException catch (e) {
      _log.error('getTagList: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get tag list: ${e.message}',
      );
    }
  }

  /// POST /reader/api/0/rename-tag
  Future<void> renameTag(String tagId, String newName) async {
    try {
      await _dio.post(
        _apiUrl('/reader/api/0/rename-tag'),
        data: {
          's': tagId,
          'dest': 'user/-/label/$newName',
        },
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to rename tag: ${e.message}',
      );
    }
  }

  /// POST /reader/api/0/disable-tag
  Future<void> deleteTag(String tagId) async {
    try {
      await _dio.post(
        _apiUrl('/reader/api/0/disable-tag'),
        data: {
          's': tagId,
        },
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to delete tag: ${e.message}',
      );
    }
  }

  // ─── Stream Contents (Articles) ─────────────────────────────────────

  /// GET /reader/api/0/stream/contents/{streamId}
  Future<GReaderStreamContents> getStreamContents(
    String streamId, {
    int? count,
    String? continuation,
    int? sinceTimestamp,
    String? excludeTarget,
  }) async {
    try {
      _log.info('getStreamContents: streamId=$streamId, count=$count, continuation=$continuation, sinceTimestamp=$sinceTimestamp');
      final queryParameters = <String, dynamic>{
        'output': 'json',
      };

      if (count != null) {
        queryParameters['n'] = count.toString();
      }

      if (continuation != null) {
        queryParameters['c'] = continuation;
      }

      if (sinceTimestamp != null) {
        queryParameters['ot'] = sinceTimestamp.toString();
      }

      if (excludeTarget != null) {
        queryParameters['xt'] = excludeTarget;
      }

      final response = await _dio.get(
        _apiUrl('/reader/api/0/stream/contents/$streamId'),
        queryParameters: queryParameters,
        options: _authOptions(),
      );

      return GReaderStreamContents.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _log.error('getStreamContents: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get stream contents: ${e.message}',
      );
    }
  }

  /// GET /reader/api/0/stream/items/ids
  Future<List<String>> getStreamItemIds(
    String streamId, {
    int? count,
    String? continuation,
  }) async {
    try {
      _log.info('getStreamItemIds: streamId=$streamId');
      final queryParameters = <String, dynamic>{
        'output': 'json',
      };

      if (count != null) {
        queryParameters['n'] = count.toString();
      }

      if (continuation != null) {
        queryParameters['c'] = continuation;
      }

      final response = await _dio.get(
        _apiUrl('/reader/api/0/stream/items/ids'),
        queryParameters: {
          ...queryParameters,
          's': streamId,
        },
        options: _authOptions(),
      );

      final json = response.data as Map<String, dynamic>;
      final itemRefs = json['itemRefs'] as List<dynamic>? ?? [];
      
      return itemRefs.map((ref) {
        return ref['id'] as String;
      }).toList();
    } on DioException catch (e) {
      _log.error('getStreamItemIds: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get stream item IDs: ${e.message}',
      );
    }
  }

  /// GET /reader/api/0/unread-count?output=json
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      _log.info('getUnreadCounts: start');
      final response = await _dio.get(
        _apiUrl('/reader/api/0/unread-count'),
        queryParameters: {'output': 'json'},
        options: _authOptions(),
      );

      final json = response.data as Map<String, dynamic>;
      final unreadCounts = <String, int>{};

      final counts = json['unreadcounts'] as List<dynamic>? ?? [];
      for (final count in counts) {
        final countMap = count as Map<String, dynamic>;
        final id = countMap['id'] as String;
        final countValue = countMap['count'] as int;
        unreadCounts[id] = countValue;
      }
      _log.info('getUnreadCounts: found ${unreadCounts.length} counts');

      return unreadCounts;
    } on DioException catch (e) {
      _log.error('getUnreadCounts: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get unread counts: ${e.message}',
      );
    }
  }

  // ─── Item IDs ───────────────────────────────────────────────────────

  /// Gets unread item IDs.
  /// Uses stream: user/-/state/com.google/reading-list
  /// Excludes: user/-/state/com.google/read
  Future<List<String>> getUnreadItemIds({int? count}) async {
    try {
      _log.info('getUnreadItemIds: start');
      final queryParameters = <String, dynamic>{
        'output': 'json',
        's': 'user/-/state/com.google/reading-list',
        'xt': 'user/-/state/com.google/read',
      };

      if (count != null) {
        queryParameters['n'] = count.toString();
      }

      final response = await _dio.get(
        _apiUrl('/reader/api/0/stream/items/ids'),
        queryParameters: queryParameters,
        options: _authOptions(),
      );

      final json = response.data as Map<String, dynamic>;
      final itemRefs = json['itemRefs'] as List<dynamic>? ?? [];
      
      return itemRefs.map((ref) {
        return ref['id'] as String;
      }).toList();
    } on DioException catch (e) {
      _log.error('getUnreadItemIds: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get unread item IDs: ${e.message}',
      );
    }
  }

  /// Gets starred item IDs.
  /// Uses stream: user/-/state/com.google/starred
  Future<List<String>> getStarredItemIds({int? count}) async {
    try {
      _log.info('getStarredItemIds: start');
      final queryParameters = <String, dynamic>{
        'output': 'json',
        's': 'user/-/state/com.google/starred',
      };

      if (count != null) {
        queryParameters['n'] = count.toString();
      }

      final response = await _dio.get(
        _apiUrl('/reader/api/0/stream/items/ids'),
        queryParameters: queryParameters,
        options: _authOptions(),
      );

      final json = response.data as Map<String, dynamic>;
      final itemRefs = json['itemRefs'] as List<dynamic>? ?? [];
      
      return itemRefs.map((ref) {
        return ref['id'] as String;
      }).toList();
    } on DioException catch (e) {
      _log.error('getStarredItemIds: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to get starred item IDs: ${e.message}',
      );
    }
  }

  // ─── Item State ─────────────────────────────────────────────────────

  /// POST /reader/api/0/edit-tag
  /// Adds or removes tags from items.
  Future<void> editTag(
    List<String> itemIds, {
    String? addTag,
    String? removeTag,
  }) async {
    try {
      _log.info('editTag: itemIds=${itemIds.length}, addTag=$addTag, removeTag=$removeTag');
      final data = <String, dynamic>{
        'i': itemIds.join(','),
      };

      if (addTag != null) {
        data['a'] = addTag;
      }

      if (removeTag != null) {
        data['r'] = removeTag;
      }

      await _dio.post(
        _apiUrl('/reader/api/0/edit-tag'),
        data: data,
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      _log.error('editTag: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to edit tag: ${e.message}',
      );
    }
  }

  /// Marks items as read.
  Future<void> markAsRead(List<String> itemIds) async {
    await editTag(itemIds, addTag: 'user/-/state/com.google/read');
  }

  /// Marks items as unread.
  Future<void> markAsUnread(List<String> itemIds) async {
    await editTag(itemIds, removeTag: 'user/-/state/com.google/read');
  }

  /// Stars items.
  Future<void> starItems(List<String> itemIds) async {
    await editTag(itemIds, addTag: 'user/-/state/com.google/starred');
  }

  /// Unstars items.
  Future<void> unstarItems(List<String> itemIds) async {
    await editTag(itemIds, removeTag: 'user/-/state/com.google/starred');
  }

  /// POST /reader/api/0/mark-all-as-read
  Future<void> markAllAsRead(String streamId, {int? timestampUsec}) async {
    try {
      _log.info('markAllAsRead: streamId=$streamId');
      final data = <String, dynamic>{
        's': streamId,
        'ts': timestampUsec?.toString() ?? '0',
      };

      await _dio.post(
        _apiUrl('/reader/api/0/mark-all-as-read'),
        data: data,
        options: _authOptions(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      _log.error('markAllAsRead: failed', error: e);
      throw DioException(
        requestOptions: e.requestOptions,
        type: e.type,
        response: e.response,
        error: 'Failed to mark all as read: ${e.message}',
      );
    }
  }

  // ─── Private Helpers ────────────────────────────────────────────────

  /// Builds request options with auth header.
  Options _authOptions({String? contentType}) {
    final headers = <String, dynamic>{};

    if (_authToken != null) {
      headers['Authorization'] = 'GoogleLogin auth=$_authToken';
    }

    return Options(
      headers: headers,
      contentType: contentType,
    );
  }

  /// Builds the full API URL.
  String _apiUrl(String path) => '$baseUrl$path';
}

// ─── Data Models ───────────────────────────────────────────────────────

/// Google Reader API subscription model.
class GReaderSubscription {
  final String id; // stream ID, e.g. 'feed/https://...' or 'feed/48'
  final String title;
  final String? url; // actual feed URL from API response
  final String? htmlUrl;
  final String? iconUrl;
  final String? firstItemMsec;
  final List<GReaderCategory> categories;

  GReaderSubscription({
    required this.id,
    required this.title,
    this.url,
    this.htmlUrl,
    this.iconUrl,
    this.firstItemMsec,
    required this.categories,
  });

  factory GReaderSubscription.fromJson(Map<String, dynamic> json) {
    final categories = <GReaderCategory>[];
    if (json['categories'] != null) {
      final categoriesList = json['categories'] as List<dynamic>;
      for (final cat in categoriesList) {
        categories.add(GReaderCategory.fromJson(cat as Map<String, dynamic>));
      }
    }

    return GReaderSubscription(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String?,
      htmlUrl: json['htmlUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      firstItemMsec: json['firstitemmsec'] as String?,
      categories: categories,
    );
  }
}

/// Google Reader API category (folder/label) model.
class GReaderCategory {
  final String id; // label ID like 'user/-/label/Tech'
  final String label;

  GReaderCategory({
    required this.id,
    required this.label,
  });

  factory GReaderCategory.fromJson(Map<String, dynamic> json) {
    return GReaderCategory(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

/// Google Reader API tag model.
class GReaderTag {
  final String id;
  final String? sortId;

  GReaderTag({
    required this.id,
    this.sortId,
  });

  factory GReaderTag.fromJson(Map<String, dynamic> json) {
    return GReaderTag(
      id: json['id'] as String,
      sortId: json['sortid'] as String?,
    );
  }
}

/// Google Reader API stream contents model.
class GReaderStreamContents {
  final String id;
  final String? title;
  final String? continuation;
  final List<GReaderItem> items;

  GReaderStreamContents({
    required this.id,
    this.title,
    this.continuation,
    required this.items,
  });

  factory GReaderStreamContents.fromJson(Map<String, dynamic> json) {
    final items = <GReaderItem>[];
    if (json['items'] != null) {
      final itemsList = json['items'] as List<dynamic>;
      for (final item in itemsList) {
        items.add(GReaderItem.fromJson(item as Map<String, dynamic>));
      }
    }

    return GReaderStreamContents(
      id: json['id'] as String,
      title: json['title'] as String?,
      continuation: json['continuation'] as String?,
      items: items,
    );
  }
}

/// Google Reader API item model.
class GReaderItem {
  final String id;
  final String? title;
  final String? author;
  final GReaderItemContent? summary;
  final GReaderItemContent? content;
  final String? canonical; // URL
  final List<String> categories;
  final int? published; // Unix timestamp
  final int? updated;
  final GReaderItemOrigin? origin;
  final List<GReaderEnclosure>? enclosure;

  GReaderItem({
    required this.id,
    this.title,
    this.author,
    this.summary,
    this.content,
    this.canonical,
    required this.categories,
    this.published,
    this.updated,
    this.origin,
    this.enclosure,
  });

  factory GReaderItem.fromJson(Map<String, dynamic> json) {
    final categories = <String>[];
    if (json['categories'] != null) {
      final categoriesList = json['categories'] as List<dynamic>;
      for (final cat in categoriesList) {
        categories.add(cat as String);
      }
    }

    final enclosures = <GReaderEnclosure>[];
    if (json['enclosure'] != null) {
      final enclosureList = json['enclosure'] as List<dynamic>;
      for (final enc in enclosureList) {
        enclosures.add(GReaderEnclosure.fromJson(enc as Map<String, dynamic>));
      }
    }

    String? canonicalUrl;
    if (json['canonical'] != null) {
      final canonicalList = json['canonical'] as List<dynamic>;
      if (canonicalList.isNotEmpty) {
        canonicalUrl = canonicalList[0]['href'] as String?;
      }
    }

    return GReaderItem(
      id: json['id'] as String,
      title: json['title'] as String?,
      author: json['author'] as String?,
      summary: json['summary'] != null
          ? GReaderItemContent.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      content: json['content'] != null
          ? GReaderItemContent.fromJson(json['content'] as Map<String, dynamic>)
          : null,
      canonical: canonicalUrl,
      categories: categories,
      published: json['published'] as int?,
      updated: json['updated'] as int?,
      origin: json['origin'] != null
          ? GReaderItemOrigin.fromJson(json['origin'] as Map<String, dynamic>)
          : null,
      enclosure: enclosures.isEmpty ? null : enclosures,
    );
  }
}

/// Google Reader API item content model.
class GReaderItemContent {
  final String? content;

  GReaderItemContent({
    this.content,
  });

  factory GReaderItemContent.fromJson(Map<String, dynamic> json) {
    return GReaderItemContent(
      content: json['content'] as String?,
    );
  }
}

/// Google Reader API item origin model.
class GReaderItemOrigin {
  final String? streamId;
  final String? title;
  final String? htmlUrl;

  GReaderItemOrigin({
    this.streamId,
    this.title,
    this.htmlUrl,
  });

  factory GReaderItemOrigin.fromJson(Map<String, dynamic> json) {
    return GReaderItemOrigin(
      streamId: json['streamId'] as String?,
      title: json['title'] as String?,
      htmlUrl: json['htmlUrl'] as String?,
    );
  }
}

/// Google Reader API enclosure model.
class GReaderEnclosure {
  final String? href;
  final String? type;

  GReaderEnclosure({
    this.href,
    this.type,
  });

  factory GReaderEnclosure.fromJson(Map<String, dynamic> json) {
    return GReaderEnclosure(
      href: json['href'] as String?,
      type: json['type'] as String?,
    );
  }
}
