class AppConfig {
  /// Set via --dart-define=APP_ENV=development|staging|production
  /// Defaults to development (Android emulator uses 10.0.2.2).
  static const String environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');

  /// For physical Android devices on LAN, override via:
  ///   --dart-define=APP_ENV=development --dart-define=DEV_HOST=192.168.1.x
  /// For Android emulator:
  ///   --dart-define=DEV_HOST=10.0.2.2
  /// Default: 192.168.1.5 — works for physical device on LAN.
  static const String _devHost =
      String.fromEnvironment('DEV_HOST', defaultValue: '192.168.1.5');

  static String get baseUrl {
    switch (environment) {
      case 'production':
        // Replace with your actual production domain when provisioned.
        return String.fromEnvironment(
          'PROD_API_URL',
          defaultValue: 'https://allgujaratvankarsamaj.com/api/v1',
        );
      case 'staging':
        // Replace with your actual staging domain when provisioned.
        return String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: 'https://staging-api.vankarsamaj.com/api/v1',
        );
      case 'development':
      default:
        // Pointing to local backend
        return 'https://allgujaratvankarsamaj.com/api/v1';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}

