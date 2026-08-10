import '../entities/splash_destination.dart';

/// Contract owned by the splash feature.
///
/// Presentation depends only on this contract. The data implementation may use
/// SharedPreferences, FlutterSecureStorage, or later your auth API refresh
/// endpoint without changing the splash UI.
abstract interface class SplashRepository {
  Future<SplashDestination> resolveLaunchDestination();
}
