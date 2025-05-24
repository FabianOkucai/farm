class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.agapefarm.com/v1',
  );

  static const String apiVersion = 'v1';

  // Add other configuration constants as needed
  static const int notificationDefaultDuration = 5; // seconds
  static const String appName = 'Agape Farm App';
}
