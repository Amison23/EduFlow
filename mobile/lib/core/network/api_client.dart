import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// HTTP client wrapper using Dio
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add Retry Interceptor
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Add auth token if available
    if (_authToken != null) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }
    
    // Log request details
    if (kDebugMode) {
      print('[API_CLIENT] Request: ${options.method} ${options.baseUrl}${options.path}');
      if (options.queryParameters.isNotEmpty) {
        print('[API_CLIENT] Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        print('[API_CLIENT] Body: ${options.data}');
      }
    }
    
    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final exception = _mapDioException(error);
    
    // Log connectivity status
    if (kDebugMode) {
      try {
        final connectivityResults = await Connectivity().checkConnectivity();
        print('[API_CLIENT] Connectivity Status: $connectivityResults');
      } catch (e) {
        print('[API_CLIENT] Could not check connectivity: $e');
      }
    }

    // Log error details
    if (kDebugMode) {
      print('[API_CLIENT] Error: ${error.type}');
      print('[API_CLIENT] Message: ${error.message}');
      if (error.response != null) {
        print('[API_CLIENT] Status: ${error.response?.statusCode}');
        print('[API_CLIENT] Data: ${error.response?.data}');
      }
    }
    
    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        error: exception,
        type: error.type,
        response: error.response,
      ),
    );
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timed out',
          code: 'TIMEOUT',
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection',
          code: 'NO_CONNECTION',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, error);
      case DioExceptionType.cancel:
        return NetworkException(
          'Request cancelled',
          code: 'CANCELLED',
          originalError: error,
        );
      default:
        return NetworkException(
          error.message ?? 'Unknown network error',
          code: 'UNKNOWN',
          originalError: error,
        );
    }
  }

  AppException _handleStatusCode(int? statusCode, DioException error) {
    switch (statusCode) {
      case 400:
        return ServerException(
          'Bad request',
          statusCode: statusCode,
          code: 'BAD_REQUEST',
          originalError: error,
        );
      case 401:
        return AuthException(
          'Unauthorized',
          code: 'UNAUTHORIZED',
          originalError: error,
        );
      case 403:
        return AuthException(
          'Forbidden',
          code: 'FORBIDDEN',
          originalError: error,
        );
      case 404:
        return ServerException(
          'Not found',
          statusCode: statusCode,
          code: 'NOT_FOUND',
          originalError: error,
        );
      case 429:
        return ServerException(
          'Too many requests',
          statusCode: statusCode,
          code: 'RATE_LIMITED',
          originalError: error,
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          'Server error',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
          originalError: error,
        );
      default:
        return ServerException(
          'Unknown error',
          statusCode: statusCode,
          code: 'UNKNOWN',
          originalError: error,
        );
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Download file
  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// Dynamic retry interceptor to handle connection issues
class _RetryInterceptor extends Interceptor {
  final Dio dio;

  _RetryInterceptor(this.dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final int retryCount = (extra['retryCount'] as int? ?? 0);
    const maxRetries = ApiConstants.maxRetries;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      final newRetryCount = retryCount + 1;
      
      // Exponential backoff: retryDelay * 2^retryCount (e.g., 2s, 4s, 8s)
      final delay = ApiConstants.retryDelay * (1 << retryCount);
      
      if (kDebugMode) {
        print('[API_CLIENT] Retrying request ($newRetryCount/$maxRetries) in ${delay.inSeconds}s... Path: ${err.requestOptions.path}');
      }
      
      try {
        await Future.delayed(delay);
        
        // Update extra with new retry count
        final options = err.requestOptions;
        options.extra['retryCount'] = newRetryCount;

        final response = await dio.request(
          options.path,
          queryParameters: options.queryParameters,
          data: options.data,
          options: Options(
            method: options.method,
            headers: options.headers,
            extra: options.extra,
            responseType: options.responseType,
            contentType: options.contentType,
            validateStatus: options.validateStatus,
            receiveTimeout: options.receiveTimeout,
            sendTimeout: options.sendTimeout,
          ),
        );
        return handler.resolve(response);
      } catch (e) {
        // If the retry itself throws (and it's not handled by the next interceptor),
        // we should let it propagate or try to handle it.
        // Usually, the next call to dio.request will also go through this interceptor
        // if it fails, assuming it doesn't infinite loop. 
        // But since we are inside onError, we already have a failure.
        return super.onError(err, handler);
      }
    }
    
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Retry on most network issues and specific server errors
    return err.type == DioExceptionType.connectionError ||
           err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           (err.response?.statusCode != null && 
            (err.response!.statusCode! == 503 || 
             err.response!.statusCode! == 504 ||
             err.response!.statusCode! == 502));
  }
}
