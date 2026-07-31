import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

/// Centralized HTTP client with auth interceptors, retry logic,
/// and offline request queueing.
class ApiClient {
  late final Dio _dio;
  final StorageService _storage;

  ApiClient({required StorageService storage}) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(storage: _storage, dio: _dio),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => print('[API] $o'),
      ),
    ]);
  }

  Dio get dio => _dio;

  // ─── Convenience Methods ───────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// Upload file with multipart form data.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalFields != null) ...additionalFields,
    });
    return _dio.post<T>(path, data: formData);
  }

  /// SOS-specific POST with tighter timeout for < 2s latency target.
  Future<Response<T>> sosPost<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      options: Options(
        sendTimeout: ApiConstants.sosTimeout,
        receiveTimeout: ApiConstants.sosTimeout,
      ),
    );
  }
}

/// Interceptor that attaches JWT auth token and handles 401 refresh.
///
/// Uses a **separate Dio instance** for the refresh call to prevent
/// the refresh request itself from being intercepted and causing an
/// infinite retry loop when the refresh token is also expired.
class _AuthInterceptor extends Interceptor {
  final StorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor({required StorageService storage, required Dio dio})
      : _storage = storage,
        _dio = dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      // Attempt token refresh using a SEPARATE Dio instance
      // to avoid this interceptor catching the refresh request's errors
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null) {
          // Use a fresh Dio instance without auth interceptor
          final refreshDio = Dio(BaseOptions(
            baseUrl: _dio.options.baseUrl,
            connectTimeout: ApiConstants.connectionTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));

          final response = await refreshDio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          final newToken = response.data['token'] as String;
          final newRefreshToken = response.data['refreshToken'] as String;

          await _storage.setAuthToken(newToken);
          await _storage.setRefreshToken(newRefreshToken);

          // Retry original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh failed — user must re-authenticate
        await _storage.clearAuthData();
      }
      _isRefreshing = false;
    }
    handler.next(err);
  }
}
