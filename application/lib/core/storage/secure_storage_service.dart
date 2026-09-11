import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service providing platform-safe secure storage for sensitive authentication tokens
class SecureStorageService {
  static const String _tokenKey = 'access_token';
  static String? _inMemoryToken;

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

  /// Saves the JWT access token securely with fast fallback
  Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token).timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {}
  }

  /// Retrieves the stored JWT access token safely
  Future<String?> getToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }
    try {
      final token = await _storage.read(key: _tokenKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (token != null && token.isNotEmpty) {
        _inMemoryToken = token;
      }
      return token;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  /// Purges the stored JWT access token on logout or session expiration
  Future<void> deleteToken() async {
    _inMemoryToken = null;
    try {
      await _storage.delete(key: _tokenKey).timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {}
  }

  /// Checks if an access token exists in storage
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
