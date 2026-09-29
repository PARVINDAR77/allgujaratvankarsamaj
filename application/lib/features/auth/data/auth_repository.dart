import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      return {
        'token': data['access_token'] ?? data['accessToken'],
        'user': UserModel.fromJson(data['user']),
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      }
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('An unexpected error occurred during login');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      return {
        'token': data['access_token'] ?? data['accessToken'],
        'user': UserModel.fromJson(data['user']),
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('An unexpected error occurred during registration');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});
