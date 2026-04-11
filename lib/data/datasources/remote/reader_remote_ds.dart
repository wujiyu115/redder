import 'google_reader_api.dart';

/// Remote data source for Reader.
///
/// Reader is a self-hosted RSS reader that provides a Google Reader API
/// compatible interface. This class wraps [GoogleReaderApi] and provides
/// a straightforward implementation that is fully compatible with the
/// Google Reader API specification.
class ReaderRemoteDataSource {
  final GoogleReaderApi _api;

  /// Creates a new Reader remote data source.
  ///
  /// [serverUrl] is the base URL of the Reader server.
  /// Unlike FreshRSS, Reader uses the server URL directly as the API base URL.
  ReaderRemoteDataSource({required String serverUrl})
      : _api = GoogleReaderApi(baseUrl: serverUrl);

  /// Authenticates with Reader using username and password.
  ///
  /// Returns `true` if authentication succeeds.
  /// Throws on network errors or authentication failures.
  Future<bool> login(String username, String password) async {
    try {
      final token = await _api.clientLogin(username, password);
      if (token.isNotEmpty) {
        _api.setAuthToken(token);
        return true;
      }
      return false;
    } catch (e) {
      _api.clearAuthToken();
      rethrow;
    }
  }

  /// Logs out by clearing the authentication token.
  void logout() {
    _api.clearAuthToken();
  }

  /// Gets the list of subscriptions (feeds).
  Future<List<GReaderSubscription>> getSubscriptions() async {
    return await _api.getSubscriptionList();
  }

  /// Adds a new subscription.
  Future<void> addSubscription(
    String feedUrl, {
    String? title,
    String? label,
  }) async {
    await _api.addSubscription(feedUrl, title: title, label: label);
  }

  /// Removes a subscription.
  Future<void> removeSubscription(String streamId) async {
    await _api.removeSubscription(streamId);
  }

  /// Renames a subscription.
  Future<void> renameSubscription(String streamId, String newTitle) async {
    await _api.renameSubscription(streamId, newTitle);
  }

  /// Gets the list of tags (folders).
  Future<List<GReaderTag>> getTags() async {
    return await _api.getTagList();
  }

  /// Renames a tag.
  Future<void> renameTag(String tagId, String newName) async {
    await _api.renameTag(tagId, newName);
  }

  /// Deletes a tag.
  Future<void> deleteTag(String tagId) async {
    await _api.deleteTag(tagId);
  }

  /// Gets stream contents (articles).
  Future<GReaderStreamContents> getStreamContents(
    String streamId, {
    int? count,
    String? continuation,
    int? sinceTimestamp,
    String? excludeTarget,
  }) async {
    return await _api.getStreamContents(
      streamId,
      count: count,
      continuation: continuation,
      sinceTimestamp: sinceTimestamp,
      excludeTarget: excludeTarget,
    );
  }

  /// Gets unread article IDs.
  Future<List<String>> getUnreadItemIds({int? count}) async {
    return await _api.getUnreadItemIds(count: count);
  }

  /// Gets starred article IDs.
  Future<List<String>> getStarredItemIds({int? count}) async {
    return await _api.getStarredItemIds(count: count);
  }

  /// Edits tags for items.
  Future<void> editTags(
    List<String> itemIds, {
    String? addTag,
    String? removeTag,
  }) async {
    await _api.editTag(itemIds, addTag: addTag, removeTag: removeTag);
  }

  /// Marks items as read.
  Future<void> markAsRead(List<String> itemIds) async {
    await _api.markAsRead(itemIds);
  }

  /// Marks items as unread.
  Future<void> markAsUnread(List<String> itemIds) async {
    await _api.markAsUnread(itemIds);
  }

  /// Stars items.
  Future<void> starItems(List<String> itemIds) async {
    await _api.starItems(itemIds);
  }

  /// Unstars items.
  Future<void> unstarItems(List<String> itemIds) async {
    await _api.unstarItems(itemIds);
  }

  /// Marks all items in a stream as read.
  Future<void> markAllAsRead(String streamId, {int? timestampUsec}) async {
    await _api.markAllAsRead(streamId, timestampUsec: timestampUsec);
  }
}
