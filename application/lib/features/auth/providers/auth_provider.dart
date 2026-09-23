import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_models.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticated(UserModel user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _storage;
  final Dio _dio;

  AuthNotifier(this._storage, this._dio) : super(AuthState.initial()) {
    _checkAuth();
  }

  UserModel? _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String decoded = utf8.decode(base64Url.decode(normalized));
      
      final data = jsonDecode(decoded);
      return UserModel(
        id: data['sub']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        role: data['role']?.toString() ?? 'USER',
        status: 'ACTIVE',
      );
    } catch (e) {
      print('JWT Decode error: $e');
      return null;
    }
  }

  Future<void> _checkAuth() async {
    // Make login mandatory every time by clearing any existing session on startup
    await _storage.deleteToken();
    state = AuthState.unauthenticated();
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['accessToken'];
      if (token != null) {
        await _storage.saveToken(token);
        final user = _decodeToken(token);
        if (user != null) {
          state = AuthState.authenticated(user);
          return true;
        }
      }
      state = AuthState.error('Failed to parse authentication data');
      return false;
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      state = AuthState.error(failure.message);
      return false;
    } catch (e) {
      state = AuthState.error('An unexpected error occurred: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password, {String? phone, String? name, String? gender}) async {
    state = AuthState.loading();
    try {
      // Backend expects email, phone, name, gender, password
      await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (name != null) 'name': name,
        if (gender != null) 'gender': gender,
      });
      // Immediately log in after successful registration
      return await login(email, password);
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      state = AuthState.error(failure.message);
      return false;
    } catch (e) {
      state = AuthState.error('An unexpected error occurred: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    state = AuthState.unauthenticated();
  }

  ApiFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiFailure(
        type: ApiFailureType.networkTimeout,
        message: 'Connection timed out. Please check your internet.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiFailure(
        type: ApiFailureType.noConnection,
        message: 'No internet connection. Please check your network.',
      );
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      final serverMessage = e.response?.data?['message'];
      final messageString = serverMessage is List ? serverMessage.first : serverMessage?.toString();
      return ApiFailure.fromStatusCode(statusCode, messageString);
    }
    return ApiFailure(
      type: ApiFailureType.unknown,
      message: e.message ?? 'An unexpected error occurred.',
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final dio = ref.watch(apiClientProvider);
  return AuthNotifier(storage, dio);
});
