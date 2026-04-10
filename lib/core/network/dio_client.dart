import 'package:dio/dio.dart';

import 'api_interceptor.dart';

/// Dio HTTP client wrapper for the Reeder app.
///
/// Provides a pre-configured [Dio] instance with:
/// - Timeout settings
/// - Retry logic
/// - HTTPS enforcement
/// - Custom interceptors
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Reeder/1.0 (Flutter)',
        },
      ),
    );

    _dio.interceptors.addAll([
      ApiInterceptor(),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) {
          // Use dart:developer log in debug mode
          assert(() {
            // ignore: avoid_print
            print('[DioClient] $obj');
            return true;
          }());
        },
      ),
    ]);
  }

  /// Returns the singleton instance.
  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  /// The underlying [Dio] instance.
  Dio get dio => _dio;

  /// Performs a GET request.
  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Fetches raw bytes (for downloading feed icons, etc.).
  Future<Response<List<int>>> getBytes(
    String url, {
    CancelToken? cancelToken,
  }) {
    return _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
      cancelToken: cancelToken,
    );
  }

  /// Fetches content as a plain string.
  Future<String> getString(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
      cancelToken: cancelToken,
    );
    return response.data ?? '';
  }
}
