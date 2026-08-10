import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Only this class knows the actual local-storage keys used at app launch.
abstract interface class SplashLocalDataSource {
  Future<bool> hasSeenOnboarding();
  Future<bool> hasActiveSession();
  Future<String?> readCachedRole();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  SplashLocalDataSourceImpl({
    required SharedPreferences preferences,
    required FlutterSecureStorage secureStorage,
  })  : _preferences = preferences,
        _secureStorage = secureStorage;

  static const _onboardingSeenKey = 'onboarding_seen';
  static const _accessTokenKey = 'access_token';
  static const _roleKey = 'user_role';

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<bool> hasSeenOnboarding() async {
    return _preferences.getBool(_onboardingSeenKey) ?? false;
  }

  @override
  Future<bool> hasActiveSession() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null && token.trim().isNotEmpty;
  }

  @override
  Future<String?> readCachedRole() async {
    return _preferences.getString(_roleKey);
  }
}
