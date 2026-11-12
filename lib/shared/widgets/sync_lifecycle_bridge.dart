import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/background_refresh_service.dart';
import '../../data/services/sync/sync_engine.dart';
import '../../data/services/sync/sync_models.dart';
import '../../features/article_list/article_list_controller.dart';
import '../../features/source_list/source_list_controller.dart';
import '../providers/sync_provider.dart';

/// Keeps an active sync account in step with its server while the app runs.
///
/// Before this widget existed the only way to pull remote changes was a manual
/// refresh: the periodic timer re-fetched every feed's RSS URL directly and
/// nothing happened on launch or on resume, so a Reader / FreshRSS account
/// could sit unnoticed behind its server.
///
/// Responsibilities:
/// - restore + sync on cold start (throttled),
/// - sync when the app returns to the foreground (throttled),
/// - route the periodic [BackgroundRefreshService] tick through a real sync,
/// - flush offline read/star actions as soon as the network comes back,
/// - refresh open timelines once a sync brought changes.
class SyncLifecycleBridge extends ConsumerStatefulWidget {
  const SyncLifecycleBridge({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycleBridge> createState() =>
      _SyncLifecycleBridgeState();
}

class _SyncLifecycleBridgeState extends ConsumerState<SyncLifecycleBridge>
    with WidgetsBindingObserver {
  static const _log = AppLogger('AutoSync');

  /// Do not sync again this soon after a successful one. Keeps app-switching
  /// and rapid launches from hammering the server.
  static const Duration _minGap = Duration(minutes: 1);

  /// Android reports "connected" a beat before the interface can carry
  /// traffic (DHCP, routes). Pushing immediately burns a queue retry, so wait
  /// for the link to settle before flushing.
  static const Duration _reconnectSettleDelay = Duration(seconds: 3);

  /// If the flush still failed (or the link flapped again), try once more.
  static const Duration _reconnectRetryDelay = Duration(seconds: 8);

  late final SyncEngine _engine;

  /// Listens for "network is back" so offline read/star actions get pushed
  /// immediately instead of waiting for the next resume / timer tick.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Guards against overlapping runs (timer tick + resume + startup).
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(syncEngineProvider);
    _engine.onSyncCompleted = _onSyncCompleted;

    WidgetsBinding.instance.addObserver(this);
    BackgroundRefreshService.setSyncHandler(_onPeriodicTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncIfStale(reason: 'startup'));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncIfStale(reason: 'resume'));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundRefreshService.setSyncHandler(null);
    final subscription = _connectivitySub;
    _connectivitySub = null;
    unawaited(subscription?.cancel());
    _engine.onSyncCompleted = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  /// Periodic tick handler for [BackgroundRefreshService].
  ///
  /// Returns `true` when a remote account handled the tick, so the service
  /// skips its plain-RSS fallback.
  Future<bool> _onPeriodicTick() async {
    if (await _activeAccount() == null) return false;
    await _runSync(reason: 'periodic');
    return true;
  }

  /// Syncs only when the last successful sync is older than [_minGap].
  Future<void> _syncIfStale({required String reason}) async {
    // Respect the "manual refresh only" setting: 0 disables automatic sync.
    if (!await _autoRefreshEnabled()) {
      _log.info('$reason: automatic refresh disabled, skipping');
      return;
    }

    final account = await _activeAccount();
    if (account == null) {
      _log.info('$reason: no active sync account, skipping');
      return;
    }

    final lastSyncAt = account.lastSyncAt;
    if (lastSyncAt != null) {
      final age = DateTime.now().difference(lastSyncAt);
      if (age < _minGap) {
        _log.info('$reason: synced ${age.inSeconds}s ago, skipping');
        return;
      }
    }

    await _runSync(reason: reason);
  }

  Future<void> _runSync({required String reason}) async {
    if (_running || _engine.currentStatus == SyncStatus.syncing) {
      _log.info('$reason: sync already running, skipping');
      return;
    }

    _running = true;
    final stopwatch = Stopwatch()..start();
    try {
      final result = await _engine.sync();
      _log.info(
        '$reason: sync finished in ${stopwatch.elapsedMilliseconds}ms — $result',
      );
    } catch (e) {
      // Network/auth hiccups must never break app startup or resume.
      _log.error('$reason: sync failed', error: e);
    } finally {
      _running = false;
    }
  }

  Future<SyncAccountInfo?> _activeAccount() async {
    try {
      final account = await ref.read(syncRepositoryProvider).getActiveAccount();
      // Only accounts with a remote backend can produce queued actions, so
      // subscribe lazily — and only once.
      if (account != null) _ensureReconnectListener();
      return account;
    } catch (e) {
      _log.error('activeAccount: lookup failed', error: e);
      return null;
    }
  }

  /// Subscribes to connectivity changes the first time an account is seen.
  void _ensureReconnectListener() {
    if (_connectivitySub != null || !mounted) return;
    try {
      _connectivitySub = Connectivity().onConnectivityChanged.listen(
        (results) {
          final online = !results.contains(ConnectivityResult.none);
          if (online) unawaited(_flushPendingState(reason: 'reconnect'));
        },
        onError: (Object e) => _log.error(
          'connectivity stream failed',
          error: e,
        ),
      );
    } catch (e) {
      // Platform without connectivity support — resume / timer still cover us.
      _log.error('connectivity listener unavailable', error: e);
    }
  }

  /// Pushes read/star actions that were recorded while offline.
  ///
  /// Runs even when automatic refresh is set to manual: those actions are the
  /// user's own writes, and dropping them silently loses reading progress.
  Future<void> _flushPendingState({required String reason}) async {
    final account = await _activeAccount();
    if (account == null) return;

    final pending = await _pendingCount(account.id, reason: reason);
    if (pending == null || pending == 0) return;

    // Two attempts: the network may still be settling right after the event,
    // and a failed push increments the queue retry counter.
    for (var attempt = 1; attempt <= 2; attempt++) {
      await Future<void>.delayed(
        attempt == 1 ? _reconnectSettleDelay : _reconnectRetryDelay,
      );
      if (!mounted) return;

      final remaining = await _pendingCount(account.id, reason: reason);
      if (remaining == null || remaining == 0) return;

      _log.info('$reason: flushing $remaining pending state change(s)');
      await _runSync(reason: reason);
    }
  }

  /// Pending queue size, or null when it cannot be read right now.
  Future<int?> _pendingCount(int accountId, {required String reason}) async {
    try {
      return await ref.read(syncQueueProvider).getQueueSize(accountId);
    } catch (e) {
      _log.error('$reason: queue lookup failed', error: e);
      return null;
    }
  }

  Future<bool> _autoRefreshEnabled() async {
    try {
      final settings = await SettingsRepository().getSettings();
      return settings.autoRefreshIntervalMinutes > 0;
    } catch (e) {
      _log.error('autoRefreshEnabled: settings lookup failed', error: e);
      return true;
    }
  }

  /// A sync brought data in — reload the timelines that are already built.
  void _onSyncCompleted() {
    if (!mounted) return;
    ref.invalidate(sourceListControllerProvider);
    ref.invalidate(articleListControllerProvider);
  }
}
