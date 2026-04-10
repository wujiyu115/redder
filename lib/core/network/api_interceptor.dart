import 'package:dio/dio.dart';

/// Request/response interceptor for the Reeder app.
///
/// Handles:
/// - Error logging and transformation
/// - Retry logic for transient failures
/// - Response validation
class ApiInterceptor extends Interceptor {
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Set of HTTP status codes that are retryable.
  static const Set<int> _retryableStatusCodes = {
    408, // Request Timeout
    429, // Too Many Requests
    500, // Internal Server Error
    502, // Bad Gateway
    503, // Service Unavailable
    504, // Gateway Timeout
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Track retry count in options.extra
    options.extra['retryCount'] ??= 0;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Attempt retry for retryable errors
    if (_shouldRetry(err)) {
      final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

      if (retryCount < _maxRetries) {
        // Wait before retrying
        await Future.delayed(_retryDelay * (retryCount + 1));

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          // Create a new Dio instance for retry to avoid interceptor loop
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          // If retry also fails, pass through the error
          handler.next(retryError);
          return;
        }
      }
    }

    // Transform error into a more descriptive message
    handler.next(_transformError(err));
  }

  /// Determines if the error is retryable.
  bool _shouldRetry(DioException err) {
    // Retry on connection errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific HTTP status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && _retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  /// Transforms a [DioException] into a more descriptive error.
  DioException _transformError(DioException err) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server took too long to respond. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timed out while sending data.';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        message = 'Server error ($statusCode). Please try again later.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'An unexpected error occurred: ${err.message}';
        break;
    }

    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: message,
    );
  }
}
