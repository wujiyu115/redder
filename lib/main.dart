import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap/reeder_bootstrap.dart';

void main() {
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

  // runApp happens immediately: database/settings initialization runs inside
  // ReederBootstrap so the first frame paints without waiting for it.
  runApp(
    const ProviderScope(
      child: ReederBootstrap(),
    ),
  );
}
