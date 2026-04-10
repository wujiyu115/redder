import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current network connectivity status.
///
/// Returns `true` if the device has an active network connection
/// (WiFi, mobile data, or ethernet), `false` otherwise.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>(
  (ref) => ConnectivityNotifier(),
);

/// Provider that exposes the connectivity type.
final connectivityTypeProvider =
    Provider<List<ConnectivityResult>>((ref) {
  final notifier = ref.watch(connectivityProvider.notifier);
  return notifier.currentTypes;
});

/// Notifier that monitors network connectivity changes.
class ConnectivityNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _currentTypes = [];

  /// The current connectivity types.
  List<ConnectivityResult> get currentTypes => _currentTypes;

  ConnectivityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    // Check initial connectivity
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(results);
    } catch (_) {
      state = true; // Assume connected on error
    }

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> results) {
    _currentTypes = results;
    state = results.any((r) => r != ConnectivityResult.none);
  }

  /// Manually checks the current connectivity status.
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(results);
      return state;
    } catch (_) {
      return state;
    }
  }

  /// Whether the device is connected via WiFi.
  bool get isWifi => _currentTypes.contains(ConnectivityResult.wifi);

  /// Whether the device is connected via mobile data.
  bool get isMobile => _currentTypes.contains(ConnectivityResult.mobile);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
