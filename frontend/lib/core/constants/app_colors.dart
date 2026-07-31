import 'package:flutter/material.dart';

/// Centralized color palette for SafeHer-AI.
/// Premium dark theme with safety-branded identity.
class AppColors {
  AppColors._();

  // ─── Brand Primary ─────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);        // Guardian purple
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);

  // ─── Emergency / SOS ───────────────────────────────────────
  static const Color emergency = Color(0xFFFF3B5C);       // Vivid emergency red
  static const Color emergencyLight = Color(0xFFFF6B84);
  static const Color emergencyDark = Color(0xFFCC2F4A);
  static const Color sosPulse = Color(0xFFFF1744);         // SOS button pulse

  // ─── Safety Indicators ─────────────────────────────────────
  static const Color safe = Color(0xFF00E676);             // Bright safe green
  static const Color safeDark = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);          // Amber warning
  static const Color warningLight = Color(0xFFFFD740);
  static const Color danger = Color(0xFFFF5252);           // Danger red

  // ─── Dark Theme Surface Palette ────────────────────────────
  static const Color background = Color(0xFF0A0E21);       // Deep navy background
  static const Color surface = Color(0xFF1A1F38);          // Card surfaces
  static const Color surfaceLight = Color(0xFF252B48);     // Elevated surfaces
  static const Color surfaceBorder = Color(0xFF2E3456);    // Subtle borders

  // ─── Text Colors ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F7);      // Primary white text
  static const Color textSecondary = Color(0xFFB0B3C5);    // Secondary grey text
  static const Color textTertiary = Color(0xFF6B7090);     // Muted text
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Functional Colors ─────────────────────────────────────
  static const Color accent = Color(0xFF00BCD4);           // Cyan accent
  static const Color accentLight = Color(0xFF4DD0E1);
  static const Color info = Color(0xFF448AFF);             // Info blue
  static const Color success = Color(0xFF69F0AE);          // Success green

  // ─── Glassmorphism ─────────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);       // 10% white
  static const Color glassBorder = Color(0x33FFFFFF);      // 20% white border
  static const Color glassOverlay = Color(0x0DFFFFFF);     // 5% white

  // ─── Gradient Presets ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF5B52E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [emergency, Color(0xFFE91E63)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [safe, Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFF0D1229)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, Color(0xFF1E2445)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Risk Score Color Mapping ──────────────────────────────
  static Color riskColor(int score) {
    if (score <= 3) return safe;
    if (score <= 5) return warning;
    if (score <= 7) return Color(0xFFFF9100);
    return danger;
  }
}
