import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String keyToken = 'jwt_token';
  static const String keyUser = 'user_data';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: keyToken, value: token);
    } catch (e) {
      debugPrint('[Storage] Secure storage write error: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyToken, token);
    } catch (e) {
      debugPrint('[Storage] SharedPreferences write error: $e');
    }
  }

  Future<String?> getToken() async {
    // On Web, SharedPreferences is backed by standard browser localStorage which never loses keys on reload
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(keyToken);
        if (token != null && token.trim().isNotEmpty) {
          return token.trim();
        }
      } catch (e) {
        debugPrint('[Storage] Web SharedPreferences read error: $e');
      }
    }

    try {
      final token = await _storage.read(key: keyToken);
      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    } catch (e) {
      debugPrint('[Storage] Secure storage read error: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(keyToken)?.trim();
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: keyToken);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyToken);
    } catch (_) {}
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final raw = jsonEncode(data);
    try {
      await _storage.write(key: keyUser, value: raw);
    } catch (e) {
      debugPrint('[Storage] Secure storage user write error: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyUser, raw);
    } catch (e) {
      debugPrint('[Storage] SharedPreferences user write error: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    String? raw;
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(keyUser);
      } catch (e) {
        debugPrint('[Storage] Web SharedPreferences user read error: $e');
      }
    }

    if (raw == null || raw.trim().isEmpty) {
      try {
        raw = await _storage.read(key: keyUser);
      } catch (e) {
        debugPrint('[Storage] Secure storage user read error: $e');
      }
    }

    if (raw == null || raw.trim().isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(keyUser);
      } catch (_) {}
    }

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('[Storage] User data parse error: $e');
      }
    }
    return null;
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: keyUser);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyUser);
    } catch (_) {}
  }
}
