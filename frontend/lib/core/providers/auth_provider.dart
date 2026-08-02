import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../constants/api_constants.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/emergency_contact_model.dart';

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
      // Load cached profile instantly if available so user stays logged in offline/during cold starts
      final cachedProfile = await _storage.getUserProfile();
      if (cachedProfile != null) {
        try {
          _user = UserModel.fromJson(jsonDecode(cachedProfile) as Map<String, dynamic>);
          _setState(AuthState.authenticated);
        } catch (e) {
          debugPrint('[Auth] Error parsing cached profile: $e');
        }
      }

      if (_user == null) {
        final userId = await _storage.getUserId() ?? 'offline-user';
        _user = UserModel(id: userId, name: 'SafeHer User', phone: '', email: '');
        _setState(AuthState.authenticated);
      }

      // Perform server refresh asynchronously without blocking app startup!
      _apiClient.get(ApiConstants.userProfile).then((response) async {
        _user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await _storage.setUserProfile(jsonEncode(_user!.toJson()));
        notifyListeners();
      }).catchError((e) async {
        debugPrint('[Auth] Background sync check failed: $e');
        if (e is DioException && (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
          await _storage.clearAuthData();
          _user = null;
          _setState(AuthState.unauthenticated);
        }
      });
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
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));

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
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));

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

  /// Real-time addition of emergency contact
  Future<bool> addEmergencyContact({
    required String name,
    required String phone,
    String email = '',
    String relationship = 'Guardian',
  }) async {
    if (_user == null) return false;

    final newContact = EmergencyContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      relationship: relationship,
    );

    final updatedContacts = [..._user!.emergencyContacts, newContact];
    _user = _user!.copyWith(emergencyContacts: updatedContacts);
    await _storage.setUserProfile(jsonEncode(_user!.toJson()));
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.userContacts,
        data: {
          'emergencyContacts': updatedContacts.map((e) => e.toJson()).toList(),
        },
      );
      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] Backend sync failed, kept in local real-time storage: $e');
    }
    return true;
  }

  /// Real-time removal of emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    if (_user == null) return false;

    final updatedContacts = _user!.emergencyContacts
        .where((c) => c.id != contactId && c.name != contactId)
        .toList();
    _user = _user!.copyWith(emergencyContacts: updatedContacts);
    await _storage.setUserProfile(jsonEncode(_user!.toJson()));
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.userContacts,
        data: {
          'emergencyContacts': updatedContacts.map((e) => e.toJson()).toList(),
        },
      );
      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] Backend removal sync failed: $e');
    }
    return true;
  }

  /// Real-time update of profile image (base64 string or custom avatar icon)
  Future<bool> updateProfileImage(String imageStr) async {
    if (_user == null) return false;
    _user = _user!.copyWith(profileImage: imageStr);
    await _storage.setUserProfile(jsonEncode(_user!.toJson()));
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.userProfile,
        data: {'profileImage': imageStr},
      );
      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] Profile image backend sync failed: $e');
    }
    return true;
  }

  /// Real-time update of user profile details (Name, Phone, Blood Group, Medical Notes, Safe Zone)
  Future<bool> updateProfileDetails({
    required String name,
    required String phone,
    String? bloodGroup,
    String? medicalNotes,
    String? homeSafeZone,
  }) async {
    if (_user == null) return false;
    _user = _user!.copyWith(
      name: name,
      phone: phone,
      bloodGroup: bloodGroup,
      medicalNotes: medicalNotes,
      homeSafeZone: homeSafeZone,
    );
    await _storage.setUserProfile(jsonEncode(_user!.toJson()));
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.userProfile,
        data: {
          'name': name,
          'phone': phone,
          'bloodGroup': bloodGroup,
          'medicalNotes': medicalNotes,
          'homeSafeZone': homeSafeZone,
        },
      );
      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] Profile details backend sync failed: $e');
    }
    return true;
  }

  /// Real-time update of AI sensitivity & detection sensor settings
  Future<bool> updateAiSettings(AiSettings settings) async {
    if (_user == null) return false;
    _user = _user!.copyWith(aiSettings: settings);
    await _storage.setUserProfile(jsonEncode(_user!.toJson()));
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.userAiSettings,
        data: settings.toJson(),
      );
      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storage.setUserProfile(jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] AI settings backend sync failed: $e');
    }
    return true;
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
