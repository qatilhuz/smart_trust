class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'My App';
  static const String appVersion = '1.0.0';

  // Network
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 8;

  // UI
  static const double maxContentWidth = 1200.0;

  // Image
  static const double defaultImageAspectRatio = 16 / 9;
}