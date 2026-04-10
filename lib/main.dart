import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'data/services/background_refresh_service.dart';

void main() async {
  // Track cold start time
  final startTime = DateTime.now();

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Drift (SQLite) database
  await AppDatabase.initialize();

  // Initialize background refresh
  await BackgroundRefreshService.initialize();

  // Log cold start duration
  final startDuration = DateTime.now().difference(startTime);
  developer.log(
    'Cold start completed in ${startDuration.inMilliseconds}ms',
    name: 'Reeder.Startup',
  );

  runApp(
    const ProviderScope(
      child: ReederApp(),
    ),
  );
}
