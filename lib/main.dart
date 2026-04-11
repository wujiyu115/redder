import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'data/services/background_refresh_service.dart';

void main() async {
  // Track cold start time
  final startTime = DateTime.now();

  WidgetsFlutterBinding.ensureInitialized();

  // Silence image loading HTTP errors (e.g. 403 from CDN)
  // These are already handled by CachedNetworkImage's errorWidget,
  // but Flutter's Image Resource Service still logs them as exceptions.
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final exception = details.exception;
    if (exception is HttpException &&
        details.library == 'image resource service') {
      developer.log(
        'Image load failed: ${exception.message}',
        name: 'Reeder.Image',
      );
      return;
    }
    originalOnError?.call(details);
  };

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
