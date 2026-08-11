/// Non-visual application configuration and validation defaults.
///
/// Visual tokens belong in AppColors, AppSpacing, AppFonts, or AppSizes.
class AppConstants {
  AppConstants._();

  static const String appName = 'SmartTrust';
  static const String appVersion = '1.0.0';

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  static const int minPasswordLength = 8;
  static const int maxRequestImages = 4;

  static const double maxContentWidth = 1200.0;
  static const double defaultImageAspectRatio = 16 / 9;
}
