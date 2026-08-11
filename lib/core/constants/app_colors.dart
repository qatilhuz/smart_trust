import 'package:flutter/material.dart';

/// SmartTrust semantic color tokens.
///
/// Keep reusable product colors here rather than defining them in feature
/// widgets. Opacity variants should be derived from these tokens at the point
/// of use when they are genuinely decorative.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF42A5F5);
  static const Color primaryLight = Color(0xFF90CAF9);
  static const Color primaryDark = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF0D2A4A);
  static const Color secondaryLight = Color(0xFF1E456D);
  static const Color secondaryDark = Color(0xFF071B30);

  // Surfaces and text
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = surface;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = border;

  // Semantic status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Platform/common values
  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color white70 = Color(0xB3FFFFFF);
}
