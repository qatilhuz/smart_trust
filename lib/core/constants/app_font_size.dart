import 'package:flutter/material.dart';

/// Low-level typography metrics shared by [AppTextStyles].
///
/// Screens should normally consume a complete style from AppTextStyles rather
/// than combining these values themselves.
class AppFonts {
  AppFonts._();

  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 20.0;
  static const double xxxl = 24.0;

  static const double headingSmall = xxl;
  static const double headingMedium = xxxl;
  static const double headingLarge = 28.0;
  static const double display = 32.0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  static const double lineHeightSmall = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightLarge = 1.6;
}
