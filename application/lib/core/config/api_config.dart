import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { development, staging, production }

class ApiConfig {
  final Environment environment;
  final String? customBaseUrl;

  const ApiConfig({
    this.environment = Environment.development,
    this.customBaseUrl,
  });

  /// Dynamically resolves the platform-aware base URL
  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    switch (environment) {
      case Environment.staging:
        return 'https://staging-api.vankarsamaj.org/api/v1';
      case Environment.production:
        return 'https://api.vankarsamaj.org/api/v1';
      case Environment.development:
        return _developmentBaseUrl;
    }
  }

  static String get _developmentBaseUrl {
    if (kIsWeb) {
      // Web / Chrome browser targets host localhost directly
      return 'http://localhost:3000/api/v1';
    }

    try {
      if (Platform.isAndroid) {
        // Host machine LAN IP for physical mobile devices and emulators
        return 'http://192.168.1.18:3000/api/v1';
      }
    } catch (_) {
      // Fallback for non-IO platforms
    }

    // Default for iOS Simulator, Windows Desktop, macOS
    return 'http://localhost:3000/api/v1';
  }
}
