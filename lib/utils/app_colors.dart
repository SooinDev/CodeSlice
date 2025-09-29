import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF0969DA);
  static const Color primaryLight = Color(0xFF1F8AE8);
  static const Color primaryDark = Color(0xFF0550B3);

  // Status Colors
  static const Color success = Color(0xFF1F8959);
  static const Color warning = Color(0xFFFB8500);
  static const Color error = Color(0xFFDA3633);
  static const Color info = Color(0xFF8957E5);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFBFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF24292F);
  static const Color lightTextSecondary = Color(0xFF656D76);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightBorderSubtle = Color(0xFFE1E4E8);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF21262D);
  static const Color darkCardBackground = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkBorderSubtle = Color(0xFF21262D);

  // Semantic Colors
  static const Color accent = Color(0xFF0969DA);
  static const Color highlight = Color(0xFFFFF8DC);
  static const Color overlay = Color(0x80000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF0969DA),
    Color(0xFF1F8AE8),
  ];

  static const List<Color> successGradient = [
    Color(0xFF1F8959),
    Color(0xFF2EA16F),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFB8500),
    Color(0xFFFFB347),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFDA3633),
    Color(0xFFFF6B6B),
  ];

  // Helper methods
  static Color getBackgroundColor(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color getSurfaceColor(bool isDark) =>
      isDark ? darkSurface : lightSurface;

  static Color getCardBackgroundColor(bool isDark) =>
      isDark ? darkCardBackground : lightCardBackground;

  static Color getTextPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  static Color getTextSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color getBorderColor(bool isDark) =>
      isDark ? darkBorder : lightBorder;

  static Color getBorderSubtleColor(bool isDark) =>
      isDark ? darkBorderSubtle : lightBorderSubtle;

  // Type-specific colors
  static Color getQRTypeColor(String type) {
    switch (type) {
      case '텍스트':
        return primary;
      case 'URL':
        return success;
      case 'WiFi':
        return warning;
      case '연락처':
        return info;
      default:
        return primary;
    }
  }

  // Color with alpha utilities
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}