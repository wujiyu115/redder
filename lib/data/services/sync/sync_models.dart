/// Sync layer data transfer objects (DTOs).
///
/// These models serve as an abstraction layer between remote sync services
/// (Feedbin, Feedly, Inoreader, FreshRSS, Reader) and the local database.
/// Each service implementation converts its API responses into these DTOs,
/// which are then mapped to local Drift models for storage.
library;

/// Supported sync service types.
enum SyncServiceType {
  /// Local-only RSS fetching (no remote sync).
  local,

  /// Feedbin (https://feedbin.com) - REST API v2, Basic Auth.
  feedbin,

  /// Feedly (https://feedly.com) - Cloud API v3, OAuth 2.0.
  feedly,

  /// Inoreader (https://www.inoreader.com) - Google Reader API compatible, OAuth 2.0.
  inoreader,

  /// FreshRSS (self-hosted) - Google Reader API compatible, Basic Auth.
  freshRss,

  /// Reader (self-hosted) - Google Reader API compatible.
  reader,
}

/// Extension to provide display metadata for [SyncServiceType].
extension SyncServiceTypeExtension on SyncServiceType {
  /// Human-readable service name.
  String get displayName {
    switch (this) {
      case SyncServiceType.local:
        return 'Local';
      case SyncServiceType.feedbin:
        return 'Feedbin';
      case SyncServiceType.feedly:
        return 'Feedly';
      case SyncServiceType.inoreader:
        return 'Inoreader';
      case SyncServiceType.freshRss:
        return 'FreshRSS';
      case SyncServiceType.reader:
        return 'Reader';
    }
  }

  /// Icon identifier for the service.
  String get iconName {
    switch (this) {
      case SyncServiceType.local:
        return 'rss_feed';
      case SyncServiceType.feedbin:
        return 'feedbin';
      case SyncServiceType.feedly:
        return 'feedly';
      case SyncServiceType.inoreader:
        return 'inoreader';
      case SyncServiceType.freshRss:
        return 'freshrss';
      case SyncServiceType.reader:
        return 'reader';
    }
  }

  /// Whether this service requires a server URL (self-hosted).
  bool get requiresServerUrl {
    switch (this) {
      case SyncServiceType.freshRss:
      case SyncServiceType.reader:
        return true;
      default:
        return false;
    }
  }

  /// Whether this service uses OAuth 2.0 authentication.
  bool get usesOAuth {
    switch (this) {
      case SyncServiceType.feedly:
      case SyncServiceType.inoreader:
        return true;
      default:
        return false;
    }
  }
}

/// DTO representing a feed subscription from a remote sync service.
class SyncFeed {
  /// Remote service-specific feed ID.
  final String remoteId;

  /// Feed title.
  final String title;

  /// Feed URL (RSS/Atom/JSON Feed URL).
  final String feedUrl;

  /// Website URL.
  final String? siteUrl;

  /// Feed icon URL.
  final String? iconUrl;

  /// Folder/category remote ID this feed belongs to.
  final String? folderId;

  /// Feed description.
  final String? description;

  const SyncFeed({
    required this.remoteId,
    required this.title,
    required this.feedUrl,
    this.siteUrl,
    this.iconUrl,
    this.folderId,
    this.description,
  });

  @override
  String toString() => 'SyncFeed(remoteId: $remoteId, title: $title, feedUrl: $feedUrl)';
}

/// DTO representing a folder/category from a remote sync service.
class SyncFolder {
  /// Remote service-specific folder ID.
  final String remoteId;

  /// Folder name.
  final String name;

  const SyncFolder({
    required this.remoteId,
    required this.name,
  });

  @override
  String toString() => 'SyncFolder(remoteId: $remoteId, name: $name)';
}

/// DTO representing an article/entry from a remote sync service.
class SyncArticle {
  /// Remote service-specific article ID.
  final String remoteId;

  /// Remote feed ID this article belongs to.
  final String feedRemoteId;

  /// Article title.
  final String title;

  /// Article summary/excerpt.
  final String? summary;

  /// Full article content (HTML).
  final String? content;

  /// Article URL.
  final String url;

  /// Article author.
  final String? author;

  /// Publication date.
  final DateTime publishedAt;

  /// Whether the article is read.
  final bool isRead;

  /// Whether the article is starred/saved.
  final bool isStarred;

  /// Image URL (thumbnail/hero image).
  final String? imageUrl;

  /// Audio enclosure URL (for podcasts).
  final String? audioUrl;

  /// Video enclosure URL.
  final String? videoUrl;

  /// Audio duration in seconds.
  final int? audioDuration;

  const SyncArticle({
    required this.remoteId,
    required this.feedRemoteId,
    required this.title,
    this.summary,
    this.content,
    required this.url,
    this.author,
    required this.publishedAt,
    this.isRead = false,
    this.isStarred = false,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.audioDuration,
  });

  @override
  String toString() => 'SyncArticle(remoteId: $remoteId, title: $title)';
}

/// Result of a sync operation.
class SyncResult {
  /// Number of new feeds added.
  final int newFeeds;

  /// Number of feeds updated.
  final int updatedFeeds;

  /// Number of feeds removed.
  final int removedFeeds;

  /// Number of new articles added.
  final int newArticles;

  /// Number of articles with updated state (read/starred).
  final int updatedArticles;

  /// Number of articles removed.
  final int removedArticles;

  /// Errors encountered during sync, keyed by feed/item identifier.
  final Map<String, String> errors;

  /// Timestamp when the sync completed.
  final DateTime completedAt;

  /// Duration of the sync operation.
  final Duration duration;

  const SyncResult({
    this.newFeeds = 0,
    this.updatedFeeds = 0,
    this.removedFeeds = 0,
    this.newArticles = 0,
    this.updatedArticles = 0,
    this.removedArticles = 0,
    this.errors = const {},
    required this.completedAt,
    required this.duration,
  });

  factory SyncResult.empty() => SyncResult(
        completedAt: DateTime.now(),
        duration: Duration.zero,
      );

  bool get hasErrors => errors.isNotEmpty;
  bool get hasChanges =>
      newFeeds > 0 ||
      updatedFeeds > 0 ||
      removedFeeds > 0 ||
      newArticles > 0 ||
      updatedArticles > 0 ||
      removedArticles > 0;

  @override
  String toString() =>
      'SyncResult(feeds: +$newFeeds ~$updatedFeeds -$removedFeeds, '
      'articles: +$newArticles ~$updatedArticles -$removedArticles, '
      'errors: ${errors.length})';
}

/// Credentials for authenticating with a sync service.
class SyncCredentials {
  /// Service type.
  final SyncServiceType serviceType;

  /// Server URL (for self-hosted services like FreshRSS, Reader).
  final String? serverUrl;

  /// Username or email.
  final String? username;

  /// Password or API key.
  final String? password;

  /// OAuth access token.
  final String? accessToken;

  /// OAuth refresh token.
  final String? refreshToken;

  /// OAuth token expiry time.
  final DateTime? tokenExpiresAt;

  const SyncCredentials({
    required this.serviceType,
    this.serverUrl,
    this.username,
    this.password,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  });

  /// Whether the credentials use Basic Auth (username + password).
  bool get isBasicAuth => username != null && password != null;

  /// Whether the credentials use OAuth.
  bool get isOAuth => accessToken != null;

  /// Whether the OAuth token has expired.
  bool get isTokenExpired {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(tokenExpiresAt!);
  }

  /// Creates a copy with updated OAuth tokens.
  SyncCredentials copyWithTokens({
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return SyncCredentials(
      serviceType: serviceType,
      serverUrl: serverUrl,
      username: username,
      password: password,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }
}

/// Current status of the sync engine.
enum SyncStatus {
  /// No sync in progress, idle.
  idle,

  /// Sync is currently running.
  syncing,

  /// Last sync completed with errors.
  error,

  /// Waiting for network connectivity.
  waitingForNetwork,
}

/// Information about a sync account stored locally.
class SyncAccountInfo {
  /// Local database ID.
  final int id;

  /// Service type.
  final SyncServiceType serviceType;

  /// Server URL (for self-hosted services).
  final String? serverUrl;

  /// Username/email for display.
  final String? username;

  /// Whether this is the currently active account.
  final bool isActive;

  /// Last successful sync timestamp.
  final DateTime? lastSyncAt;

  /// Account creation timestamp.
  final DateTime createdAt;

  const SyncAccountInfo({
    required this.id,
    required this.serviceType,
    this.serverUrl,
    this.username,
    this.isActive = false,
    this.lastSyncAt,
    required this.createdAt,
  });

  /// Display label for the account.
  String get displayLabel {
    if (username != null) {
      return '$username (${serviceType.displayName})';
    }
    if (serverUrl != null) {
      return '$serverUrl (${serviceType.displayName})';
    }
    return serviceType.displayName;
  }
}
