import '../../domain/entities/splash_destination.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_local_data_source.dart';

class SplashRepositoryImpl implements SplashRepository {
  SplashRepositoryImpl(this._localDataSource);

  final SplashLocalDataSource _localDataSource;

  @override
  Future<SplashDestination> resolveLaunchDestination() async {
    final hasSeenOnboarding = await _localDataSource.hasSeenOnboarding();
    if (!hasSeenOnboarding) {
      return SplashDestination.onboarding;
    }

    final hasActiveSession = await _localDataSource.hasActiveSession();
    if (!hasActiveSession) {
      return SplashDestination.login;
    }

    // This is intentionally only a fast, cached route decision. Your auth
    // feature should refresh/validate the JWT before loading protected data.
    switch ((await _localDataSource.readCachedRole())?.toLowerCase()) {
      case 'customer':
        return SplashDestination.customerHome;
      case 'provider':
      case 'service_provider':
        return SplashDestination.providerFeed;
      case 'admin':
        return SplashDestination.adminVerification;
      default:
        // A token without a known role is not trusted as a valid session.
        return SplashDestination.login;
    }
  }
}
