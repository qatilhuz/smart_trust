import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'LocalStorageService provider must be initialized in main or app bootstrap.',
  );
});

class LocalStorageService {
  final SharedPreferences _preferences;

  LocalStorageService(this._preferences);

  bool get onboardingCompleted =>
      _preferences.getBool('onboardingCompleted') ?? false;

  Future<bool> setOnboardingCompleted(bool value) async {
    return _preferences.setBool('onboardingCompleted', value);
  }

  bool get hasSeenIntro => _preferences.getBool('hasSeenIntro') ?? false;

  Future<bool> setHasSeenIntro(bool value) async {
    return _preferences.setBool('hasSeenIntro', value);
  }

  Future<bool> setDarkModeEnabled(bool value) async {
    return _preferences.setBool('darkModeEnabled', value);
  }

  bool get darkModeEnabled => _preferences.getBool('darkModeEnabled') ?? false;
}
