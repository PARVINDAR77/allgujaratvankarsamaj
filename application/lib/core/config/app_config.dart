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
        // Use 10.0.2.2 for Android Emulator, or localhost for iOS/Web
        // For physical devices, this needs to be a LAN IP.
        return 'http://10.0.2.2:3000/api/v1';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
