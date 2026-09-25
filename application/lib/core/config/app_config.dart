class AppConfig {
  // Use a factory to support environments later if needed
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'development');
  
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.vankarsamaj.com/api/v1';
      case 'staging':
        return 'https://staging-api.vankarsamaj.com/api/v1';
      case 'development':
      default:
        return 'http://127.0.0.1:3000/api/v1';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
