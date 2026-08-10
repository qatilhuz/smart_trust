import '../../domain/entities/splash_destination.dart';

/// Presentation-level bridge between a semantic splash decision and GoRouter.
///
/// If you later centralize these in core/router/route_names.dart, replace the
/// string values below with your AppRouteNames constants.
extension SplashDestinationRouteMapper on SplashDestination {
  String get routePath {
    switch (this) {
      case SplashDestination.onboarding:
        return '/onboarding';
      case SplashDestination.login:
        return '/auth/login';
      case SplashDestination.customerHome:
        return '/customer/home';
      case SplashDestination.providerFeed:
        return '/provider/feed';
      case SplashDestination.adminVerification:
        return '/admin/verification';
    }
  }
}
