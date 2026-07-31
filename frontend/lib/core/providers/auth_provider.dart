import 'package:flutter/material.dart';
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
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
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
  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
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

  /// Log out and clear all auth data.
  Future<void> logout() async {
    await _storage.clearAuthData();
    _user = null;
    _setState(AuthState.unauthenticated);
  }

  String _parseError(dynamic e) {
    if (e.toString().contains('401')) return 'Invalid email or password';
    if (e.toString().contains('409')) return 'Email already registered';
    if (e.toString().contains('SocketException')) return 'No internet connection';
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
