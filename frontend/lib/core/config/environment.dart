import 'package:flutter/foundation.dart';

enum AppEnv { development, production }

/// Environment Manager for SafeHer-AI.
/// Automatically toggles settings between Development and Production modes.
class Environment {
  Environment._();

  // ─── Production Configurations ─────────────────────────────
  static const String _productionBaseUrl = 'https://abhay-hwe8.onrender.com';
  static const String _productionWsUrl = 'wss://abhay-hwe8.onrender.com';

  // ─── Development Configurations ────────────────────────────
  // For physical device testing, replace '10.106.1.246' with your computer's local IP address if it changes.
  // 127.0.0.1 / localhost only works for Android emulators (use 10.0.2.2 for Android Emulator) or when using USB debugging with adb reverse.
  static const String _developmentBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.106.1.246:3000',
  );
  static const String _developmentWsUrl = String.fromEnvironment(
    'API_WS_URL',
    defaultValue: 'ws://10.106.1.246:3000',
  );

  /// Get current environment based on compilation mode.
  static AppEnv get current {
    if (kReleaseMode) {
      return AppEnv.production;
    }
    return AppEnv.development;
  }

  /// Get base HTTP URL.
  static String get baseUrl => current == AppEnv.production ? _productionBaseUrl : _developmentBaseUrl;

  /// Get base WebSocket URL.
  static String get wsBaseUrl => current == AppEnv.production ? _productionWsUrl : _developmentWsUrl;
}
