import '../config/environment.dart';

/// API constants and endpoint definitions for SafeHer-AI.
class ApiConstants {
  ApiConstants._();

  // ─── Base Configuration ────────────────────────────────────
  static String get baseUrl => Environment.baseUrl;
  static const String apiVersion = '/api';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // ─── WebSocket ─────────────────────────────────────────────
  static String get wsBaseUrl => Environment.wsBaseUrl;
  static String get wsLiveTracking => '$wsBaseUrl/tracking';

  // ─── Auth Endpoints ────────────────────────────────────────
  static String get login => '$apiBaseUrl/auth/login';
  static String get register => '$apiBaseUrl/auth/register';
  static String get refreshToken => '$apiBaseUrl/auth/refresh';

  // ─── SOS Endpoints ─────────────────────────────────────────
  static String get sosTrigger => '$apiBaseUrl/sos/trigger';
  static String get sosActive => '$apiBaseUrl/sos/active';
  static String sosResolve(String id) => '$apiBaseUrl/sos/$id/resolve';

  // ─── User Endpoints ────────────────────────────────────────
  static String get userProfile => '$apiBaseUrl/users/profile';
  static String get userContacts => '$apiBaseUrl/users/contacts';
  static String get userAiSettings => '$apiBaseUrl/users/ai-settings';
  static String get userFcmToken => '$apiBaseUrl/users/fcm-token';

  // ─── Incident Endpoints ────────────────────────────────────
  static String get incidents => '$apiBaseUrl/incidents';
  static String incidentDetail(String id) => '$apiBaseUrl/incidents/$id';
  static String incidentMedia(String id) => '$apiBaseUrl/incidents/$id/media';

  // ─── Safety Endpoints ──────────────────────────────────────
  static String get safetyZones => '$apiBaseUrl/safety/zones';
  static String get safetyRoute => '$apiBaseUrl/safety/route';
  static String get safetyReport => '$apiBaseUrl/safety/report';

  // ─── Health Check ──────────────────────────────────────────
  static String get healthCheck => '$apiBaseUrl/health';

  // ─── Timeouts ──────────────────────────────────────────────
  // Render free-tier cold starts can take 30–50 s, so we need generous timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sosTimeout = Duration(seconds: 10); // SOS must be fast

  // ─── Storage Keys ──────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompleteKey = 'onboarding_complete';
}
