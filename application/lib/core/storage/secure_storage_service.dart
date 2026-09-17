import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String keyToken = 'jwt_token';
  static const String keyUser = 'user_data';

  Future<void> saveToken(String token) async {
    await _storage.write(key: keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: keyToken);
  }
}
