// lib/constants/config.dart
class AppConfig {
  // Environment-based configuration
  static final String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  static final String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _getDefaultApiUrl(),
  );

  static const String apiVersion = 'v1';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Authentication
  static const String tokenRefreshThreshold = '5'; // minutes before expiry
  static const Duration sessionTimeout = Duration(hours: 2400);

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expires_at';
  static const String userDataKey = 'user_data';

  // App Configuration
  static const int notificationDefaultDuration = 5; // seconds
  static const String appName = 'Agape Farm App';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false;

  // Development/Testing
  static const bool useMockServices = bool.fromEnvironment(
    'USE_MOCK_SERVICES',
    defaultValue: false,
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  static String _getDefaultApiUrl() {
    switch (environment) {
      case 'production':
        return 'http://192.168.100.161/mango-backend/public/api/v1';
      case 'staging':
        return 'https://staging-api.agapefarm.com/v1';
      case 'development':
      default:
        return 'http://192.168.100.10/mangoAppBackend/public/api/v1';
    }
  }

  // Network configuration
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': '$appName/$appVersion',
  };

  // Error messages
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String authErrorMessage =
      'Authentication failed. Please log in again.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
}