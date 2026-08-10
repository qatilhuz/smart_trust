class Env {
  Env._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.smarttrust.local',
  );

  static const debug = bool.fromEnvironment('DEBUG', defaultValue: true);
}
