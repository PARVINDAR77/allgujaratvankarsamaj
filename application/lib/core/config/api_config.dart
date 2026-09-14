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

    // Default to live production backend domain across Web, Android (APK), iOS, etc.
    return 'https://allgujaratvankarsamaj.com/api/v1';
  }
}
