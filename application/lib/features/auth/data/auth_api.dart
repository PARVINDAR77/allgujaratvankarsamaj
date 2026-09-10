import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';

import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

/// Low-level API client for NestJS Authentication endpoints
class AuthApi {
  final DioClient dioClient;

  AuthApi(this.dioClient);

  /// Registers a new user (`POST /api/v1/auth/register`)
  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await dioClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(e.message ?? 'Registration failed');
    }
  }

  /// Logs in an existing user (`POST /api/v1/auth/login`)
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dioClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(e.message ?? 'Login failed');
    }
  }

  /// Gets the currently authenticated user (`GET /api/v1/auth/me`)
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.dio.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(e.message ?? 'Failed to fetch current user');
    }
  }
}
