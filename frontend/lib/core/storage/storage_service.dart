import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Abstraction over secure and general-purpose local storage.
/// Uses `flutter_secure_storage` for sensitive data (tokens)
/// and `shared_preferences` for non-sensitive preferences.
class StorageService {
  final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  bool _initialized = false;

  StorageService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Must be called before using any methods.
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ─── Auth Tokens (Secure) ──────────────────────────────────

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: ApiConstants.tokenKey);
  }

  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: ApiConstants.tokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: ApiConstants.refreshTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: ApiConstants.refreshTokenKey, value: token);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: ApiConstants.tokenKey);
    await _secureStorage.delete(key: ApiConstants.refreshTokenKey);
    await _secureStorage.delete(key: ApiConstants.userIdKey);
    await _secureStorage.delete(key: 'user_profile_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ─── User ID & Profile (Secure) ─────────────────────────────

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: ApiConstants.userIdKey);
  }

  Future<void> setUserId(String userId) async {
    await _secureStorage.write(key: ApiConstants.userIdKey, value: userId);
  }

  Future<String?> getUserProfile() async {
    return await _secureStorage.read(key: 'user_profile_data');
  }

  Future<void> setUserProfile(String jsonStr) async {
    await _secureStorage.write(key: 'user_profile_data', value: jsonStr);
  }

  // ─── Onboarding (Non-Sensitive) ────────────────────────────

  bool get isOnboardingComplete {
    return _prefs.getBool(ApiConstants.onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(ApiConstants.onboardingCompleteKey, value);
  }

  // ─── AI Settings (Non-Sensitive) ───────────────────────────

  double get voiceSensitivity {
    return _prefs.getDouble('voice_sensitivity') ?? 0.75;
  }

  Future<void> setVoiceSensitivity(double value) async {
    await _prefs.setDouble('voice_sensitivity', value);
  }

  double get motionSensitivity {
    return _prefs.getDouble('motion_sensitivity') ?? 0.7;
  }

  Future<void> setMotionSensitivity(double value) async {
    await _prefs.setDouble('motion_sensitivity', value);
  }

  bool get isVoiceDetectionEnabled {
    return _prefs.getBool('voice_detection_enabled') ?? true;
  }

  Future<void> setVoiceDetectionEnabled(bool value) async {
    await _prefs.setBool('voice_detection_enabled', value);
  }

  bool get isMotionDetectionEnabled {
    return _prefs.getBool('motion_detection_enabled') ?? true;
  }

  Future<void> setMotionDetectionEnabled(bool value) async {
    await _prefs.setBool('motion_detection_enabled', value);
  }

  // ─── General Preferences ───────────────────────────────────

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Wipe all data (logout).
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
