import 'package:dio/dio.dart';

import 'google_reader_api.dart';

/// Inoreader remote data source.
///
/// Implements Google Reader API compatible protocol for Inoreader service.
/// Uses OAuth 2.0 Bearer Token authentication instead of ClientLogin.
/// Base URL: https://www.inoreader.com
class InoreaderRemoteDataSource {
  /// Base URL for Inoreader API.
  static const String baseUrl = 'https://www.inoreader.com';

  /// OAuth access token for authentication.
  String? _accessToken;

  /// Custom Dio instance with Bearer token interceptor.
  late final Dio _dio;

  /// Google Reader API client wrapper.
  late final GoogleReaderApi _googleReaderApi;

  InoreaderRemoteDataSource() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Reeder/1.0 (Flutter)',
        },
      ),
    );

    // Add interceptor for Bearer token authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
      ),
    );

    // Create GoogleReaderApi with custom Dio instance
    _googleReaderApi = GoogleReaderApi(
      baseUrl: baseUrl,
      dio: _dio,
    );
  }

  /// Sets the OAuth access token for authentication.
  ///
  /// This will be used in the Authorization header as 'Bearer {token}'.
  void setAccessToken(String token) {
    _accessToken = token;
    // Update the GoogleReaderApi's auth token as well
    _googleReaderApi.setAuthToken(token);
  }

  /// Clears the access token.
  void clearAccessToken() {
    _accessToken = null;
    _googleReaderApi.clearAuthToken();
  }

  /// Gets the subscription list (feeds).
  Future<List<GReaderSubscription>> getSubscriptionList() async {
    return _googleReaderApi.getSubscriptionList();
  }

  /// Adds a new subscription (feed).
  Future<void> addSubscription(
    String feedUrl, {
    String? title,
    String? label,
  }) async {
    await _googleReaderApi.addSubscription(
      feedUrl,
      title: title,
      label: label,
    );
  }

  /// Removes a subscription (feed).
  Future<void> removeSubscription(String streamId) async {
    await _googleReaderApi.removeSubscription(streamId);
  }

  /// Renames a subscription (feed).
  Future<void> renameSubscription(String streamId, String newTitle) async {
    await _googleReaderApi.renameSubscription(streamId, newTitle);
  }

  /// Gets the tag list (folders/labels).
  Future<List<GReaderTag>> getTagList() async {
    return _googleReaderApi.getTagList();
  }

  /// Renames a tag (folder).
  Future<void> renameTag(String tagId, String newName) async {
    await _googleReaderApi.renameTag(tagId, newName);
  }

  /// Deletes a tag (folder).
  Future<void> deleteTag(String tagId) async {
    await _googleReaderApi.deleteTag(tagId);
  }

  /// Gets stream contents (articles).
  Future<GReaderStreamContents> getStreamContents(
    String streamId, {
    int? count,
    String? continuation,
    int? sinceTimestamp,
    String? excludeTarget,
  }) async {
    return _googleReaderApi.getStreamContents(
      streamId,
      count: count,
      continuation: continuation,
      sinceTimestamp: sinceTimestamp,
      excludeTarget: excludeTarget,
    );
  }

  /// Gets stream item IDs.
  Future<List<String>> getStreamItemIds(
    String streamId, {
    int? count,
    String? continuation,
  }) async {
    return _googleReaderApi.getStreamItemIds(
      streamId,
      count: count,
      continuation: continuation,
    );
  }

  /// Gets unread counts for streams.
  Future<Map<String, int>> getUnreadCounts() async {
    return _googleReaderApi.getUnreadCounts();
  }

  /// Gets unread item IDs.
  Future<List<String>> getUnreadItemIds({int? count}) async {
    return _googleReaderApi.getUnreadItemIds(count: count);
  }

  /// Gets starred item IDs.
  Future<List<String>> getStarredItemIds({int? count}) async {
    return _googleReaderApi.getStarredItemIds(count: count);
  }

  /// Edits tags on items (read/unread/star/unstar).
  Future<void> editTag(
    List<String> itemIds, {
    String? addTag,
    String? removeTag,
  }) async {
    await _googleReaderApi.editTag(
      itemIds,
      addTag: addTag,
      removeTag: removeTag,
    );
  }

  /// Marks items as read.
  Future<void> markAsRead(List<String> itemIds) async {
    await _googleReaderApi.markAsRead(itemIds);
  }

  /// Marks items as unread.
  Future<void> markAsUnread(List<String> itemIds) async {
    await _googleReaderApi.markAsUnread(itemIds);
  }

  /// Stars items.
  Future<void> starItems(List<String> itemIds) async {
    await _googleReaderApi.starItems(itemIds);
  }

  /// Unstars items.
  Future<void> unstarItems(List<String> itemIds) async {
    await _googleReaderApi.unstarItems(itemIds);
  }

  /// Marks all items in a stream as read.
  Future<void> markAllAsRead(String streamId, {int? timestampUsec}) async {
    await _googleReaderApi.markAllAsRead(streamId, timestampUsec: timestampUsec);
  }
}
