import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_font_size.dart';

/// Complete, reusable text styles for the SmartTrust light theme.
///
/// Keeping size, weight, color, and line height together prevents screens from
/// recreating subtly different versions of the same hierarchy.
class AppTextStyles {
  AppTextStyles._();

  static const heading1 = TextStyle(
    fontSize: AppFonts.display,
    fontWeight: AppFonts.bold,
    color: AppColors.textPrimary,
    height: AppFonts.lineHeightSmall,
  );

  static const heading2 = TextStyle(
    fontSize: AppFonts.headingMedium,
    fontWeight: AppFonts.bold,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const heading3 = TextStyle(
    fontSize: AppFonts.headingSmall,
    fontWeight: AppFonts.semiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const bodyRegular = TextStyle(
    fontSize: AppFonts.lg,
    fontWeight: AppFonts.regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: AppFonts.lg,
    fontWeight: AppFonts.medium,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: AppFonts.md,
    fontWeight: AppFonts.regular,
    color: AppColors.textSecondary,
    height: AppFonts.lineHeightNormal,
  );

  static const label = TextStyle(
    fontSize: AppFonts.sm,
    fontWeight: AppFonts.medium,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const button = TextStyle(
    fontSize: AppFonts.lg,
    fontWeight: AppFonts.bold,
    color: AppColors.surface,
    height: AppFonts.lineHeightSmall,
  );

  static const input = bodyRegular;
  static const navigation = label;
  static const caption = bodySmall;
}
