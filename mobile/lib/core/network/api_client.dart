import 'package:dio/dio.dart';
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
    
    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  void _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    final exception = _mapDioException(error);
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
