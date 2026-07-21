import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stable cache key. Also the on-disk subdirectory name under the
/// platform's temporary directory (`<tempDir>/reederImageCache`) and the
/// sqlite database name used by [CacheObjectProvider].
const _kCacheKey = 'reederImageCache';

/// Custom image cache manager for article/feed images.
///
/// All `CachedNetworkImage` widgets that opt in share this single on-disk
/// cache directory and sqlite metadata index.
///
/// `flutter_cache_manager` only enforces [Config.stalePeriod] (file age) and
/// [Config.maxNrOfCacheObjects] (file count) natively — it does NOT cap by
/// total bytes. [enforceSizeCap] adds a best-effort byte ceiling on top.
class ReederImageCacheManager extends CacheManager {
  ReederImageCacheManager._()
      : super(
          Config(
            _kCacheKey,
            stalePeriod: const Duration(days: 30),
            maxNrOfCacheObjects: 1000,
          ),
        );

  /// Process-wide singleton. [CacheManager] should only be instantiated
  /// once per cache key (it owns a sqlite connection + directory).
  static final ReederImageCacheManager instance = ReederImageCacheManager._();

  /// Best-effort byte cap on the image cache directory.
  ///
  /// Walks `<tempDir>/reederImageCache`, sums file sizes, and deletes the
  /// oldest files (by lastModified) until the total is under [maxBytes].
  ///
  /// ponytail: not transactional — a concurrent writer can re-create files
  /// between stat and delete, so the cap is approximate, not exact. Also
  /// ignores the sqlite metadata index (orphan rows stay until the next
  /// stale-period sweep). Good enough for a user-facing quota; upgrade to a
  /// transactional LRU tied to the cache store if a hard byte ceiling is
  /// required.
  Future<void> enforceSizeCap(int maxBytes) async {
    if (maxBytes <= 0) return;
    try {
      final dir = await _cacheDirectory();
      if (!await dir.exists()) return;

      // file → size in bytes
      final files = <File, int>{};
      await for (final entity
          in dir.list(recursive: false, followLinks: false)) {
        if (entity is File) {
          try {
            files[entity] = await entity.length();
          } catch (_) {
            // File vanished mid-scan; skip.
          }
        }
      }

      var total = files.values.fold<int>(0, (a, b) => a + b);
      if (total <= maxBytes) return;

      // Sort oldest first.
      final statted = <(File, DateTime)>[];
      for (final f in files.keys) {
        try {
          statted.add((f, f.statSync().modified));
        } catch (_) {
          // File vanished; skip.
        }
      }
      statted.sort((a, b) => a.$2.compareTo(b.$2));

      for (final entry in statted) {
        if (total <= maxBytes) break;
        final size = files[entry.$1] ?? 0;
        try {
          await entry.$1.delete();
          total -= size;
        } catch (_) {
          // Ignore failures on individual deletes.
        }
      }
    } catch (e, st) {
      developer.log(
        'enforceSizeCap failed: $e',
        name: 'Reeder.ImageCache',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<Directory> _cacheDirectory() async {
    final base = await getTemporaryDirectory();
    return Directory(p.join(base.path, _kCacheKey));
  }
}

/// Singleton provider for the reeder image cache manager.
final reederImageCacheManagerProvider = Provider<ReederImageCacheManager>(
  (_) => ReederImageCacheManager.instance,
);
