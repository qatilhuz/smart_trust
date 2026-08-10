import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/splash_local_data_source.dart';
import '../../data/repositories/splash_repository_impl.dart';
import '../../domain/entities/splash_destination.dart';
import '../../domain/repositories/splash_repository.dart';

/// Override this once in main.dart after awaiting SharedPreferences.getInstance().
///
/// If your project already exposes a SharedPreferences/local-storage provider,
/// remove this provider and read your existing one inside [splashLocalDataSourceProvider].
final splashSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override splashSharedPreferencesProvider in ProviderScope from main.dart.',
  );
});

/// Keep this provider if you do not already have a core secure-storage provider.
final splashSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final splashLocalDataSourceProvider = Provider<SplashLocalDataSource>((ref) {
  return SplashLocalDataSourceImpl(
    preferences: ref.watch(splashSharedPreferencesProvider),
    secureStorage: ref.watch(splashSecureStorageProvider),
  );
});

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepositoryImpl(ref.watch(splashLocalDataSourceProvider));
});

/// Starts the session/onboarding decision while the brand animation is playing.
final splashDestinationProvider = FutureProvider.autoDispose<SplashDestination>((ref) {
  return ref.watch(splashRepositoryProvider).resolveLaunchDestination();
});
