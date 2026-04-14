import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:reeder/core/network/dio_client.dart';
import 'package:reeder/data/datasources/local/article_local_ds.dart';
import 'package:reeder/data/datasources/local/feed_local_ds.dart';
import 'package:reeder/data/datasources/local/settings_local_ds.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';
import 'package:reeder/data/datasources/remote/rss_remote_ds.dart';
import 'package:reeder/data/repositories/article_repository.dart';
import 'package:reeder/data/repositories/feed_repository.dart';
import 'package:reeder/data/repositories/settings_repository.dart';
import 'package:reeder/data/repositories/tag_repository.dart';
import 'package:reeder/data/services/auth/auth_service.dart';
import 'package:reeder/data/services/feed_discovery_service.dart';
import 'package:reeder/data/services/feed_refresh_service.dart';
import 'package:reeder/data/services/podcast_service.dart';
import 'package:reeder/data/services/reader_view_service.dart';
import 'package:reeder/data/services/scroll_position_service.dart';
import 'package:reeder/data/services/sync/sync_bridge.dart';
import 'package:reeder/data/services/sync/sync_engine.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';
import 'package:reeder/data/services/sync/sync_service.dart';
import 'package:reeder/data/services/sync/sync_service_registry.dart';

@GenerateMocks([
  // Existing mocks
  SyncServiceRegistry,
  SyncLocalDataSource,
  SyncQueue,
  SyncService,
  AuthService,
  FlutterSecureStorage,
  Connectivity,
  // Repository layer
  FeedRepository,
  ArticleRepository,
  SettingsRepository,
  TagRepository,
  // DataSource layer
  ArticleLocalDataSource,
  FeedLocalDataSource,
  SettingsLocalDataSource,
  RssRemoteDataSource,
  // Service layer
  SyncBridge,
  SyncEngine,
  FeedRefreshService,
  FeedDiscoveryService,
  ScrollPositionService,
  ReaderViewService,
  PodcastService,
  // Network layer
  DioClient,
])
void main() {}
