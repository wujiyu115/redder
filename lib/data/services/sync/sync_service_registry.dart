import 'sync_models.dart';
import 'sync_service.dart';

/// Registry for managing available sync service implementations.
///
/// Provides a centralized place to register, retrieve, and switch between
/// different sync service implementations. The registry follows a
/// service locator pattern.
///
/// Usage:
/// ```dart
/// final registry = SyncServiceRegistry();
/// registry.register(FeedbinSyncService());
/// registry.register(FeedlySyncService());
///
/// final service = registry.getService(SyncServiceType.feedbin);
/// ```
class SyncServiceRegistry {
  /// Registered service factories, keyed by service type.
  final Map<SyncServiceType, SyncService Function()> _factories = {};

  /// Cached service instances, keyed by service type.
  final Map<SyncServiceType, SyncService> _instances = {};

  /// The currently active sync service.
  SyncService? _activeService;

  /// Registers a sync service factory.
  ///
  /// The factory will be called lazily when the service is first requested.
  void registerFactory(SyncServiceType type, SyncService Function() factory) {
    _factories[type] = factory;
  }

  /// Registers a sync service instance directly.
  void register(SyncService service) {
    _instances[service.serviceType] = service;
  }

  /// Gets a sync service by type.
  ///
  /// Returns a cached instance if available, otherwise creates one from
  /// the registered factory. Returns `null` if no service is registered
  /// for the given type.
  SyncService? getService(SyncServiceType type) {
    if (_instances.containsKey(type)) {
      return _instances[type];
    }

    final factory = _factories[type];
    if (factory != null) {
      final service = factory();
      _instances[type] = service;
      return service;
    }

    return null;
  }

  /// Gets the currently active sync service.
  ///
  /// Returns `null` if no service is active.
  SyncService? get activeService => _activeService;

  /// Sets the active sync service by type.
  ///
  /// Returns `true` if the service was found and activated.
  bool setActiveService(SyncServiceType type) {
    final service = getService(type);
    if (service != null) {
      _activeService = service;
      return true;
    }
    return false;
  }

  /// Clears the active service (reverts to local-only mode).
  void clearActiveService() {
    _activeService = null;
  }

  /// Gets all registered service types.
  List<SyncServiceType> get registeredTypes {
    final types = <SyncServiceType>{};
    types.addAll(_factories.keys);
    types.addAll(_instances.keys);
    return types.toList();
  }

  /// Gets metadata about all available services for display in UI.
  List<SyncServiceInfo> get availableServices {
    return SyncServiceType.values
        .where((type) => type != SyncServiceType.local)
        .map((type) => SyncServiceInfo(
              type: type,
              name: type.displayName,
              icon: type.iconName,
              requiresServerUrl: type.requiresServerUrl,
              usesOAuth: type.usesOAuth,
              isRegistered: _factories.containsKey(type) || _instances.containsKey(type),
            ))
        .toList();
  }

  /// Disposes all cached service instances.
  void dispose() {
    _instances.clear();
    _activeService = null;
  }
}

/// Metadata about a sync service for display in the UI.
class SyncServiceInfo {
  /// Service type.
  final SyncServiceType type;

  /// Display name.
  final String name;

  /// Icon identifier.
  final String icon;

  /// Whether the service requires a server URL.
  final bool requiresServerUrl;

  /// Whether the service uses OAuth authentication.
  final bool usesOAuth;

  /// Whether a service implementation is registered.
  final bool isRegistered;

  const SyncServiceInfo({
    required this.type,
    required this.name,
    required this.icon,
    required this.requiresServerUrl,
    required this.usesOAuth,
    required this.isRegistered,
  });

  /// Description text for the service.
  String get description {
    switch (type) {
      case SyncServiceType.feedbin:
        return 'A fast, simple RSS reader with a clean interface.';
      case SyncServiceType.feedly:
        return 'Organize, read and share content from across the web.';
      case SyncServiceType.inoreader:
        return 'A content reader built for power users.';
      case SyncServiceType.freshRss:
        return 'A free, self-hosted RSS aggregator.';
      case SyncServiceType.reader:
        return 'A self-hosted Google Reader API compatible server.';
      default:
        return '';
    }
  }

  /// Authentication method description.
  String get authDescription {
    if (usesOAuth) return 'Sign in with your account';
    if (requiresServerUrl) return 'Server URL, username & password';
    return 'Email & password';
  }
}
