import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';
import 'package:reeder/data/services/auth/auth_service.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';
import 'package:reeder/data/services/sync/sync_service.dart';
import 'package:reeder/data/services/sync/sync_service_registry.dart';

@GenerateMocks([
  SyncServiceRegistry,
  SyncLocalDataSource,
  SyncQueue,
  SyncService,
  AuthService,
  FlutterSecureStorage,
  Connectivity,
])
void main() {}
