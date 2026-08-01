import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../constants/api_constants.dart';
import '../../shared/models/user_model.dart';

/// Authentication state management.
///
/// Handles login, registration, token persistence,
/// and session lifecycle.
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storage;

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _error;

  AuthProvider({
    required ApiClient apiClient,
    required StorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Check if user is already logged in (on app start).
  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);

    final isLoggedIn = await _storage.isLoggedIn();
    if (isLoggedIn) {
      // Try to fetch user profile
      try {
        final response = await _apiClient.get(ApiConstants.userProfile);
        _user = UserModel.fromJson(response.data as Map<String, dynamic>);
        _setState(AuthState.authenticated);
      } catch (e) {
        // Token might be expired
        await _storage.clearAuthData();
        _setState(AuthState.unauthenticated);
      }
    } else {
      _setState(AuthState.unauthenticated);
    }
  }

  /// Log in with email and password.
  /// Retries once on timeout (handles Render cold starts).
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _postWithRetry(
        ApiConstants.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Check for error in the response body
      if (data.containsKey('error')) {
        _error = data['error'].toString();
        _setState(AuthState.unauthenticated);
        return false;
      }

      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final userData = data['user'] as Map<String, dynamic>;

      // Persist auth data
      await _storage.setAuthToken(token);
      if (refreshToken != null) {
        await _storage.setRefreshToken(refreshToken);
      }

      _user = UserModel.fromJson(userData);
      await _storage.setUserId(_user!.id);

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  /// Register a new user.
  /// Retries once on timeout (handles Render cold starts).
  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _postWithRetry(
        ApiConstants.register,
        data: {
          'name': name.trim(),
          'phone': phone.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Check for error in the response body
      if (data.containsKey('error')) {
        _error = data['error'].toString();
        _setState(AuthState.unauthenticated);
        return false;
      }

      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final userData = data['user'] as Map<String, dynamic>;

      await _storage.setAuthToken(token);
      if (refreshToken != null) {
        await _storage.setRefreshToken(refreshToken);
      }

      _user = UserModel.fromJson(userData);
      await _storage.setUserId(_user!.id);

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  /// POST with automatic retry on timeout or connection error.
  /// Handles Render free-tier cold starts which can take 30-50 seconds.
  Future<Response> _postWithRetry(
    String path, {
    dynamic data,
    int maxRetries = 2,
  }) async {
    DioException? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('[Auth] Attempt $attempt/$maxRetries for $path');
        final response = await _apiClient.post(path, data: data);
        return response;
      } on DioException catch (e) {
        lastError = e;
        debugPrint('[Auth] Attempt $attempt failed: ${e.type} - ${e.message}');

        // Only retry on timeout or connection errors (server might be waking up)
        final isRetryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError;

        if (!isRetryable || attempt >= maxRetries) {
          rethrow;
        }

        // Brief pause before retry
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    throw lastError!;
  }

  /// Log out and clear all auth data.
  Future<void> logout() async {
    await _storage.clearAuthData();
    _user = null;
    _setState(AuthState.unauthenticated);
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Server is starting up. Please wait a moment and try again.';
      }
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('error')) {
        // If it's a validation error with details
        if (responseData.containsKey('details')) {
          final details = responseData['details'];
          if (details is List && details.isNotEmpty) {
            return details.map((d) => d['message']).join('\n');
          }
        }
        return responseData['error'].toString();
      }
      if (e.response?.statusCode == 401) return 'Invalid email or password';
      if (e.response?.statusCode == 409) return 'Email already registered';
      if (e.response?.statusCode == 400) return 'Validation failed. Please check input.';
      if (e.response?.statusCode == 429) return 'Too many attempts. Please wait and try again.';
      if (e.response?.statusCode == 500) return 'Server error. Please try again in a moment.';
    }
    if (e.toString().contains('SocketException')) return 'No internet connection';
    debugPrint('[Auth] Unhandled error: $e');
    return 'Something went wrong. Please try again.';
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
}
