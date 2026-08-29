class Env {
  Env._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://api.smarttrust.local',
    defaultValue: 'http://localhost:8080',
  );

  static const debug = bool.fromEnvironment('DEBUG', defaultValue: true);
}
