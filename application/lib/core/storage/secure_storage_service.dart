import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service providing platform-safe secure storage for sensitive authentication tokens
class SecureStorageService {
  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              webOptions: WebOptions(
                dbName: 'vankar_matrimony_secure_store',
                publicKey: 'vankar_matrimony_app_key',
              ),
            );

  /// Saves the JWT access token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the stored JWT access token, or null if not set
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Purges the stored JWT access token on logout or session expiration
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Checks if an access token exists in storage
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
