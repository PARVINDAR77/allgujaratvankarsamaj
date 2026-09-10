import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'profile_models.dart';

/// Low-level API client for NestJS Matrimonial Profile endpoints.
/// Uses the existing DioClient (with AuthInterceptor already attached).
class ProfileApi {
  final DioClient dioClient;

  ProfileApi(this.dioClient);

  /// GET /api/v1/profile/me
  /// Returns the authenticated user's profile or throws [ServerException] on error.
  Future<MatrimonialProfileModel> getMyProfile() async {
    try {
      final response = await dioClient.dio.get('/profile/me');
      return MatrimonialProfileModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// POST /api/v1/profile
  /// Creates a new profile. 409 if profile already exists.
  Future<MatrimonialProfileModel> createProfile(
      CreateProfileRequest request) async {
    try {
      final response = await dioClient.dio.post(
        '/profile',
        data: request.toJson(),
      );
      return MatrimonialProfileModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// PATCH /api/v1/profile/me
  /// Updates the authenticated user's profile with partial data.
  Future<MatrimonialProfileModel> updateProfile(
      UpdateProfileRequest request) async {
    try {
      final response = await dioClient.dio.patch(
        '/profile/me',
        data: request.toJson(),
      );
      return MatrimonialProfileModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// DELETE /api/v1/profile/me
  /// Returns {message: "Profile deleted successfully"}.
  Future<void> deleteProfile() async {
    try {
      await dioClient.dio.delete('/profile/me');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// GET /api/v1/profile/reference-data
  /// Returns gender and maritalStatus enum arrays from backend.
  Future<ReferenceDataModel> getReferenceData() async {
    try {
      final response = await dioClient.dio.get('/profile/reference-data');
      return ReferenceDataModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// GET /api/v1/profile/completeness
  /// Returns {completedFields, totalFields, percentage, isComplete}.
  Future<CompletenessModel> getCompleteness() async {
    try {
      final response = await dioClient.dio.get('/profile/completeness');
      return CompletenessModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message']?.toString() ??
        e.message ??
        'An unexpected error occurred';
    if (statusCode == 401) return UnauthorizedException(message);
    if (statusCode == 404) return ServerException(message, 404);
    if (statusCode == 409) return ServerException(message, 409);
    return ServerException(message, statusCode);
  }
}
