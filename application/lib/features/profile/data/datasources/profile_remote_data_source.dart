import 'package:dio/dio.dart';
import '../../../../core/network/api_failure.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getReferenceData() async {
    try {
      final response = await _dio.get('/profiles/reference-data');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> getProfiles({
    int page = 1,
    int limit = 20,
    String? search,
    String? gender,
    String? status,
    int? minAge,
    int? maxAge,
    String? districtId,
    String? occupationCategory,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (minAge != null) queryParams['ageMin'] = minAge;
      if (maxAge != null) queryParams['ageMax'] = maxAge;
      if (districtId != null && districtId.isNotEmpty) queryParams['districtId'] = districtId;
      if (occupationCategory != null && occupationCategory.isNotEmpty) queryParams['occupationCategory'] = occupationCategory;

      final response = await _dio.get('/profiles', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _dio.get('/profiles/me');
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> getProfileById(String id) async {
    try {
      final response = await _dio.get('/profiles/$id');
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/profiles', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/profiles/me', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> getProfileCompleteness() async {
    try {
      final response = await _dio.get('/profiles/completeness');
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiFailure(type: ApiFailureType.networkTimeout, message: 'Connection timed out.');
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      final data = e.response?.data;
      final serverMessage = (data is Map<String, dynamic>) ? data['message'] : null;
      final messageString = serverMessage is List ? serverMessage.first : serverMessage?.toString();
      return ApiFailure.fromStatusCode(statusCode, messageString);
    }
    return ApiFailure(type: ApiFailureType.unknown, message: e.message ?? 'An unexpected error occurred.');
  }
}
